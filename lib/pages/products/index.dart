import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/extesions/color.dart';
import 'package:g2r_market/services/favorite.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:g2r_market/services/catalog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/widgets/youtube_frame.dart';

// ignore: must_be_immutable
class ProductPage extends StatefulWidget {

  final int productId;
  final auth;
  bool favorite;

  ProductPage({
    Key key,
    this.productId,
    this.auth
  }) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}


class _ProductPageState extends State<ProductPage> {

  CarouselController buttonCarouselController = CarouselController();

  bool _loaded = false;
  var _data;
  var _selectedModel;
      
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
      future: __getContent(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError)
              return __content(context, null, spinkit);
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
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(247,247,247, 100)
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height:20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Icon(Icons.arrow_back_ios),
                        onTap:  () => Navigator.pop(context),
                      ),
                      Center()                
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    child: Center()
                  ),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        ([null].contains(spinkit)) ? __productInfo(data) : spinkit
                      ],
                    ),
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

  __productInfo(data)
  {

    var images = [data[0]['preview_image']];

    for (var item in data[0]['describle_images'])
    {
      images.add(item);
    }

    for (var item in data[0]['detail_images'])
    {
      images.add(item);
    }

    if(_selectedModel != null)
    {
      images = [];

      images.add(_selectedModel['preview_image']);
    }

    widget.favorite = data[0]['favorite'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                enlargeCenterPage: true,
                aspectRatio: 4/3,
                viewportFraction: 0.9,
                carouselController: buttonCarouselController,
                initialPage: images.lastIndexOf(images.last)
              ),
              items: images.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: CachedNetworkImage(imageUrl: i, httpHeaders: {'Host': 'g2r-market.mobile'}, fit: BoxFit.fill,),
                    );
                  },
                );
              }).toList(),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 300,
                  child: Text(data[0]['name'], style: TextStyle(fontSize: 22), overflow: TextOverflow.clip)
                ),
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(13)
                    ),
                    child: InkWell(
                      onTap: () => __updateFavorite(data),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: (widget.favorite) ? SvgPicture.asset('resources/svg/catalog/favorite-colored-active.svg') : SvgPicture.asset('resources/svg/catalog/favorite-colored.svg')
                      ),
                    )
                  ),
                ),
              ],
            ),
          ]
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    (_selectedModel == null)
                    ? Text('\$${data[0]['price_min']} - \$${data[0]['price_max']}', style: TextStyle(fontSize: 20))
                    : Text('\$${_selectedModel['price_min']} - \$${ (_selectedModel.containsKey('price_max') != false) ? _selectedModel['price_max'] : data[0]['price_max']}', style: TextStyle(fontSize: 20))
                  ],
                ),
              ]
            ),
            SizedBox(width: 10),
            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color:Colors.black
                  )
                ]
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Image.asset('icons/flags/png/${data[0]['country']['type'].toString().toLowerCase()}.png', package: 'country_icons'),
                    SizedBox(width: 10),
                    Text(data[0]['country']['value'], style: TextStyle(fontSize: 12)),
                  ],
                )
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: (_selectedModel == null) ? HexColor.fromHex(data[0]['color']['type']) : HexColor.fromHex(_selectedModel['color']['type']),
                boxShadow: [
                  BoxShadow(
                    color:Colors.black
                  )
                ]
              ),
            ),            
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text('Мин. заказ: ', style: TextStyle(fontSize: 16, color: Colors.black45)),
                    Text('${data[0]['min_order']['value']}, ${data[0]['min_order']['type']}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Доступно: ', style: TextStyle(fontSize: 16, color: Colors.black45)),
                    (_selectedModel == null)
                    ? Text('${data[0]['available']['value']}, ${data[0]['available']['type']}', style: TextStyle(fontSize: 16))
                    : Text('${_selectedModel['available']['value']}, ${_selectedModel['available']['type']}', style: TextStyle(fontSize: 16))
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Вес: ', style: TextStyle(fontSize: 16, color: Colors.black45)),
                    Text('${data[0]['weight']['value']}, ${data[0]['weight']['type']}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Длина: ', style: TextStyle(fontSize: 12, color: Colors.black45)),
                    Text('${data[0]['lenght']['value']}, ${data[0]['lenght']['type']}', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 5),
                    Text('Высота: ', style: TextStyle(fontSize: 12, color: Colors.black45)),
                    Text('${data[0]['height']['value']}, ${data[0]['height']['type']}', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 5),
                    Text('Ширина: ', style: TextStyle(fontSize: 12, color: Colors.black45)),
                    Text('${data[0]['width']['value']}, ${data[0]['width']['type']}', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(),
            Text('Торговые предложения:', style: TextStyle(fontSize: 22)),
            __productModels(data, data[0]['product_models']),         
            Divider(),
            SizedBox(height: 10),
            Text('Описание:', style: TextStyle(fontSize: 22)),
            SizedBox(height: 5),
            Text(data[0]['description'], style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Divider(),
            YouTubeFrame(url: data[0]['youtube'])
          ],
        ),
      ],
    );
  }

  __productModels(data, models)
  {
    return Row(
      children: <Widget>[
        (_selectedModel != null)
        ? InkWell(
          child: Container(
            margin: EdgeInsets.all(4),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              image: DecorationImage(image: CachedNetworkImageProvider(data[0]['preview_image'], headers: {'Host': 'g2r-market.mobile'}), fit: BoxFit.cover)
            ),
          ),
          onTap: () => setState((){
            _loaded = true;
            _data = data;
            _selectedModel = null;
          }),
        )
        : Container(
            margin: EdgeInsets.all(4),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              image: DecorationImage(image: CachedNetworkImageProvider(data[0]['preview_image'], headers: {'Host': 'g2r-market.mobile'}), fit: BoxFit.cover)
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(13)
              ),
            )
          ),
        for (var model in models)
        (_selectedModel != model)
        ? InkWell(
          child: Container(
            margin: EdgeInsets.all(4),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              image: DecorationImage(image: CachedNetworkImageProvider(model['preview_image'], headers: {'Host': 'g2r-market.mobile'}), fit: BoxFit.cover)
            ),
          ),
          onTap: () => {
            setState((){
              _loaded = true;
              _data = data;
              _selectedModel = model;
            }),
          }
        )
        : Container(
            margin: EdgeInsets.all(4),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              image: DecorationImage(image: CachedNetworkImageProvider(model['preview_image'], headers: {'Host': 'g2r-market.mobile'}), fit: BoxFit.cover)
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(13)
              ),
            )
          ),
      ],
    );
  }

  Future __updateFavorite(data) async
  {
    var function;

    if(widget.auth != Null)
    {
      if (widget.favorite == true)
      {
        function = Favorite.removeProduct(await widget.auth, data[0]['id']);

      } else
      {
        function = Favorite.addProduct(await widget.auth, data[0]['id']);
      }

      await function;

      data[0]['favorite'] = (widget.favorite) ? false : true;

      setState((){
        widget.favorite =  (widget.favorite) ? false : true;
        _data = data;
        _loaded = true;
      });
    }
  }

  Future __getContent() async
  {
    var data = await Catalog.getProduct(widget.productId);

    return data;
  }
}