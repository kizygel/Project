import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late int setHours = 0;
  late int setWatts = 0;
  bool isLoading = true;

  List<double> totalKWh = [];
  double total = 0.0;
  DateTimeRange? dateRange;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  double overallTotalPerKwh = 0.0;
  StreamSubscription<DocumentSnapshot>? _subscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchThresholdHours();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> fetchThresholdHours() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('Threshold').get();

      if (docSnapshot.docs.isNotEmpty) {
        final data = docSnapshot.docs.first.data();
        final hours = data['hours'] as int;
        final watts = data['watts']; // Assuming 'hours' is stored as an int
        setState(() {
          setHours = hours;
          setWatts = watts;
          isLoading = false;
        });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber.shade900,
        height: 1000,
        child: Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Notification',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Activity')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.data!.docs.isEmpty) {
                              return Center(
                                  child: Text('No data available yet'));
                            } else {
                              List<DocumentSnapshot> dataDocs =
                                  snapshot.data!.docs;
                              // Filter data by date range if selected

                              List<DocumentSnapshot> filteredDocs =
                                  dataDocs.where((document) {
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                Timestamp onTime = data['onTime'];
                                Timestamp offTime = data['offTime'];
                                DateTime now = DateTime.now();

                                // Check if the current date is within the range of onTime and offTime
                                bool isWithinRange =
                                    now.isAfter(onTime.toDate()) &&
                                        now.isBefore(offTime.toDate());

                                // Check if watts exceed 300
                                bool isWattsExceed300 =
                                    data['watts'] >= setWatts;
                                print(
                                    'sethours ${setHours} setwatts ${setWatts}');

                                double hours =
                                    calculateTotalHours(onTime, offTime);
                                print(hours);

                                // Return true only if both conditions are met
                                return isWattsExceed300 && hours >= setHours;
                              }).toList();

                              // Calculate total overtime pay for the current user
                              double totalOvertimePay = 0;

                              for (var appliancesData in filteredDocs) {
                                double hours = calculateTotalHours(
                                    appliancesData['onTime'],
                                    appliancesData['offTime']);
                                double watts = double.parse(
                                    appliancesData['watts'].toString());
                                if (appliancesData['watts'] != null) {
                                  totalOvertimePay +=
                                      ((watts * hours / 1000) * 12.05);
                                }
                              }
                              overallTotalPerKwh =
                                  filteredDocs.fold<double>(0.0, (sum, doc) {
                                Map<String, dynamic> appliancesData =
                                    doc.data() as Map<String, dynamic>;
                                double hours = calculateTotalHours(
                                    appliancesData['onTime'],
                                    appliancesData['offTime']);
                                double watts = double.parse(
                                    appliancesData['watts'].toString());
                                return sum +
                                    ((watts * hours / 1000) *
                                        12.05); // Adjust rate as needed
                              });

                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredDocs.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot data = filteredDocs[index];
                                  Map<String, dynamic> appliancesData =
                                      data.data() as Map<String, dynamic>;
                                  String userId = data.id;
                                  String watts =
                                      appliancesData['watts'].toString();

                                  double hours = calculateTotalHours(
                                      appliancesData['onTime'],
                                      appliancesData['offTime']);

                                  double perKwh =
                                      ((double.parse(watts) * hours / 1000) *
                                          12.05);

                                  return Card(
                                    color: Colors.white,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.notifications,
                                            size: 30,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Flexible(
                                            child: Text.rich(
                                              TextSpan(
                                                text:
                                                    "We've noticed a significant increase in your energy consumption, likely due to the ",
                                                style: TextStyle(
                                                    color: Colors.black),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        "${appliancesData['type']}",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ". Taking immediate action is crucial to manage escalating utility expenses.",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
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

  double calculateTotalHours(Timestamp start, Timestamp end) {
    DateTime startTime = start.toDate();
    DateTime endTime = end.toDate();
    return endTime.difference(startTime).inHours.toDouble();
  }

  TextStyle textStyle() {
    return TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  }
}
