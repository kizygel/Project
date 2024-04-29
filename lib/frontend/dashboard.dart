import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String _userName = 'Guest';

  @override
  void initState() {
    super.initState();
    _fetchName();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> _fetchName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        _userName = docSnapshot['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber.shade900,
        height: 1000,
        child: Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hi! ${_userName}",
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                  ),
                  Container(child: Text('Dashboard'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
