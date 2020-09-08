import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/cabinet/product/create.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:g2r_market/static/api_methods.dart';

class ProductListPage extends StatefulWidget {
  
  final auth;
  final profileId;

  ProductListPage({
    Key key,
    @required this.auth,
    @required this.profileId
  }) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}


class _ProductListPageState extends State<ProductListPage> {

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
      future: __getProductsList(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError || snapshot.data == null)
              return __content(context, null, null);
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
      bottomNavigationBar: BottomNavBar(),
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
                      InkWell(
                        child: Icon(Icons.arrow_back_ios),
                        onTap: () => Navigator.pop(context, true),
                      ),
                      Text('Товары', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 20)
                    ],
                  ),
                  Expanded(
                    child: ([null].contains(spinkit)) ? __getProfiles(data) : spinkit
                  ),
                  CustomRaisedButton(
                    color: Colors.deepPurple[700],
                    child: Text('Создать товар', style: TextStyle(color: Colors.white)),
                    onPressed: () => {
                      Navigator.push(context, AnimatedSizeRoute(
                          builder: (context) => ProductCreatePage(profileId: widget.profileId, auth: widget.auth)
                        )
                      )
                    },
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

  __getProfiles(data)
  {
    return (data == null)
    ? Center()
    : RefreshIndicator(
      onRefresh: () => __updateProducts(),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int i) {

          return Column(
            children: <Widget>[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () => {
                      
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        image: DecorationImage(image: CachedNetworkImageProvider(data[i]['preview_image'], headers: {'Host': API_HOST}), fit: BoxFit.fill)
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            color:Colors.white,
                            image: DecorationImage(image: AssetImage('icons/flags/png/${(data[i]['localisation'].toString().toLowerCase() != 'zh') ? data[i]['localisation'].toString().toLowerCase() : 'cn'}.png', package: 'country_icons'), fit: BoxFit.fill),
                            borderRadius: BorderRadius.circular(13)
                          ),
                        ),
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(data[i]['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.clip, maxLines: 2)
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 200,
                          child: Text(data[i]['description'], style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2,)
                        )
                      ],
                    ),
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

  Future __getProductsList() async
  {
    var products;

    return products;
  }

  __updateProducts()
  {
    setState(() {
      _loaded = false;
    });
  }
}