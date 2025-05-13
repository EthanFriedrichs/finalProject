// import 'dart:ffi';
import '../main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';

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

class ChatsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: FutureBuilder<List<Chat>>(
        future: fetchUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: LinearProgressIndicator());
          }

          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chats found'));
          }

          else {
            final chats = snapshot.data!;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  title: Text(chat.roomName),
                  subtitle: Text('Users: ${chat.includedUsers.join(', ')}'),
                  onTap: () async {
                    final messages = await fetchMessages(chat.roomName);
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