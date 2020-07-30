import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/services/profile.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:g2r_market/widgets/youtube_frame.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {

  final int profileId;
  final auth;

  ProfilePage({
    Key key,
    this.profileId,
    this.auth
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {

  CarouselController buttonCarouselController = CarouselController();

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
                        ([null].contains(spinkit)) ? __profileInfo(data) : spinkit
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

  __profileInfo(data)
  {

    List images = data['main_banner'];
    
    if(data.containsKey('company_promo') != false)
    {
      for(var image in data['company_promo'])
      {
        images.add(image);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 300,
              child: Text(data['company_name'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.clip)
            ),
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('icons/flags/png/${data['localisation'].toString().toLowerCase()}.png', package: 'country_icons'), fit: BoxFit.fill),
                borderRadius: BorderRadius.circular(13),
                color: Colors.white,
              ),
            )
          ],
        ),
        Divider(),
        Column(
          children: <Widget>[
            CarouselSlider(
              options: CarouselOptions(
                enlargeCenterPage: true,
                aspectRatio: 4/3,
                viewportFraction: 0.9,
                carouselController: buttonCarouselController,
                initialPage: 1
              ),
              items: images.map<Widget>((i) {
                return new Builder(
                  builder: (BuildContext context) {
                    return new Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: CachedNetworkImage(imageUrl: i, httpHeaders: {'Host': 'g2r-market.mobile'}, fit: BoxFit.fill,),
                    );
                  },
                );
              }).toList(),
            ),
            Divider(),
          ]
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
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
                        Image.asset('icons/flags/png/${data['country']['type'].toString().toLowerCase()}.png', package: 'country_icons'),
                        SizedBox(width: 10),
                        Text(data['country']['value'], style: TextStyle(fontSize: 12)),
                      ],
                    )
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    (data['region'] != null) ? Text('${data['region']} , ') : Text(' , '),
                    (data['city'] != null) ? Text('${data['city']}') : Text(''),
                  ],
                ),
                Row(
                  children: <Widget>[
                    (data['street'] != null) ? Text('${data['street']} , ') : Text(' , '),
                    (data['number_home'] != null) ? Text('${data['number_home']}') : Text(''),
                  ],
                ),
              ]
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
                Center()
              ],
            ),
          ],
        ),
        SizedBox(height: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Контакты', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: <Widget>[
                Text('Контактное лицо: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                (data['name'] != null || data['last_name'] != null) ? Text('${data['name']} ${data['last_name']}') : Text(''),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Должность: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                (data['position'] != null) ? Text(data['position']) : Text('Не указана'),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Номер телефона: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                (data['number_phone'] != null) ? Text(data['number_phone']) : Text('Не указан'),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Номер телефона (мобильный): ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                (data['number_phone_mobile'] != null) ? Text(data['number_phone_mobile']) : Text('Не указан'),
              ],
            ),
            Divider(),
            Text('Описание', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            (data['company_description'] != null) ? Text(data['company_description']) : Text('Без описания'),
            SizedBox(height: 10),
            (data['company_youtube_link'] != null) ? YouTubeFrame(url: data['company_youtube_link']) : Center(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CustomRaisedButton(
                  borderRaius: 0,
                  color: Colors.deepPurple[700],
                  child: Text('Выбрать', style: TextStyle(color: Colors.white),),
                  onPressed: (){},
                ),
                CustomRaisedButton(
                  borderRaius: 0,
                  color: Colors.deepPurple[700],
                  child: Text('Редактировать', style: TextStyle(color: Colors.white),),
                  onPressed: (){},
                ),
                CustomRaisedButton(
                  borderRaius: 0,
                  color: Colors.red,
                  child: Text('Удалить', style: TextStyle(color: Colors.white),),
                  onPressed: (){},
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future __getContent() async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return null;
    }

    var data = await Profile.getProfileInfo(auth, widget.profileId);

    return data;
  }
}