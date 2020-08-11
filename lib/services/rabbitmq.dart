import "package:dart_amqp/dart_amqp.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:g2r_market/helpers/db.dart';
import 'dart:async';
import 'dart:core';
import 'dart:convert';

import 'package:g2r_market/services/settings.dart';

class Rabbitmq {

  static Future getDelivery() async
  {
    var auth = await DBProvider.db.getAuth();

    if(auth != Null)
    {

      if(await DBProvider.db.getAccountInfo() == Null)
      {
        await Settings.getAccountInfo(auth);
      }

      var account = await DBProvider.db.getAccountInfo();

      String hash = "${base64.encode(utf8.encode(account['name']))}${base64.encode(utf8.encode(account['user_id'].toString()))}";

      print(hash);

      Client client = new Client(
        settings: ConnectionSettings(
          host: '176.99.5.64',
          authProvider: AmqPlainAuthenticator('market_listener', 'xfc3z578neje85yq')
        )
      );

      client
      .channel() // auto-connect to localhost:5672 using guest credentials
      .then((Channel channel) => channel.queue("production-$hash", durable: true))
      .then((Queue queue) => queue.consume())
      .then((Consumer consumer) => consumer.listen((AmqpMessage message) async {

          Map messageBody = message.payloadAsJson;

          if(messageBody.containsKey('message') == true && messageBody.containsKey('from') == true)
          {
            await Rabbitmq()._showNotification(messageBody['message'], messageBody['from']);
          }

        })
      );
    }
  }

  Future<void> _showNotification(String text, String from) async {

    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    FlutterLocalNotificationsPlugin().initialize(initializationSettings);
    
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker'
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, from, text, platformChannelSpecifics,
        payload: 'item x');
  }
}