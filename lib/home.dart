import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_notifications/notification_badge.dart';
import 'package:firebase_notifications/push_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// initiallize firebase messaging
  late final FirebaseMessaging _messaging;

  ///notification counter
  late int _notificationCounter;

  ///model
  PushNotification? _pushNotification;

  void registerNotification() async {
    _messaging = FirebaseMessaging.instance;

    ///notification setting
    NotificationSettings settings = await _messaging.requestPermission(
        alert: true, badge: true, provisional: false, sound: true);

    ///check for if notifications are authorized,
    ///Note: in android it is enabled by default
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted the permission');

      /// main message to be sent
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            dataTitle: message.data['title'],
            dataBody: message.data['body']);
        setState(() {
          ///increase the counter value and saving by calling inside setState method
          _notificationCounter++;

          ///asigning the local model instance to globally declared model instance
          _pushNotification = notification;
        });

        if (notification != null) {
          showSimpleNotification(Text(_pushNotification!.title!),
              leading:
                  NotificationBadge(totalNotifications: _notificationCounter),
              subtitle: Text(_pushNotification!.body!),
              background: Colors.cyan.shade700,
              duration: Duration(seconds: 3));
        }
      });
    } else {
      print('User declined the permission');
    }
  }
  checkForInitialMessage()async{
    await Firebase.initializeApp();
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null){
      PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body']);
      setState(() {
        ///increase the counter value and saving by calling inside setState method
        _notificationCounter++;

        ///asigning the local model instance to globally declared model instance
        _pushNotification = notification;
      });
    }

  }

  @override
  void initState() {

    /// when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body']);
      setState(() {
        ///increase the counter value and saving by calling inside setState method
        _notificationCounter++;

        ///asigning the local model instance to globally declared model instance
        _pushNotification = notification;
      });
    });
    /// when app is in foreground state
    registerNotification();
    /// when app is in terminated state
    checkForInitialMessage();
    super.initState();

    ///initiallized notificationCounter to 0
    _notificationCounter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Flutter Push Notification',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black)),
            const SizedBox(height: 20),
            NotificationBadge(totalNotifications: _notificationCounter),
            _pushNotification != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          'Title: ${_pushNotification!.dataTitle ?? _pushNotification!.title}'),
                      const SizedBox(height: 20),
                      Text(
                          'Body: ${_pushNotification!.dataBody ?? _pushNotification!.body}'),
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
