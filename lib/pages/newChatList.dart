import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chatList.dart';

class CreateRoomDialog extends StatefulWidget {
  @override
  _CreateRoomDialogState createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController usersController = TextEditingController(); // comma-separated emails

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create New Chat Room"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: roomNameController,
            decoration: InputDecoration(labelText: "Room Name"),
          ),
          TextField(
            controller: usersController,
            decoration: InputDecoration(labelText: "User Emails (comma-separated)"),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text("Create"),
          onPressed: () async {
            final roomName = roomNameController.text.trim();
            final rawUsers = usersController.text.trim();

            //prevent duplication
            Set<String> userSet = rawUsers
                .split(',')
                .map((e) => e.trim())
                .where((email) => email.isNotEmpty)
                .toSet();

            final userList = userSet.toList();
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              final currentEmail = await getUserEmail(currentUser.uid);
              if (currentEmail != null) userList.add(currentEmail);
            }


            await FirebaseFirestore.instance.collection('chats').doc(roomName).set({
              'roomName': roomName,
              'includedUsers': userList,
            });

            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}