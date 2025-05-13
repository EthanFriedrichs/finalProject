import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/signup.dart';
import 'pages/chatList.dart';
import 'pages/login.dart';
import 'pages/account.dart';
import 'pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme.dart';

// Global theme notifier for managing theme changes across the app
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);  // Default theme is dark

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCbIVleeWSrCrL9PUGXz6slbrLtlM36iNA",
      authDomain: "fir-tuesday-3a2ed.firebaseapp.com",
      projectId: "fir-tuesday-3a2ed",
      storageBucket: "fir-tuesday-3a2ed.firebasestorage.app",
      messagingSenderId: "885008455506",
      appId: "1:885008455506:web:b848607d5eddb8952a0c8b",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          //key: ValueKey(themeMode), //forces to home page so wont work
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: Page1(),
          builder: (context, child) {
            return child!;
          },
        );
      },
    );
  }
}

// Custom Drawer (unchanged from your code)
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              "Options",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          GestureDetector(
            child: const ListTile(
              title: Text("My Profile"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Page6()),
              );
            },
          ),
          GestureDetector(
            child: const ListTile(
              title: Text("Settings"),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          GestureDetector(
            child: const ListTile(
              title: Text("Logout"),
            ),
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                final uid = user.uid;

                // Update status before signing out
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'status': 'Offline',
                });

                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Page1()),
                      (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Page1 widget with theme toggle button
class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // // Button to toggle theme
            // IconButton(
            //   icon: Icon(Icons.brightness_6),
            //   onPressed: () {
            //     themeNotifier.value = themeNotifier.value == ThemeMode.light
            //         ? ThemeMode.dark
            //         : ThemeMode.light;
            //   },
            // ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page3()),
                );
              },
              child: Text("Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Page2()),
                );
              },
              child: Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
