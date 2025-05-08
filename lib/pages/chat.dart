import '../main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Page4 extends StatefulWidget {
  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {

  final TextEditingController _messageController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to both text fields
    _messageController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _messageController.text.isNotEmpty;
    });
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      //DataClass.addMessage(message);
      _messageController.clear();
      setState(() {}); // Refresh the UI to show the new message
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Group Chat')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  //itemCount: DataClass.getMessages().length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => Page5()),
                          //   );
                          // },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            //child: Text(DataClass.getMessages()[index], style: TextStyle(fontSize: 30),),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            //input email
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 + 35,
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'New Message',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isButtonEnabled ? _sendMessage : null,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30,),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
    );
  }
}
