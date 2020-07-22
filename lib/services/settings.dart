import 'package:g2r_market/helpers/user_base.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:core';

class Settings {

  static Future<bool> getAccountInfo(auth) async
  {

    bool result = false;

    final response = await http.Client().get(
      MarketApi.accountInfo,
      headers: {
        'Host': 'g2r-market.mobile',
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body)['data'][0];

      var avatar = '';


        if(data.containsKey('avatar') != false)
        {
          avatar = API_URL + '/storage/' + data['avatar']['path'];
        }

        var userMap = {
            'name': data['name'],
            'avatar': avatar,
        };

        for( var acc in data['account'].values )
        {
          userMap.addEntries([MapEntry(acc['code'], acc['value'])]);
        }

        UserBase user = UserBase.fromMap(userMap);

        var accountCreated = await DBProvider.db.getAccountInfo();

        if(accountCreated != Null)
        {
          await DBProvider.db.updateAccountInfo(user);
          
        } else
        {
          await DBProvider.db.newAccountInfo(user);
        }

        result = true;
    }

    return result;

  }
}