import 'package:g2r_market/static/api_methods.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:core';

class Favorite {

  static Future<bool> addProduct(auth, id) async
  {

    bool result = false;

    final response = await http.Client().get(
      '${MarketApi.favoriteProductAdd}?id=$id',
      headers: {
        'Host': 'g2r-market.mobile',
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
        'Host': 'g2r-market.mobile',
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