// import 'dart:ffi';
// import '../main.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String roomName;
  final List<String> includedUsers;

  Chat({required this.roomName, required this.includedUsers});

  factory Chat.fromMap(Map<String, dynamic> data) {
    return Chat(
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

Future<List<Chat>> fetchUserChats(String userEmail) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('chats')
      .where('includedUsers', arrayContains: userEmail)
      .get();

  return querySnapshot.docs.map((doc) => Chat.fromMap(doc.data())).toList();
}

class ChatsPage extends StatelessWidget {
  final String userEmail;

  ChatsPage({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: FutureBuilder<List<Chat>>(
        future: fetchUserChats(userEmail),
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
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Message(senderEmail: '', text: ''),
                    //   ),
                    // );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}