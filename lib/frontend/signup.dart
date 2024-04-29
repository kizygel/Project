import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quantumaware/frontend/bottomNavigation.dart';
import 'package:quantumaware/frontend/login.dart';
import 'package:quantumaware/frontend/users.dart';

class SignUp extends StatefulWidget {
  SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FocusNode myFocusNode = FocusNode();
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late String error;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    emailController = TextEditingController();
    error = "";
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    emailController.dispose();
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
                  'Name',
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
                    controller: nameController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter name',
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? Colors.blue
                                : Colors.black)),
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
                  'Email',
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
                    controller: emailController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter email',
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? Colors.blue
                                : Colors.black)),
                  ),
                ),
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
                    registerUser();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 55, 17, 101),
                    padding: const EdgeInsets.all(18.0),
                    minimumSize: const Size(350, 50),
                    maximumSize: const Size(350, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(
                      color: Colors.white, // Change the text color to white
                    ),
                  ),
                ),
                height(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.all(18.0),
                    minimumSize: const Size(350, 50),
                    maximumSize: const Size(350, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "SIGN IN",
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

  void registerUser() async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      await FirebaseFirestore.instance
          .collection('User')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text,
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        // Add additional fields here
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarExample()),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
      });
      print(e);
    }
  }
}
