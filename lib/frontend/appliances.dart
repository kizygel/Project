import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';

class AppliancesPage extends StatefulWidget {
  const AppliancesPage({super.key});

  @override
  State<AppliancesPage> createState() => _AppliancesPageState();
}

class _AppliancesPageState extends State<AppliancesPage> {
  FocusNode myFocusNode = FocusNode();
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
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Appliances')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No data available yet'));
                        } else {
                          List<DocumentSnapshot> dataDocs = snapshot.data!.docs;
                          return SingleChildScrollView(
                            child: Column(
                              children: List.generate(
                                dataDocs.length,
                                (index) {
                                  DocumentSnapshot data = dataDocs[index];
                                  Map<String, dynamic> appliancesData =
                                      data.data() as Map<String, dynamic>;

                                  String userId = data.id;
                                  return Container(
                                    height: 80,
                                    width: double.infinity,
                                    margin: EdgeInsets.fromLTRB(8, 2, 8, 0),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors.purple.shade900,
                                            width: 2)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${appliancesData['type']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                '${appliancesData['brand']}',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black54),
                                              ),
                                              Text(
                                                '${appliancesData['watts']} watts',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.black54),
                                              ),
                                            ]),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  addActivity(
                                                      userId, appliancesData);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  minimumSize:
                                                      const Size(80, 40),
                                                  maximumSize:
                                                      const Size(100, 40),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: Text('Add',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white))),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            ElevatedButton(
                                                onPressed: () {
                                                  viewActivity(userId);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.purple.shade900,
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  minimumSize:
                                                      const Size(80, 40),
                                                  maximumSize:
                                                      const Size(100, 40),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: Text(
                                                  'View',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> viewActivity(String userId) {
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
                  Text('View Activity'),
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
                    height: 250,
                    child: Column(
                      children: [
                        StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Activity')
                                .where('id', isEqualTo: userId)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.data!.docs.isEmpty) {
                                return Center(
                                    child: Text('No data available yet'));
                              } else {
                                List<DocumentSnapshot> dataDocs =
                                    snapshot.data!.docs;
                                return SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(
                                      dataDocs.length,
                                      (index) {
                                        DocumentSnapshot data = dataDocs[index];
                                        Map<String, dynamic> appliancesData =
                                            data.data() as Map<String, dynamic>;

                                        String userId = data.id;
                                        Timestamp timestamp =
                                            appliancesData['onTime'];
                                        DateTime dateTime = timestamp.toDate();
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd HH:mm')
                                                .format(dateTime);

                                        Timestamp timestamp2 =
                                            appliancesData['offTime'];
                                        DateTime dateTime2 =
                                            timestamp2.toDate();
                                        String formattedDate2 =
                                            DateFormat('yyyy-MM-dd HH:mm')
                                                .format(dateTime2);

                                        return Container(
                                          width: double.infinity,
                                          margin:
                                              EdgeInsets.fromLTRB(2, 0, 2, 0),
                                          padding: EdgeInsets.only(left: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                // Wrap in Flexible
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'ON - ${formattedDate} ${appliancesData['addedBy']}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        overflow: TextOverflow
                                                            .ellipsis, // Handle overflow
                                                      ),
                                                    ),
                                                    Text(
                                                      'OFF - ${formattedDate2} ${appliancesData['addedBy']}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        overflow: TextOverflow
                                                            .ellipsis, // Handle overflow
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            }),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  Future<dynamic> addActivity(String userId, Map<String, dynamic> userData) {
    TextEditingController brandController =
        TextEditingController(text: userData['brand'].toString());
    TextEditingController typeController =
        TextEditingController(text: userData['type'].toString());
    TextEditingController wattsController =
        TextEditingController(text: userData['watts'].toString());
    final TextEditingController onTimeController = TextEditingController();
    final TextEditingController offTimeController = TextEditingController();

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
                Text('Add Activity'),
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
                    height: 500,
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
                            readOnly: true,
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
                            readOnly: true,
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
                            readOnly: true,
                            decoration: fieldDecoration('watts'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'On Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15),
                          height: 50,
                          decoration: boxDecoration(),
                          child: FormBuilderDateTimePicker(
                            controller: onTimeController,
                            name: 'dateTime',
                            initialValue: null,
                            inputType: InputType.both,
                            format: DateFormat('yyyy-MM-dd HH:mm'),
                            decoration: InputDecoration(
                              labelText: 'Select Date/Time',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Off Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15),
                          height: 50,
                          decoration: boxDecoration(),
                          child: FormBuilderDateTimePicker(
                            name: 'dateTime',
                            controller: offTimeController,
                            initialValue: null,
                            inputType: InputType.both,
                            format: DateFormat('yyyy-MM-dd HH:mm'),
                            decoration: InputDecoration(
                              labelText: 'Select Date/Time',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                            ),
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
                                onPressed: () async {
                                  // Get the current date and time
                                  DateTime now = DateTime.now();
                                  // Set onTime and offTime (assuming you have these values)
                                  DateTime onTime = DateTime.parse(onTimeController
                                      .text); // Set your onTime DateTime value here
                                  DateTime offTime = DateTime.parse(
                                      offTimeController
                                          .text); // Set your offTime DateTime value here

                                  // Call addAppliance method
                                  await addAppliance(
                                    addedBy: _userName,
                                    id: userId,
                                    watts: double.parse(wattsController.text),
                                    onTime: onTime,
                                    offTime: offTime,
                                    type: typeController.text,
                                    brand: brandController.text,
                                  );
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

  Future<void> addAppliance({
    required String addedBy,
    required String id,
    required double watts,
    required DateTime onTime,
    required DateTime offTime,
    required String type,
    required String brand,
  }) async {
    try {
      // Convert DateTime objects to Timestamp
      Timestamp onTimeTimestamp = Timestamp.fromDate(onTime);
      Timestamp offTimeTimestamp = Timestamp.fromDate(offTime);

      final json = {
        'type': type,
        'id': id,
        'watts': watts,
        'onTime': onTimeTimestamp,
        'offTime': offTimeTimestamp,
        'addedBy': addedBy,
        'brand': brand,
      };
      await FirebaseFirestore.instance.collection('Activity').doc().set(json);
      // Clear the text fields after adding the data

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
    } catch (e) {
      print('Error adding appliances data: $e');
    }
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
