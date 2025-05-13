import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account.dart';

class Message {
  final String senderEmail;
  final String senderUid;
  final String text;

  Message({
    required this.senderEmail,
    required this.text,
    required this.senderUid,
  });

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      senderEmail: data['senderEmail'],
      senderUid: data['senderUid'],
      text: data['text'],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String senderEmail;
  final String text;
  final bool isMe;

  MessageBubble({
    required this.senderEmail,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderEmail,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Page4 extends StatefulWidget {
  final String chatId;
  final String roomName;

  Page4({required this.chatId, required this.roomName});

  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  final TextEditingController _messageController = TextEditingController();
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || currentUserEmail == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderEmail': currentUserEmail,
      'senderUid': FirebaseAuth.instance.currentUser?.uid,
      'text': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];
                final messages = docs
                    .map((doc) => Message.fromMap(doc.data() as Map<String, dynamic>))
                    .toList();

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 60),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderEmail == currentUserEmail;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Page6(userId: message.senderUid),
                          ),
                        );
                      },
                      child: MessageBubble(
                        senderEmail: message.senderEmail,
                        text: message.text,
                        isMe: isMe,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    sendMessage(_messageController.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}