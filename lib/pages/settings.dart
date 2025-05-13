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
              onPressed: () {
                themeNotifier.value = themeNotifier.value == ThemeMode.light
                    ? ThemeMode.dark
                    : ThemeMode.light;
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
                    // Prompt user to re-authenticate before deletion
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please log in again before deleting your account."),
                    ));
                    // Optionally navigate to re-login screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Error: ${e.toString()}"),
                    ));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,       // Background stays red
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),

              child: Text("Delete Account"),
            )
          ],
        ),
      ),
    );
  }
}