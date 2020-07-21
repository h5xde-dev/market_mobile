import 'dart:convert';

import 'package:g2r_market/static/api_methods.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:core';

class Category {

  static Future<List> getPopular() async
  {
    List mainCategoryCards = [];

    

    final response = await http.Client().get(
      MarketApi.mainUrl,
      headers: {
        'Host': 'g2r-market.mobile'
      }
    );

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body);

      for (var item in data['data'])
      {
        Map category = {
          'id': item['id'],
          'title': item['title'],
          'banner': API_URL + "/assemble" + item['banner'],
          'children': item['children']
        };

        mainCategoryCards.add(category);
      }
    }

    return mainCategoryCards;

  }

  static Future<List> getAll() async
  {
    final response = await http.Client().get(
      MarketApi.fullCatalog,
      headers: {
        'Host': 'g2r-market.mobile'
      }
    );

    List categories;

    if(response.statusCode == 200)
    {
      Map data = jsonDecode(response.body);

      categories = data['data'][0]['children'];
    }

    return categories;

  }
}