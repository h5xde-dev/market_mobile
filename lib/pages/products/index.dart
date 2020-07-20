import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/extesions/color.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:g2r_market/services/catalog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProductPage extends StatefulWidget {

  final int productId;

  ProductPage({
    Key key,
    this.productId,
  }) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}


class _ProductPageState extends State<ProductPage> {
      
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
    
    return FutureBuilder(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(),
              items: images.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: CachedNetworkImage(imageUrl: i, httpHeaders: {'Host': 'g2r-market.mobile'},),
                    );
                  },
                );
              }).toList(),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(data[0]['name'], style: TextStyle(fontSize: 32),),
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(13)
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: SvgPicture.asset('resources/svg/catalog/favorite-colored.svg')
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
                    Text(data[0]['country']['value'], style: TextStyle(fontSize: 12),),
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
                color: HexColor.fromHex(data[0]['color']['type']),
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
                    Text('${data[0]['available']['value']}, ${data[0]['available']['type']}', style: TextStyle(fontSize: 16)),
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
            )
          ],
        ),
        SizedBox(height: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Торговые предложения:', style: TextStyle(fontSize: 22)),
            Divider(),
            SizedBox(height: 10),
            Text('Описание:', style: TextStyle(fontSize: 22)),
            SizedBox(height: 5),
            Text(data[0]['description'], style: TextStyle(fontSize: 18)),
            SizedBox(height: 5),
            Divider(),
            Container(
              height: 400,
              child: WebView(
              initialUrl: data[0]['youtube'],
              javascriptMode: JavascriptMode.unrestricted,
            )),
          ],
        ),
      ],
    );
  }

  Future __getContent() async
  {
    var data = await Catalog.getProduct(widget.productId);

    return data;
  }
}