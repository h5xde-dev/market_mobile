import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/profile.dart';
import 'package:g2r_market/helpers/user.dart';
import 'package:g2r_market/services/manager.dart';
import 'package:g2r_market/services/profile.dart';
import 'package:g2r_market/static/api_methods.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:g2r_market/widgets/youtube_frame.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {

  final int profileId;
  final String profileType;
  final auth;

  ProfilePage({
    Key key,
    @required this.profileId,
    @required this.auth,
    @required this.profileType
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
    List images = [];

    if(widget.profileType == 'seller')
    {
      images = data['main_banner'];
    
      if(data.containsKey('company_promo') != false && data['company_promo'] != null)
      {
        for(var image in data['company_promo'])
        {
          images.add(image);
        }
      }
    }

    List<Widget> _allowedActions()
    {
      List<Widget> _list = new List<Widget>();

      switch (data['status'])
      {
        case 'active':
          _list = [
            (data['active'] == true)
            ? CustomRaisedButton(
                borderRaius: 0,
                color: Colors.deepPurple[700],
                child: Text('Выбран', style: TextStyle(color: Colors.white)),
              )
            : CustomRaisedButton(
                borderRaius: 0,
                color: Colors.deepPurple[700],
                child: Text('Выбрать', style: TextStyle(color: Colors.white),),
                onPressed: () async {

                  await ProfileHelper.select(data['id'], widget.profileType);

                  setState(() {
                    
                  });
                },
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
          ];
          break;
        case 'wait':
          _list = [
            Center(
              child: Container(
                color: Colors.yellow[900],
                height: 50,
                width: MediaQuery.of(context).size.width - 40,
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Text('Ожидает подтверждения', style: TextStyle(color: Colors.white))
                ),
              )
            )
          ];
          break;
        default:
          _list = [
            CustomRaisedButton(
              borderRaius: 0,
              color: Colors.deepPurple[700],
              width: 250,
              child: Text('Подтвердить', style: TextStyle(color: Colors.white),),
              onPressed: () async {

                List roles = await UserHelper.getRoles();

                if(roles.contains('site_manager'))
                {
                  await Manager.approve(widget.auth, data['id']);
                    Navigator.pop(context, false);
                    setState(() {
                      _loaded = false;
                    });
                  return null;
                }

                List<String> _allowedExtensions = [
                  'jpeg',
                  'png',
                  'jpg',
                  'gif',
                  'svg',
                  'docx',
                  'doc',
                  'xls',
                  'xlsx',
                  'ppt',
                  'pptx',
                  'csv',
                  'odp',
                  'ods',
                  'txt',
                  'odt'
                ];

                List<File> _documents = [];

                _documents = await FilePicker.getMultiFile(
                  type: FileType.custom,
                  allowedExtensions: _allowedExtensions,
                  allowCompression: true
                );

                if( _documents.isNotEmpty)
                {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13)
                        ),
                        title: Text('Вы действительно хотите подтвердить профиль?'),
                        actions: [
                          FlatButton(
                            onPressed: () async {
                              await Profile.approve(widget.auth, data['id'], _documents);
                                Navigator.pop(context, false);
                                setState(() {
                                  _loaded = false;
                                });
                              },
                            child: Text('Да'),
                          ),
                          FlatButton(
                            onPressed: () => Navigator.pop(context, false), // passing false
                            child: Text('Отмена'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            CustomRaisedButton(
              borderRaius: 0,
              color: Colors.red,
              child: Text('Удалить', style: TextStyle(color: Colors.white),),
              onPressed: (){},
            ),
          ];
          break;
      }

      return _list;
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
                image: DecorationImage(image: AssetImage('icons/flags/png/${(data['localisation'].toString().toLowerCase() != 'zh') ? data['localisation'].toString().toLowerCase() : 'cn'}.png', package: 'country_icons'), fit: BoxFit.fill),
                borderRadius: BorderRadius.circular(13),
                color: Colors.white,
              ),
            )
          ],
        ),
        Divider(),
        (widget.profileType == 'seller')
        ? Column(
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
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(image: ResizeImage(CachedNetworkImageProvider(i), width:  500, height: 500, allowUpscaling: true), fit: BoxFit.fill)
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 5.0)
                      );
                    },
                  );
                }).toList(),
              ),
              Divider(),
            ]
          )
        : SizedBox(),
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
                        Image.asset('icons/flags/png/${(data['country']['type'].toString().toLowerCase() != 'zh') ? data['country']['type'].toString().toLowerCase() : 'cn'}.png', package: 'country_icons'),
                        SizedBox(width: 10),
                        Text(data['country']['value'], style: TextStyle(fontSize: 12)),
                      ],
                    )
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    (data.containsKey('region') && data['region'] != null) ? Text('${data['region']} , ') : Text(' , '),
                    (data.containsKey('city') && data['city'] != null) ? Text('${data['city']}') : Text(''),
                  ],
                ),
                Row(
                  children: <Widget>[
                    (data.containsKey('street') && data['street'] != null) ? Text('${data['street']} , ') : Text(' , '),
                    (data.containsKey('number_home') && data['number_home'] != null) ? Text('${data['number_home']}') : Text(''),
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
                (data.containsKey('name') && data['name'] != null || data['last_name'] != null) ? Text('${data['name']} ${data['last_name']}') : Text(''),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Должность: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                (data.containsKey('position') && data['position'] != null) ? Text(data['position']) : Text('Не указана'),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Номер телефона: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                (data.containsKey('number_phone') && data['number_phone'] != null) ? Text(data['number_phone']) : Text('Не указан'),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Номер телефона (мобильный): ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                (data.containsKey('number_phone_mobile') && data['number_phone_mobile'] != null) ? Text(data['number_phone_mobile']) : Text('Не указан'),
              ],
            ),
            Divider(),
            Text('Описание', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            (data.containsKey('company_description') && data['company_description'] != null) ? Text(data['company_description']) : Text('Без описания'),
            SizedBox(height: 10),
            (data.containsKey('company_youtube_link') && data['company_youtube_link'] != null) ? YouTubeFrame(url: data['company_youtube_link']) : Center(),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _allowedActions(),
            ),
          ],
        ),
      ],
    );
  }

  Future __getContent() async
  {
    int activeProfile = await ProfileHelper.getSelectedProfile();

    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return null;
    }

    Map data = await Profile.getProfileInfo(auth, widget.profileId, widget.profileType);

    data.addAll({'active': (activeProfile != data['id']) ? false : true});

    return data;
  }
}