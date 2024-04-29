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
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    _fetchChartData().then((chartData) {
      setState(() {
        data = chartData;
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

    print(chartData);
    return chartData;
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
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

class _ChartData {
  final String x;
  final double y;

  _ChartData(this.x, this.y);
}
