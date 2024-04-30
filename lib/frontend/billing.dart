import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({Key? key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
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
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(3.0),
                            minimumSize: const Size(150, 40),
                            maximumSize: const Size(150, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final initialDateRange = dateRange ??
                                DateTimeRange(
                                    start: DateTime.now(), end: DateTime.now());
                            final newDateRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2025),
                              initialDateRange: initialDateRange,
                            );
                            if (newDateRange == null) return;
                            setState(() {
                              dateRange = newDateRange;
                              startDate = dateRange!.start;
                              endDate = dateRange!.end;
                            });
                          },
                          child: Text(
                            'Select Date Range',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      if (dateRange != null)
                        Text(
                          '${DateFormat('yyyy-MM-dd').format(dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(dateRange!.end)}',
                          style: TextStyle(color: Colors.white),
                        ),
                    ],
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

                            bool isAfterStartDate = dateRange?.start == null ||
                                (timeIn != null && timeIn.isAfter(startDate!));
                            bool isBeforeEndDate = endDate == null ||
                                (timeIn != null &&
                                    timeIn.isBefore(
                                        endDate!.add(Duration(days: 1))));

                            return isAfterStartDate && isBeforeEndDate;
                          }).toList();

                          // Calculate total overtime pay for the current user
                          double totalOvertimePay = 0;
                          double hours = 0;

                          for (var appliancesData in filteredDocs) {
                            hours = calculateTotalHours(
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

                          return Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        DataTable(
                                          columns: [
                                            DataColumn(
                                              label: Text(
                                                '#',
                                                style: textStyle(),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Type',
                                                style: textStyle(),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'Brand',
                                                style: textStyle(),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'watts',
                                                style: textStyle(),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                'per kWh',
                                                style: textStyle(),
                                              ),
                                            ),
                                          ],
                                          rows: List.generate(
                                            filteredDocs.length,
                                            (index) {
                                              DocumentSnapshot data =
                                                  dataDocs[index];
                                              Map<String, dynamic>
                                                  appliancesData = data.data()
                                                      as Map<String, dynamic>;
                                              String userId = data.id;
                                              String watts =
                                                  appliancesData['watts']
                                                      .toString();

                                              double hours =
                                                  calculateTotalHours(
                                                      appliancesData['onTime'],
                                                      appliancesData[
                                                          'offTime']);

                                              double perKwh =
                                                  ((double.parse(watts) *
                                                          hours /
                                                          1000) *
                                                      12.05);

                                              return DataRow(cells: [
                                                DataCell(Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                )),
                                                DataCell(Text(
                                                  '${appliancesData['type']}',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                )),
                                                DataCell(Text(
                                                  '${appliancesData['brand']}',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                )),
                                                DataCell(Text(
                                                  '${double.parse(watts).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                )),
                                                DataCell(Text(
                                                    '${perKwh.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ))),
                                              ]);
                                            },
                                          ),
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(15),
                                              child: Text(
                                                'Total per kWh: ${totalOvertimePay.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

  double calculateTotalHours(Timestamp start, Timestamp end) {
    DateTime startTime = start.toDate();
    DateTime endTime = end.toDate();
    return endTime.difference(startTime).inHours.toDouble();
  }

  TextStyle textStyle() {
    return TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
  }
}
