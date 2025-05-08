import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          _cpasswordController.text.isNotEmpty && _passwordController.text == _cpasswordController.text;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();
    super.dispose();
  }

  Future<bool> firebaseSignup(email, password) async {
    log("email $email password $password");
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'email': _emailController.text.trim(),
        'firstname': '',
        'lastname': '',
        'profile': '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful')), ) ;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  Page3()),
      );
      return true;

    } on FirebaseAuthException catch (e) {
      printError(e);
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void printError(FirebaseAuthException e){
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }else if (e.code == 'invalid-email') {
      print('The email address is not valid.');
    }else if (e.code == 'user-not-found') {
      print('There is no user by this email');
    }else if (e.code == 'wrong-password') {
      print('Wrong password');
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up Screen')),
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
                  ? () async {
                //log("email ${_emailController.text} password ${_passwordController.text}");

                await firebaseSignup(_emailController.text, _passwordController.text);

              }
                  : null,
              child: const Text("Create Account"),
            ),
          ],
        ),

      ),
    );
  }
}