import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quantumaware/frontend/appliances.dart';
import 'package:quantumaware/frontend/billing.dart';
import 'package:quantumaware/frontend/dashboard.dart';
import 'package:quantumaware/frontend/login.dart';
import 'package:quantumaware/frontend/notification.dart';

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  FocusNode myFocusNode = FocusNode();
  late TextEditingController typeController;
  late TextEditingController brandController;
  late TextEditingController wattsController;

  @override
  void initState() {
    super.initState();
    typeController = TextEditingController();
    brandController = TextEditingController();
    wattsController = TextEditingController();
  }

  @override
  void dispose() {
    typeController.dispose();
    brandController.dispose();
    wattsController.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Dashboard(),
    AppliancesPage(),
    NotificationPage(),
    BillingPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[900],
        title: Container(
          color: Colors.amber[900],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MY APPLIANCES',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Container(
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          addAppliances(context);
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: Colors.white,
                        )),
                    IconButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut(); // Sign out the user
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) =>
                                    Login()), // Navigate back to the login page
                            (route) =>
                                true, // Remove all existing routes from the navigation stack
                          );
                        },
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(
          backgroundColor: Colors.purple[900],
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Dashboard',
              backgroundColor: Colors.purple.shade900,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Appliances',
              backgroundColor: Colors.purple.shade900,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
              backgroundColor: Colors.purple.shade900,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Billing',
              backgroundColor: Colors.purple.shade900,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Future<dynamic> addAppliances(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext Context) {
          const textStyle = TextStyle(
            letterSpacing: 0.5,
          );
          return AlertDialog(
            surfaceTintColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Appliances'),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            content: Container(
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: 380,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15),
                          height: 50,
                          decoration: boxDecoration(),
                          child: TextField(
                            controller: typeController,
                            decoration: fieldDecoration('type'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Brand',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15),
                          height: 50,
                          decoration: boxDecoration(),
                          child: TextField(
                            controller: brandController,
                            decoration: fieldDecoration('brand'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Watts',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15),
                          height: 50,
                          decoration: boxDecoration(),
                          child: TextField(
                            controller: wattsController,
                            decoration: fieldDecoration('watts'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.all(3.0),
                                  minimumSize: const Size(100, 40),
                                  maximumSize: const Size(100, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  addAppliance();
                                },
                                child: Text(
                                  'ADD',
                                  style: TextStyle(color: Colors.white),
                                )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.all(3.0),
                                  minimumSize: const Size(100, 40),
                                  maximumSize: const Size(100, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  'CLOSE',
                                  style: TextStyle(color: Colors.white),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                )),
          );
        });
  }

  void addAppliance() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Add data to the "Appliances" collection
    await firestore.collection('Appliances').add({
      'type': typeController.text,
      'brand': brandController.text,
      'watts': wattsController.text,
      // Add more fields as needed
    });

    // Clear the text fields after adding the data
    typeController.clear();
    brandController.clear();
    wattsController.clear();

    // Close the dialog
    Navigator.of(context).pop();
    // Show success dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Appliance added successfully'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade900));
  }

  InputDecoration fieldDecoration(String hintText) {
    return InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter ${hintText}',
        labelStyle: TextStyle(
            color: myFocusNode.hasFocus ? Colors.blue : Colors.black));
  }
}
