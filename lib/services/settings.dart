import 'package:g2r_market/helpers/user.dart';
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
        'Host': API_HOST,
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
              'userId': data['id'],
              'name': data['name'],
              'avatar': avatar
          };
          
          if(data['roles'][0] != null)
          {

            List<String> roles = data['roles'].map<String>((role) {
              return role.toString();
            }).toList();

            await UserHelper.setRoles(roles);
          }

          if(data.containsKey('account'))
          {
            for( var acc in data['account'].values )
            {
              userMap.addEntries([MapEntry(acc['code'], acc['value'])]);
            }
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

   static Future<bool> changeAccountInfo(auth, name, lastName, patronymic, birthday, phone, avatar) async
  {

    bool result = false;

    final Map<String, String> body = {
      'name': name,
      'last_name': lastName,
      'patronymic': patronymic,
      'birthday': birthday,
      'phone': phone,
    };

    final request = http.MultipartRequest(
      "POST",
      Uri.parse(MarketApi.accountInfoUpdate),
    );

    request.headers.addAll({
      'Host': API_HOST,
      'Authorization': 'Bearer ${auth['token']}'
    });

    request.fields.addEntries(body.entries);

    if(avatar is !String)
    {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatar.path
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) 
    {
      await Settings.getAccountInfo(auth);
      result = true;
    }

    return result;
  }
}