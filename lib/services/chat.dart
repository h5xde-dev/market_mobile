import 'dart:convert';

import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:core';

class Chat {

  static Future<Map> getInfo(auth, profile) async
  {

    Map result = {};

    String url = MarketApi.getChats;

    if(profile != null)
    {
      url = "$url?profile=$profile";
    }

    final response = await http.Client().get(
      url,
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body);

      result = data;
    }

    return result;
  }

  static Future<List> getMessagesSupport(auth, int chatId, int page) async
  {

    List result = [];

    String url = MarketApi.getMessagesSupport;

    final response = await http.Client().get(
      "$url$chatId?page=$page",
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      List data = jsonDecode(response.body);

      result = data.reversed.toList();
    }

    return result;
  }

  static Future<List> getMessages(auth, int chatId, int profileId, int page) async
  {

    List result = [];

    String url = MarketApi.getMessages;

    final response = await http.Client().get(
      "$url$chatId?profile=$profileId&page=$page",
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      List data = jsonDecode(response.body);

      result = data.reversed.toList();
    }

    return result;
  }

  static Future<bool> sendSupport(auth, int chatId, String message) async
  {

    bool result = false;

    String url = MarketApi.sendSupport;

    final response = await http.Client().post(
      "$url$chatId",
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
      body: {
        'message_text': message
      }
    );

    if(response.statusCode == 200)
    {
      result = true;
    }

    return result;
  }

  static Future<bool> sendProfile(auth, int chatId, int profileId, int toProfile, String message) async
  {

    bool result = false;

    String url = MarketApi.sendProfile;

    final response = await http.Client().post(
      "$url$chatId?profile=$profileId&to_profile=$toProfile",
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
      body: {
        'message_text': message
      }
    );

    if(response.statusCode == 200)
    {
      result = true;
    }

    return result;
  }
}