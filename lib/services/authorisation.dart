import 'dart:io' show Platform;
import 'package:g2r_market/helpers/auth_base.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:core';

class Auth {

  static Future<bool>login(String email, String password) async
  {

    bool result = false;

    final response = await http.Client().post(
      MarketApi.authUrl,
      headers: {
        'Host': API_HOST
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

  static Future<List>register(String name, String email, String password) async
  {

    List errors = [];

    final response = await http.Client().post(
      MarketApi.registerUrl,
      headers: {
        'Host': API_HOST
      },
      body: {
        'email': email,
        'name': name,
        'password': password,
        'app': (Platform.isAndroid) ? 'android' : 'ios'
      }
    );

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body);

      for( var error in data['original'] )
      {
        errors.add(error);
      }

    }

    if(errors.length == 0)
    {
      await Auth.login(email, password);
    }

    return errors;

  }
}