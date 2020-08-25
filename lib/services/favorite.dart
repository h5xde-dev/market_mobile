import 'dart:convert';

import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:core';

class Favorite {

  static Future<List> getProducts(auth) async
  {

    List productCards = [];

    final response = await http.Client().get(
      MarketApi.favoriteProductGet,
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body);

      String avatar;

      if(data.length == 0)
      {
        return null;
      }

      for (var item in data['data'])
      {

        if(item.containsKey('downloads') != false)
        {
          avatar = '$API_URL/storage/${item['downloads'][0]['path']}';
        }
        
        Map product = {
          'id': item['id'],
          'shows': item['shows'],
          'price_min': item['product_prices'][0]['min'],
          'price_max': item['product_prices'][0]['max'],
          'min_order': item['characteristics']['min_order']['value'],
          'order_type': item['characteristics']['min_order']['type'],
          'preview_image': avatar,
        };

        for (var property in item['product_properties'])
        {
          product.addEntries([MapEntry(property['code'], property['value'])]);
        }

        for (var chars in item['characteristics'].entries)
        {
          product.addEntries([chars]);
        }

        productCards.add(product);
      }
    }

    return productCards;
  }

  static Future<bool> addProduct(auth, id) async
  {

    bool result = false;

    final response = await http.Client().get(
      '${MarketApi.favoriteProductAdd}?id=$id',
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 201)
    {
        result = true;
    }

    return result;
  }

  static Future<bool> removeProduct(auth, id) async
  {

    bool result = false;

    final response = await http.Client().get(
      '${MarketApi.favoriteProductRemove}?id=$id',
      headers: {
        'Host': API_HOST,
        'Authorization': 'Bearer ${auth['token']}'
      },
    );

    if(response.statusCode == 201)
    {
        result = true;
    }

    return result;
  }
}