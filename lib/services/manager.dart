import 'dart:convert';
import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:core';

class Manager {

  static Future<List> getCompanies(auth) async
  {
    List companyList = [];

    final response = await http.Client().get(
      MarketApi.getCompanies,
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      List data = jsonDecode(response.body);

      if(data.length == 0)
      {
        return null;
      }

      for (var item in data)
      {
        companyList.add(item);
      }
      
    }

    return companyList;
  }

  static Future<List> getProfiles(auth, type, companyId) async
  {
    List profileList = [];

    final response = await http.Client().get(
      MarketApi.getCompanyProfiles + "?user=$companyId&type=$type",
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body);

      if(data.length == 0)
      {
        return null;
      }

      for (var item in data['data'])
      {        

        var localisation;

        switch (item['profile_properties'][0]['localisation_id']) {
          case 1:
            localisation = 'ru';
            break;
          case 2:
            localisation = 'en';
            break;
          default:
            localisation = 'zh';
            break;
        }

        Map profile = {
          'id': item['id'],
          'type': item['profile_type_id'],
          'status': item['status'],
          'localisation': localisation
        };

        if(item.containsKey('downloads') != false)
        {
          for (var files in item['downloads'])
          {
            profile.addEntries([MapEntry(files['type'], '$API_URL/storage/${files['path']}')]);
          }
        }

        for (var property in item['profile_properties'])
        {
          profile.addEntries([MapEntry(property['code'], property['value'])]);
        }

        profileList.add(profile);
      }
    }

    return profileList;
  }

  static Future<bool> createCompany(auth, Map<String, String> data) async
  {
    bool result = false;

    final response = await http.Client().post(
      MarketApi.createCompany,
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },

      body: data
    );

    if(response.statusCode == 200)
    {
      List data = jsonDecode(response.body);

      if(data.length == 0)
      {
        result = false;
      }
      
      result = true;
    }

    return result;
  }

  static Future<bool> approve(auth, int profileId) async
  {
    bool result = false;

    final response = await http.Client().get(
      MarketApi.approveCompanyProfile + profileId.toString(),
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      }
    );

    if(response.statusCode == 200)
    {      
      result = true;
    }

    return result;
  }
}