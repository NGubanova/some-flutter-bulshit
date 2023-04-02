import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/firebase_options.dart';
import 'package:emoji/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth.dart';
import 'file.dart';

final FirebaseFirestore fireStore = FirebaseFirestore.instance;
String userAutoId = "";

Future<void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),routes: {
        PostPage.name: (context) => const PostPage(title: 'е',),
        FilePage.name: (context) => const FilePage(title: 'е',),
      },
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
                  signUpEmail(_emailController.text, _passwordController.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AuthPage(
                                title: "",
                              )));
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
                      'Зарегистрироваться',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
                onTap: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthPage(
                              title: "",
                            )));},
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Text(
                    'Авторизоваться',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            
          ],
        ),
      ),
    );
  }

  void signUpEmail(String email, String password) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await userAdd(email);
  }

  Future<void> userAdd(String email) {
    final user = fireStore.collection("user");
    return user
        .add({'email': email})
        .then((value) => print("User added"))
        .catchError((error) => print(error.toString()))
        .whenComplete(() => userAutoId = user.id);
  }
}
