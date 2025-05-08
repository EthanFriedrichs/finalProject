import 'pages/signup.dart';
import 'pages/login.dart';
import 'pages/account.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';




void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCbIVleeWSrCrL9PUGXz6slbrLtlM36iNA",
          authDomain: "fir-tuesday-3a2ed.firebaseapp.com",
          projectId: "fir-tuesday-3a2ed",
          storageBucket: "fir-tuesday-3a2ed.firebasestorage.app",
          messagingSenderId: "885008455506",
          appId: "1:885008455506:web:b848607d5eddb8952a0c8b"
      ));

  runApp(MaterialApp(
    home: Page1()
  )
  );
}

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
              title: Text("My Account"),
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
              title: Text("Logout"),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Page1()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}


class Page1 extends StatefulWidget {
  @override
  State<Page1> createState() => _Page1State();
}
class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) {
                          return Page3();
                        }
                    )
                );
              },

              child: Text("Login"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) {
                          return Page2();
                        }
                    )
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


