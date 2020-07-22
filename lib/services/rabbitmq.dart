import "package:dart_amqp/dart_amqp.dart";
import 'package:g2r_market/helpers/db.dart';
import 'dart:async';
import 'dart:core';

class Settings {

  static Future getDelivery() async
  {
    if(DBProvider.db.getAuth() != Null)
    {
      Client client = new Client(
        settings: ConnectionSettings(
          host: 'g2r-market.mobile',
          authProvider: AmqPlainAuthenticator('market_listener', 'xfc3z578neje85yq')
        )
      );

      client
      .channel() // auto-connect to localhost:5672 using guest credentials
      .then((Channel channel) => channel.queue("production-MQ=="))
      .then((Queue queue) => queue.consume())
      .then((Consumer consumer) => consumer.listen((AmqpMessage message) {
          // Get the payload as a string
          print(" [x] Received string: ${message.payloadAsString}");

          // Or unserialize to json
          print(" [x] Received json: ${message.payloadAsJson}");

          // Or just get the raw data as a Uint8List
          print(" [x] Received raw: ${message.payload}");
          
          // The message object contains helper methods for 
          // replying, ack-ing and rejecting
          message.reply("world");
        })
      );
    }
  }
}