import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/pages/cabinet/profile/create_seller.dart';
import 'package:g2r_market/pages/cabinet/profile/profile.dart';
import 'package:g2r_market/services/profile.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:g2r_market/static/api_methods.dart';

class ProfileListPage extends StatefulWidget {
  
  final auth;
  final fromMain;

  ProfileListPage({
    Key key,
    this.fromMain: false,
    this.auth
  }) : super(key: key);

  @override
  _ProfileListPageState createState() => _ProfileListPageState();
}


class _ProfileListPageState extends State<ProfileListPage> {

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
      future: __getProfilesList(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError || snapshot.data == null)
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
                      Text('Профили', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                            child: Text('Продавец'),
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
                            child: Text('Покупатель'),
                          )
                        )
                      ],
                    )
                  ),
                  Expanded(
                    child: ([null].contains(spinkit)) ? __getProfiles(data) : spinkit
                  ),
                  CustomRaisedButton(
                    color: Colors.deepPurple[700],
                    child: Text('Создать профиль'),
                    onPressed: () => {
                      Navigator.push(context, AnimatedSizeRoute(
                          builder: (context) => SellerCreatePage(profiles: data)
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
      onRefresh: () => __updateProfiles(),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int i){

          var status;

          switch (data[i]['status']) {
            case 'active':
              status = 'Подтверждён';
              break;
            case 'waiting':
              status = 'Ожидает подтверждения';
              break;
            default:
              status = 'Не подтверждён';
              break;
          }

          return Column(
            children: <Widget>[
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () => {
                      Navigator.push(context, AnimatedScaleRoute(
                        builder: (context) => ProfilePage(
                            profileId: data[i]['id'],
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
                        image: DecorationImage(image: CachedNetworkImageProvider(data[i]['company_logo_image'], headers: {'Host': API_HOST}), fit: BoxFit.fill)
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
                      children: <Widget>[
                        Container(
                          width: 200,
                          child: Text(data[i]['company_name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.clip, maxLines: 2)
                        ),
                        Container(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Статус: ', style: TextStyle(color: Colors.black54),),
                              Text(status)
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 200,
                          child: Text(data[i]['company_description'], style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2,)
                        ),
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

  Future __getProfilesList() async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return 'NOT_AUTHORIZED';
    }

    var profiles = await Profile.getProfiles(auth, 'seller');

    return profiles;
  }

  __updateProfiles()
  {
    setState(() {
      _loaded = false;
    });
  }
}