import 'chat.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


class Page2 extends StatefulWidget {
  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpasswordController = TextEditingController();
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _cpasswordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _cpasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log In Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //input email
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 + 35,
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),

            SizedBox(height: 25,),

            //input password
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 + 35,
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),

            SizedBox(height: 25,),

            //confirm password
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 + 35,
              child: TextField(
                controller: _cpasswordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                ),
              ),
            ),

            SizedBox(height: 25,),

            ElevatedButton(
              onPressed: isButtonEnabled
                  ? () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Page4()),
                      (Route<dynamic> route) => false, // removes all previous routes
                );
              }
                  : null, // disables the button
              child: const Text("Create Account"),
            ),
          ],
        ),

      ),
    );
  }
}