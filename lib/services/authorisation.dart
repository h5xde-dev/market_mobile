import 'package:g2r_market/helpers/auth_base.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:core';

class Auth {

  static Future<bool> login(String email, String password) async
  {

    bool result = false;

    final response = await http.Client().post(
      MarketApi.authUrl,
      headers: {
        'Host': 'g2r-market.mobile'
      },
      body: {
        'grant_type': 'password',
        'client_id': CLIENT_ID,
        'client_secret': CLIENT_SECRET,
        'username': email,
        'password': password,
        'scope': ''
      }
    );

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body);

      AuthBase auth = AuthBase.fromMap({
        'token': data['access_token']
      });

      DBProvider.db.newAuth(auth);

      result = true;
    }

    return result;

  }
}