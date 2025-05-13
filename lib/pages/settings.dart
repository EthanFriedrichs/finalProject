import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';


class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button to toggle theme
            ElevatedButton.icon(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                final newTheme = themeNotifier.value == ThemeMode.light ? "dark" : "light";

                // Update locally
                themeNotifier.value = newTheme == "dark" ? ThemeMode.dark : ThemeMode.light;

                // Save to Firestore
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  'theme': newTheme,
                });
              },
              icon: Icon(Icons.brightness_6),
              label: Text('Toggle Theme'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 25),

            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                final email = currentUser?.email;

                if (email == null) return;

                final TextEditingController currentPasswordController = TextEditingController();
                final TextEditingController newPasswordController = TextEditingController();

                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Reset Password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: currentPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Current Password'),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'New Password'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              final credential = EmailAuthProvider.credential(
                                email: email,
                                password: currentPasswordController.text.trim(),
                              );

                              await currentUser!.reauthenticateWithCredential(credential);
                              await currentUser.updatePassword(newPasswordController.text.trim());

                              Navigator.pop(context); // Close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Password updated successfully.')),
                              );
                            } on FirebaseAuthException catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.message}')),
                              );
                            }
                          },
                          child: Text('Update'),
                        ),
                      ],
                    );
                  },
                );
              }, child: Text("Password Reset"),
            ),

            SizedBox(height: 25),


            ElevatedButton(
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Confirm Deletion"),
                    content: Text("Are you sure you want to delete your account? This action cannot be undone."),
                    actions: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text("Delete"),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                );

                if (confirm) {
                  try {
                    await FirebaseAuth.instance.currentUser?.delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account Deleted')),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => Page1()),
                          (route) => false,
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'requires-recent-login') {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please log in again before deleting your account."),
                      ));
                      // You could navigate to a login screen here
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Error: ${e.toString()}"),
                      ));
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Delete Account"),
            ),
          ],
        ),
      ),
    );
  }
}