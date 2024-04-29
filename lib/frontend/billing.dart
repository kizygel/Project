import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  List<double> totalKWh = [];
  double total = 0.0;

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          // Calculate total kWh

                          // Calculate total kWh
                          List<String> applianceIds =
                              dataDocs.map((doc) => doc.id).toList();
                          String watts =
                              ''; // Example watts per hour, replace with actual value

                          return Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: 500,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Flexible(
                                      child: Column(
                                    children: [
                                      DataTable(
                                          columns: [
                                            DataColumn(label: Text('#')),
                                            DataColumn(label: Text('Type')),
                                            DataColumn(label: Text('Brand')),
                                            DataColumn(label: Text('per kWh')),
                                          ],
                                          rows: List.generate(
                                            dataDocs.length,
                                            (index) {
                                              DocumentSnapshot data =
                                                  dataDocs[index];
                                              Map<String, dynamic>
                                                  appliancesData = data.data()
                                                      as Map<String, dynamic>;
                                              String userId = data.id;
                                              watts = appliancesData['watts']
                                                  .toString();

                                              return DataRow(cells: [
                                                DataCell(Text('${index + 1}')),
                                                DataCell(Text(
                                                    '${appliancesData['type']}')),
                                                DataCell(Text(
                                                    '${appliancesData['brand']}')),
                                                DataCell(
                                                  FutureBuilder<String>(
                                                    future: getTotalWatts(
                                                        userId,
                                                        appliancesData['watts']
                                                            .toString()),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return CircularProgressIndicator();
                                                      } else {
                                                        if (snapshot.hasError) {
                                                          return Text('Error');
                                                        } else {
                                                          double? kWh = double
                                                              .tryParse(snapshot
                                                                      .data ??
                                                                  '0.0');
                                                          print('kwh ${kWh}');
                                                          total += kWh!;
                                                          totalKWh.add(total);
                                                          print(totalKWh);
                                                          return Text(kWh!
                                                              .toStringAsFixed(
                                                                  2));
                                                        }
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ]);
                                            },
                                          )),
                                      FutureBuilder<double>(
                                        future: getOverallTotalKWh(
                                            applianceIds, watts),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator();
                                          } else {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  'Error calculating total kWh');
                                            } else {
                                              double? overallTotalKWh =
                                                  snapshot.data;

                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text('Overall Total kWh'),
                                                  Text('${totalKWh.length}')
                                                ],
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  )),
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

  Future<String> getTotalWatts(String id, String watts) async {
    double totalkWh = 0.0;
    // Get documents from 'Activity' collection for the given appliance id
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Activity')
        .where('id', isEqualTo: id)
        .get();

    int totalHours = 0;
    querySnapshot.docs.forEach((doc) {
      // Parse 'offTime' and 'onTime' strings into DateTime objects
      DateTime offTime = DateTime.parse(doc['offTime']);
      DateTime onTime = DateTime.parse(doc['onTime']);

      // Calculate the difference in hours
      int hours = offTime.difference(onTime).inHours;

      // Add the hours to the total
      totalHours += hours;
    });

    // Convert total hours to kWh (assuming 12.05 kWh = 1 hour for simplicity)
    double kWh = ((totalHours.toDouble() * double.parse(watts)) / 1000) * 12.05;
    return kWh.toStringAsFixed(2); // Return kWh as a formatted string
  }

  Future<double> getOverallTotalKWh(
      List<String> applianceIds, String watts) async {
    double overallTotalKWh = 0.0;

    // Calculate total kWh for each appliance
    List<double> individualKWh = await Future.wait(applianceIds.map((id) async {
      String kWhString = await getTotalWatts(id, watts);
      print(kWhString);

      return double.parse(kWhString);
    }));

    // Sum up individual kWh values to get overall total kWh

    print(totalKWh);
    print(" indi -- ${individualKWh}");

    return individualKWh[0];
  }
}
