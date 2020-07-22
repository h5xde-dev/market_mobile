import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/pages/products/index.dart';
import 'package:g2r_market/services/favorite.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavoritePage extends StatefulWidget {
  
  final auth;
  final fromMain;

  FavoritePage({
    Key key,
    this.fromMain,
    this.auth
  }) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}


class _FavoritePageState extends State<FavoritePage> {

  bool _loaded = false;
  var _data;
      
  @override
  Widget build(BuildContext context) {

    final spinkit = Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SpinKitRing(color: Colors.blue[900], size: 175),
          SvgPicture.asset('resources/svg/main/spinner.svg', alignment: Alignment.center, width: 150),
        ],
      )
    );
    
    return (_loaded != false)
    ? __content(context, _data, null)
    : FutureBuilder(
      future: __getFavoritesInfo(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError || snapshot.data == 'NOT_AUTHORIZED')
              return SignInPage(fromMain: widget.fromMain,);
            else {
              return __content(context, snapshot.data, null);
            }
        }
      },
    );
  }

  __content(context, data, spinkit)
  {
    return Scaffold(
      bottomNavigationBar: (widget.fromMain) ? null :  BottomNavBar(),
      body: Stack(
        children: <Widget>[
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height:20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      (widget.fromMain == true)
                      ? SizedBox(width: 20)
                      : InkWell(
                          child: Icon(Icons.arrow_back_ios),
                          onTap: () => Navigator.pop(context, true),
                        ),
                      Text('Избранное', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 20)
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Text('Продукты'),
                          )
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Text('Запросы'),
                          )
                        )
                      ],
                    )
                  ),
                  Expanded(
                    child: ([null].contains(spinkit)) ? __getFavorites(data) : spinkit
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          ),
        ]
      ),
    );
  }

  __getFavorites(data)
  {
    return (data == null)
    ? Center()
    : RefreshIndicator(
      onRefresh: () => __updateFavoriteItems(),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int i){
          return Column(
            children: <Widget>[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () => {
                      Navigator.push(context, AnimatedScaleRoute(
                        builder: (context) => ProductPage(
                            productId: data[i]['id'],
                            auth: widget.auth,
                          )
                        )
                      )
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        image: DecorationImage(image: CachedNetworkImageProvider(data[i]['preview_image'], headers: {'Host': 'g2r-market.mobile'}), fit: BoxFit.fill)
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: 200,
                        child: Text(data[i]['name'], style: TextStyle(fontSize: 12), overflow: TextOverflow.clip, maxLines: 2)
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 200,
                        child: Text('${data[i]['price_min']}\$ - ${data[i]['price_max']}\$', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.clip, maxLines: 2,)
                      ),
                    ],
                  ),                
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(13)
                    ),
                    child: InkWell(
                      onTap: () => __updateFavorite(data[i], data),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (true) ? SvgPicture.asset('resources/svg/catalog/favorite-colored-active.svg') : SvgPicture.asset('resources/svg/catalog/favorite-colored.svg')
                      ),
                    )
                  ),
                ],
              ),
              Divider(),
            ],
          );
        }
      )
    );
  }

  Future __updateFavorite(product, data) async
  {
    var auth = await DBProvider.db.getAuth();

    if(auth != Null)
    {
      
      await Favorite.removeProduct(await auth, product['id']);

      data.removeWhere((item) => item['id'] == product['id']);

      setState((){
        _data = data;
        _loaded = true;
      });
    }
  }

  Future __getFavoritesInfo() async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return 'NOT_AUTHORIZED';
    }

    var userInfo = await Favorite.getProducts(auth);

    return userInfo;
  }

  __updateFavoriteItems()
  {
    setState(() {
      _loaded = false;
    });
  }
}