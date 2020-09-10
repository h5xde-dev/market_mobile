import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/cabinet/product/create.dart';
import 'package:g2r_market/services/product.dart';
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
  String _selectedType = 'active';
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
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_selectedType == 'active') ? Colors.black54 : Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Text('Активные'),
                          ),
                          onTap: (){
                            setState(() {
                              _selectedType = 'active';
                              _loaded = false;
                            });
                          },
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_selectedType == 'inactive') ? Colors.black54 : Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Text('Неактивные'),
                          ),
                          onTap: (){
                            setState(() {
                              _selectedType = 'inactive';
                              _loaded = false;
                            });
                          },
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_selectedType == 'deleted') ? Colors.black54 : Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Text('Удалённые'),
                          ),
                          onTap: (){
                            setState(() {
                              _selectedType = 'deleted';
                              _loaded = false;
                            });
                          },
                        )
                      ],
                    )
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
                        image: DecorationImage(image: (data[i].containsKey('preview_image'))
                        ? CachedNetworkImageProvider(data[i]['preview_image'], headers: {'Host': API_HOST})
                        : AssetImage('resources/images/default_profile_image.png'), fit: BoxFit.fill)
                      ),
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
                          child: Row(
                            children: [
                              /* Text(data[i]['min_price']) */
                            ],
                          )
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
    var products = Product.getCabinet(widget.auth, _selectedType, widget.profileId);

    return products;
  }

  __updateProducts()
  {
    setState(() {
      _loaded = false;
    });
  }
}