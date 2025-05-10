import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

import 'reactive_subject_drawer.dart';

class NotificationMerger extends StatefulWidget {
  static const String route = '/notification_merger';

  const NotificationMerger({super.key});

  @override
  NotificationMergerState createState() => NotificationMergerState();
}

class NotificationMergerState extends State<NotificationMerger> {
  final ReactiveSubject<String> _emailNotifications = ReactiveSubject<String>();
  final ReactiveSubject<String> _pushNotifications = ReactiveSubject<String>();
  late ReactiveSubject<String> _allNotifications;

  @override
  void initState() {
    super.initState();
    // Merge email and push notifications
    _allNotifications = ReactiveSubject.merge<String>([
      _emailNotifications,
      _pushNotifications,
    ]);
  }

  @override
  void dispose() {
    _emailNotifications.dispose();
    _pushNotifications.dispose();
    _allNotifications.dispose();
    super.dispose();
  }

  void _simulateEmailNotification() {
    _emailNotifications.add('New email received');
  }

  void _simulatePushNotification() {
    _pushNotifications.add('New push notification');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReactiveSubjectDrawer(NotificationMerger.route),
      appBar: AppBar(title: Text("Notification Merger")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _simulateEmailNotification,
            child: Text('Simulate Email Notification'),
          ),
          ElevatedButton(
            onPressed: _simulatePushNotification,
            child: Text('Simulate Push Notification'),
          ),
          Expanded(
            child: StreamBuilder<String>(
              stream: _allNotifications.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Notification: ${snapshot.data}');
                } else {
                  return Text('No notifications');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
