import 'dart:convert';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/static/api_methods.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:core';

class Catalog {

  static Future<List> getProducts(int category,int page) async
  {    
    List productCards = [];

    var auth = await DBProvider.db.getAuth(1);

    final response = await http.Client().get(
      MarketApi.getProducts + '?category=$category&page=$page',
      headers: (auth != Null)
      ? {
          'Host': 'g2r-market.mobile',
          'Authorization': 'Bearer ${auth['token']}'
        }
      : {
          'Host': 'g2r-market.mobile',
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
          'favorite': (auth != Null && item['favorites'].isEmpty == false) ? true : false,
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

    var auth = await DBProvider.db.getAuth(1);

    final response = await http.Client().get(
      MarketApi.getProduct + '?id=$productId',
      headers: (auth != Null)
      ? {
          'Host': 'g2r-market.mobile',
          'Authorization': 'Bearer ${auth['token']}'
        }
      : {
          'Host': 'g2r-market.mobile',
        }
    );

    if(response.statusCode == 200)
    {

      String avatar;
      List detailImages = [];
      List describleImages = [];

      List productModels = [];

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

        if(item.containsKey('product_models') != false)
        {
          for (var productModel in item['product_models'])
          {
            var modelAvatar;

            if(productModel.containsKey('downloads') != false)
            {
              modelAvatar = '$API_URL/storage/${productModel['downloads'][0]['path']}';
            }

            Map model = {
              'id': productModel['id'],
              'price_min': productModel['product_prices'][0]['min'],
              'price_max': productModel['product_prices'][0]['max'],
              'preview_image': modelAvatar,
            };

            for (var chars in productModel['characteristics'].entries)
            {
              model.addEntries([chars]);
            }

            productModels.add(model);
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
          'detail_images': detailImages,
          'product_models': productModels,
          'favorite': (auth != Null && item['favorites'].isEmpty == false) ? true : false,
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