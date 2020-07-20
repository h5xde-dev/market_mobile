import 'dart:convert';

import 'package:g2r_market/static/api_methods.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:core';

class Catalog {

  static Future<List> getProducts(int category,int page) async
  {    
    List productCards = [];

    final response = await http.Client().get(
      MarketApi.getProducts + '?category=$category&page=$page',
      headers: {
        'Host': 'g2r-market.mobile'
      }
    );

    if(response.statusCode == 200)
    {

      String avatar;

      Map data = jsonDecode(response.body);

      if(data.length == 0)
      {
        return null;
      }

      for (var item in data['data'])
      {

        if(item.containsKey('downloads') != false)
        {
          avatar = API_URL + '/storage/' + item['downloads'][0]['path'];
        }
        
        Map product = {
          'id': item['id'],
          'shows': item['shows'],
          'title': item['product_properties'][0]['value'],
          'price_min': item['product_prices'][0]['min'],
          'price_max': item['product_prices'][0]['max'],
          'min_order': item['characteristics']['min_order']['value'],
          'order_type': item['characteristics']['min_order']['type'],
          'preview_image': avatar
        };

        productCards.add(product);
      }
    }

    return productCards;

  }

  static Future<List> getProduct(int productId) async
  {    
    List productCards = [];

    final response = await http.Client().get(
      MarketApi.getProduct + '?id=$productId',
      headers: {
        'Host': 'g2r-market.mobile'
      }
    );

    if(response.statusCode == 200)
    {

      String avatar;
      List detailImages = [];
      List describleImages = [];

      Map data = jsonDecode(response.body);

      if(data.length == 0)
      {
        return null;
      }

      var item = data['data'];

        if(item.containsKey('downloads') != false)
        {
          avatar = '$API_URL/storage/${item['downloads']['preview_image'][0]['path']}';

          if(item['downloads'].containsKey('detail_images') != false)
          {
            for (var detailImage in item['downloads']['detail_images'])
            {
              detailImages.add('$API_URL/storage/${detailImage['path']}');
            }
          }

          if(item['downloads'].containsKey('describle_images') != false)
          {
            for (var describleImage in item['downloads']['describle_images'])
            {
              describleImages.add('$API_URL/storage/${describleImage['path']}');
            }
          }
        }
        
        Map product = {
          'id': item['id'],
          'shows': item['shows'],
          'price_min': item['product_prices'][0]['min'],
          'price_max': item['product_prices'][0]['max'],
          'min_order': item['characteristics']['min_order']['value'],
          'order_type': item['characteristics']['min_order']['type'],
          'preview_image': avatar,
          'describle_images': describleImages,
          'detail_images': detailImages
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

    return productCards;

  }
}