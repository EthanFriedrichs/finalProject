// import 'dart:ffi';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';
import 'newChatList.dart';

class Chat {
  final String id; // <-- Firestore document ID
  final String roomName;
  final List<String> includedUsers;

  Chat({
    required this.id,
    required this.roomName,
    required this.includedUsers,
  });

  factory Chat.fromMap(Map<String, dynamic> data, String id) {
    return Chat(
      id: id,
      roomName: data['roomName'],
      includedUsers: List<String>.from(data['includedUsers']),
    );
  }
}

class Message {
  final String senderEmail;
  final String text;

  Message({required this.senderEmail, required this.text});

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      senderEmail: data['senderEmail'],
      text: data['text'],
    );
  }
}

Future<List<Chat>> fetchUserChats() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final uid = currentUser?.uid;

  if (uid == null) {
    throw Exception('User is not logged in');
  }

  final userEmail = await getUserEmail(uid);

  if (userEmail == null) {
    throw Exception('User email not found');
  }

  final querySnapshot = await FirebaseFirestore.instance
      .collection('chats')
      .where('includedUsers', arrayContains: userEmail)
      .get();

  return querySnapshot.docs
      .map((doc) => Chat.fromMap(doc.data(), doc.id)) // <-- include doc.id
      .toList();
}

Future<String?> getUserEmail(String uid) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();

  if (querySnapshot.exists) {
    return querySnapshot.data()?['email'] as String?;
  }

  else {
    return null;
  }
}

Future<List<Message>> fetchMessages(String chatId) async {
  try {
    print("CHATID:");
    print(chatId);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('No messages found');
    } else {
      print('Messages found: ${querySnapshot.docs.length}');
    }

    return querySnapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
  } catch (e) {
    print('Error fetching messages: $e');
    return [];
  }
}


class ChatsPage extends StatefulWidget {
  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  void initState() {
    super.initState();
    _loadUserTheme(); // Call your theme loading logic here
  }

  Future<void> _loadUserTheme() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final theme = doc.data()?['theme'];
      if (theme == 'dark') {
        themeNotifier.value = ThemeMode.dark;
      } else {
        themeNotifier.value = ThemeMode.light;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CreateRoomDialog(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('includedUsers', arrayContains: FirebaseAuth.instance.currentUser?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LinearProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chats found'));
          } else {
            final chatDocs = snapshot.data!.docs;
            final chats = chatDocs.map((doc) => Chat.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  title: Text(chat.roomName),
                  subtitle: Text('Users: ${chat.includedUsers.join(', ')}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Page4(
                          chatId: chat.id,
                          roomName: chat.roomName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      drawer: const CustomDrawer(),
    );
  }
}