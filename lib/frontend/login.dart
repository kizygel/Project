import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quantumaware/frontend/bottomNavigation.dart';
import 'package:quantumaware/frontend/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FocusNode myFocusNode = FocusNode();
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late String error;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    error = "";
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(color: Colors.amber[900]),
      child: Center(
        child: Expanded(
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'QuantomAware',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: const Color.fromARGB(255, 55, 17, 101),
                    ),
                  ),
                ),
                height(),
                Text(
                  'Username',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                height(),
                Container(
                  padding: const EdgeInsets.only(left: 15),
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter username',
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? Colors.blue
                                : Colors.black)),
                  ),
                ),
                height(),
                Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                height(),
                Container(
                  padding: const EdgeInsets.only(left: 15),
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter password',
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? Colors.blue
                                : Colors.black)),
                  ),
                ),
                height(),
                height(),
                ElevatedButton(
                  onPressed: () {
                    signIn();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 55, 17, 101),
                    padding: const EdgeInsets.all(3.0),
                    minimumSize: const Size(350, 50),
                    maximumSize: const Size(350, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(
                      color: Colors.white, // Change the text color to white
                    ),
                  ),
                ),
                height(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUp()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(3.0),
                    minimumSize: const Size(350, 50),
                    maximumSize: const Size(350, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(
                      color: Color.fromARGB(
                          255, 55, 17, 101), // Change the text color to white
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  SizedBox height() {
    return SizedBox(
      height: 10,
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );
      setState(() {
        error = "";
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        error = e.message.toString();
      });
    }
    Navigator.pop(context);
  }
}
