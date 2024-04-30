import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<double> totalKWh = [];
  double total = 0.0;
  DateTimeRange? dateRange;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  double overallTotalPerKwh = 0.0;

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Notification',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Activity')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No data available yet'));
                        } else {
                          List<DocumentSnapshot> dataDocs = snapshot.data!.docs;
                          // Filter data by date range if selected

                          List<String> applianceIds =
                              dataDocs.map((doc) => doc.id).toList();

                          List<DocumentSnapshot> filteredDocs =
                              dataDocs.where((document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;

                            DateTime? timeIn =
                                (data['onTime'] as Timestamp?)?.toDate();

                            bool isWattsLessThan100 = data['watts'] > 100;

                            return isWattsLessThan100;
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
                              String watts = appliancesData['watts'].toString();

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
                                        child: Text(
                                            "We've noticed a significant increase in your energy consumption, likely due to the ${appliancesData['type']}. Taking immediate action is crucial to manage escalating utility expenses."),
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
