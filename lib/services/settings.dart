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

        var acc = data['account'][0];

        var account = {
          'last_name': acc['last_name'],
          'patronymic': acc['patronymic'],
          'birthday': acc['birthday'],
          'phone': acc['phone']
        };

        if(data.containsKey('avatar') != false)
        {
          avatar = API_URL + '/storage/' + data['avatar']['path'];
        }

        UserBase user = UserBase.fromMap({
            'name': data['name'],
            'last_name': account['last_name'],
            'patronymic': account['patronymic'],
            'birthday': account['birthday'],
            'phone': account['phone'],
            'avatar': avatar,
        });

        var test = await DBProvider.db.getAccountInfo(1);

        if(test != Null)
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