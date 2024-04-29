import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.amber.shade900,
        child: Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(height: 1000, child: Text('Notification'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
