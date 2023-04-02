// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/post.dart';
import 'package:emoji/transfer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'file.dart';

final FirebaseFirestore fireStore = FirebaseFirestore.instance;
String userAutoId = "";

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.title});

  final String title;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _key = GlobalKey();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _nameController = TextEditingController();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 226, 175, 235),
              Color.fromARGB(255, 238, 177, 197),
              Color.fromARGB(255, 250, 161, 190),
              Color.fromARGB(255, 206, 149, 168),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Почта',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40.0),
            SizedBox(
              height: 60.0,
              child: ElevatedButton(
                onPressed: () {
                  var user;
                  user = signInEmail(
                      _emailController.text, _passwordController.text);
                  Navigator.pushNamed(context, PostPage.name,
                      arguments: new Transfer(credential: user));
                },
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Авторизироваться',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () async {
                var user;
                try {
                  user = await signInAnon();
                } on FirebaseAuthException catch (e) {
                  var bar = SnackBar(
                    duration: const Duration(seconds: 5),
                    content: Text(e.message.toString()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(bar);
                }
                Navigator.pushNamed(context, PostPage.name,
                    arguments: new Transfer(credential: user));
              },
              child: Text(
                'Анонимная авторизация',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signInEmail(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInAnon() async {
    return await FirebaseAuth.instance.signInAnonymously();
  }
}
