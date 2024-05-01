import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String _userName = 'Guest';

  List<_ChartData> _chartData = [];
  late List<_ChartData> data = [];
  List<_ChartData2> _chartData2 = [];
  late List<_ChartData2> data2 = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    _fetchChartData().then((chartData) {
      setState(() {
        data = chartData;
      });
    });
    _fetchChartData2().then((chartData2) {
      setState(() {
        data2 = chartData2;
      });
    });
    _tooltip = TooltipBehavior(enable: true);
    _fetchName();
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

  Future<List<_ChartData>> _fetchChartData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Appliances').get();

    List<_ChartData> chartData = snapshot.docs.map((doc) {
      return _ChartData(doc['type'], doc['watts'].toDouble());
    }).toList();

    // Sort the chartData list by watts in descending order
    chartData.sort((a, b) => b.y.compareTo(a.y));

    // Take only the top 5 items
    chartData = chartData.take(5).toList();

    print(chartData);
    return chartData;
  }

  Future<List<_ChartData2>> _fetchChartData2() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Activity').get();

    List<_ChartData2> chartData2 = snapshot.docs.map((doc) {
      Map<String, dynamic> appliancesData = doc.data() as Map<String, dynamic>;
      String type = appliancesData['type'];
      double hours = calculateTotalHours(
          appliancesData['onTime'], appliancesData['offTime']);
      double watts = double.parse(appliancesData['watts'].toString());
      double perKwh = ((watts * hours) / 1000) * 12.05; // Calculate per kWh

      return _ChartData2(type, perKwh);
    }).toList();

    // Sort the chartData list by per kWh in descending order
    chartData2.sort((a, b) => b.y.compareTo(a.y));

    // Take only the top 5 items
    chartData2 = chartData2.take(5).toList();

    print(chartData2);
    return chartData2;
  }

  double calculateTotalHours(Timestamp start, Timestamp end) {
    DateTime startTime = start.toDate();
    DateTime endTime = end.toDate();
    return endTime.difference(startTime).inHours.toDouble();
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
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appliances Chart',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'x - type, y - watts',
                          style: TextStyle(color: Colors.black54),
                        ),
                        SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: getMaxWatts(data),
                                interval: 250),
                            tooltipBehavior: _tooltip,
                            series: <CartesianSeries<_ChartData, String>>[
                              ColumnSeries<_ChartData, String>(
                                  dataSource: data ?? [],
                                  xValueMapper: (_ChartData data, _) => data.x,
                                  yValueMapper: (_ChartData data, _) => data.y,
                                  name: 'Appliances',
                                  color: Colors.purple.shade900)
                            ]),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Energy Consumption per Appliances',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'x - type, y - per kWh',
                          style: TextStyle(color: Colors.black54),
                        ),
                        SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: getMaxWatts2(data2),
                                interval:
                                    calculateInterval(getMaxWatts2(data2))),
                            tooltipBehavior: _tooltip,
                            series: <CartesianSeries<_ChartData2, String>>[
                              ColumnSeries<_ChartData2, String>(
                                  dataSource: data2 ?? [],
                                  xValueMapper: (_ChartData2 data2, _) =>
                                      data2.x,
                                  yValueMapper: (_ChartData2 data2, _) =>
                                      data2.y,
                                  name: 'Appliances',
                                  color: Colors.purple.shade900)
                            ]),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double calculateInterval(double maxValue) {
  if (maxValue <= 100) {
    return 20; // If the max value is less than or equal to 100, interval is 20
  } else if (maxValue <= 500) {
    return 100; // If the max value is less than or equal to 500, interval is 100
  } else if (maxValue <= 800) {
    return 160;
  } else if (maxValue <= 1000) {
    return 200;
  } else {
    return 1000; // Default interval
  }
}

double getMaxWatts(List<_ChartData> chartData) {
  if (chartData.isEmpty) {
    return 0.0; // Return 0 if the list is empty
  }
  return chartData
      .map((data) => data.y)
      .reduce((curr, next) => curr > next ? curr : next);
}

double getMaxWatts2(List<_ChartData2> chartData) {
  if (chartData.isEmpty) {
    return 0.0; // Return 0 if the list is empty
  }
  return chartData
      .map((data) => data.y)
      .reduce((curr, next) => curr > next ? curr : next);
}

class _ChartData {
  final String x;
  final double y;

  _ChartData(this.x, this.y);
}

class _ChartData2 {
  final String x;
  final double y;

  _ChartData2(this.x, this.y);
}
