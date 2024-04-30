import 'package:cloud_firestore/cloud_firestore.dart';
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
      decoration: BoxDecoration(color: Color.fromARGB(255, 238, 107, 6)),
      child: Center(
        child: Expanded(
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image(
                    image: AssetImage('assets/images/logo.jpg'),
                    width: 180,
                    height: 180,
                  ),
                ),
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
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                        hintText: 'Enter email',
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
                    login(context);
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
                height(),
                Center(
                  child: Text(
                    error,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                )
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

  login(BuildContext context) async {
    try {
      String email = usernameController.text; // Fetch email from Firestore
      String password =
          passwordController.text; // Get password from the user input

      // Sign in the user with fetched email and the provided password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Get the user from the userCredential
      User? user = userCredential.user;

      if (user != null) {
        setState(() {
          error = ""; // Clear the error message on successful login
        });
        // Navigate to the PovDashboard with only the userID
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BottomNavigationBarExample(),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            error = "No user found with that email.";
            break;
          case 'wrong-password':
            error = "Wrong password provided for that user.";
            break;
          case 'invalid-email':
            error = "Invalid email provided.";
            break;
          case 'user-disabled':
            error = "User account has been disabled.";
            break;
          default:
            error = "An error occurred: ${e.message}";
        }
      });
    } catch (e) {
      setState(() {
        error = "An error occurred: $e";
      });
    }
  }
}
