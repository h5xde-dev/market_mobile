import 'dart:convert';
import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import 'dart:core';

import 'package:path/path.dart';

class Profile {

  static Future<List> getProfiles(auth, type) async
  {
    List profileList = [];

    final response = await http.Client().get(
      (type == 'buyer') ? MarketApi.getBuyers : MarketApi.getSellers,
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

  static Future<Map> getProfileInfo(auth, int profileId, String type) async
  {
    Map profile = {};

    final response = await http.Client().get(
      MarketApi.getProfileInfo + '/$profileId',
      headers: 
      {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      }
    );

    if(response.statusCode == 200)
    {
      List companyMainBannerImages = [];
      List companyPromoImages = [];

      String companyLogo;

      Map data = jsonDecode(response.body);

      if(data.length == 0)
      {
        return null;
      }

      var item = data['data'];

      if(type == 'seller')
      {
        if(item.containsKey('downloads') != false)
        {
          if(item['downloads'].isNotEmpty && item['downloads'].containsKey('company_main_banner_images') != false)
          {
            for (var mainBanner in item['downloads']['company_main_banner_images'])
            {
              companyMainBannerImages.add('$API_URL/storage/${mainBanner['path']}');
            }
          }

          if(item['downloads'].isNotEmpty != 0 && item['downloads'].containsKey('company_promo_banner_images') != false)
          {
            for (var companyPromo in item['downloads']['company_promo_banner_images'])
            {
              companyPromoImages.add('$API_URL/storage/${companyPromo['path']}');
            }
          }

          if(item['downloads'].isNotEmpty != 0 && item['downloads'].containsKey('company_logo_image') != false)
          {
            companyLogo = '$API_URL/storage/${item['downloads']['company_logo_image'][0]['path']}';
          }
        }
      }

      var localisation;

      switch (item['profile_properties']['company_name']['localisation_id']) {
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
      
      profile = {
        'id': item['id'],
        'company_logo': companyLogo,
        'company_promo': companyPromoImages,
        'main_banner': companyMainBannerImages,
        'localisation': localisation
      };

      for (var property in item['profile_properties'].values)
      {
        profile.addEntries([MapEntry(property['code'], property['value'])]);
      }

      for (var chars in item['characteristics'].entries)
      {
        profile.addEntries([chars]);
      }
    }

    return profile;

  }

  static Future<bool> create(auth, Map<String, String> data, Map files) async
  {
    bool result = false;

    var dioRequest = dio.Dio();
    dioRequest.options.baseUrl = API_URL;

    dioRequest.options.headers = {
      'Host': API_HOST,
      'Authorization': 'Bearer ${auth['token']}',
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    dio.FormData formData = new dio.FormData.fromMap(data);

    if(files.isNotEmpty)
    {
      for (var file in files.entries)
      {
        if(file.value is String)
        {
          var formFile = await dio.MultipartFile.fromFile(file.value,
            filename: basename(file.value),
            contentType: MediaType("image", extension(file.value)));

          formData.files.add(MapEntry(file.key, formFile));
        }

        if(file.value is List)
        {
          int index = 0;

          for (var fileMultiple in file.value) {
            var formFile = await dio.MultipartFile.fromFile(fileMultiple,
              filename: basename(fileMultiple),
              contentType: MediaType("image", extension(fileMultiple)));

              String fileKey = "${file.key}[$index]";

              index = index+1;

            formData.files.add(MapEntry(fileKey, formFile));
          }
        }
      }
    }

    var response = await dioRequest.post(
      "/api/mobile/create/profile",
      data: formData,
    );

    if(response.statusCode == 200)
    {
      result = true;
    }

    return result;
  }
}