import 'package:g2r_market/static/api_methods.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core';

import 'package:path/path.dart';

class Product {

  static Future<bool> create(auth, Map<String, dynamic> data, Map files, profileId) async
  {
    data.removeWhere((key, value) => value == "");

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
      "/api/mobile/create/product/$profileId",
      data: formData,
    );

    if(response.statusCode == 200)
    {
      result = true;
    }

    return result;
  }

  static Future<List> getCabinet(auth, type, profileId) async
  {
    List productList = [];

    final url = MarketApi.getProductCabinet + "/$profileId/?type=$type";

    final response = await http.Client().get(
      url,
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      var data = jsonDecode(response.body);

      if(data.length == 0)
      {
        return null;
      }

      for (var item in data['data'])
      {
        print(item);

        Map product = {
          'id': item['id'],
          'category': item['categories']['name'],
        };

        if(item.containsKey('downloads') != false)
        {
          for (var files in item['downloads'])
          {
            product.addEntries([MapEntry(files['type'], '$API_URL/storage/${files['path']}')]);
          }
        }

        if(item.containsKey('product_prices') != false)
        {
          for (var price in item['product_prices'])
          {
            product.addEntries([MapEntry(price['min'], price['max'])]);
          }
        }

        if(item.containsKey('product_models') != false)
        {
          for (var model in item['product_models'])
          {
            
          }
        }

        for (var property in item['product_properties'])
        {
          product.addEntries([MapEntry(property['code'], property['value'])]);
        }

        productList.add(product);
      }
    }

    return productList;
  }
}