import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/cabinet/profile/create_buyer.dart';
import 'package:g2r_market/pages/cabinet/profile/create_seller.dart';
import 'package:g2r_market/pages/cabinet/profile/profile.dart';
import 'package:g2r_market/services/manager.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:g2r_market/static/api_methods.dart';

class CompanyProfileListPage extends StatefulWidget {
  
  final auth;
  final int companyId;

  CompanyProfileListPage({
    Key key,
    @required this.auth,
    @required this.companyId
  }) : super(key: key);

  @override
  _CompanyProfileListPageState createState() => _CompanyProfileListPageState();
}


class _CompanyProfileListPageState extends State<CompanyProfileListPage> {

  bool _loaded = false;
  var _data;

  String _selectedProfileType = 'seller';
      
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
                              color: (_selectedProfileType == 'seller') ? Colors.black54 : Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Text('Продавец'),
                          ),
                          onTap: (){
                            setState(() {
                              _selectedProfileType = 'seller';
                              _loaded = false;
                            });
                          },
                        ),
                        SizedBox(width: 20),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (_selectedProfileType == 'buyer') ? Colors.black54 : Colors.white,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: Colors.black54)
                            ),
                            child: Text('Покупатель'),
                          ),
                          onTap: (){
                            setState(() {
                              _selectedProfileType = 'buyer';
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
                    child: Text('Создать профиль', style: TextStyle(color: Colors.white)),
                    onPressed: () => {
                      Navigator.push(context, AnimatedSizeRoute(
                          builder: (context) => (_selectedProfileType == 'seller')
                          ? SellerCreatePage(profiles: data, companyId: widget.companyId)
                          : BuyerCreatePage(profiles: data, companyId: widget.companyId)
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
            case 'wait':
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
                      Navigator.push(context, AnimatedSizeRoute(
                        builder: (context) => ProfilePage(
                            profileId: data[i]['id'],
                            auth: widget.auth,
                            profileType: _selectedProfileType,
                            companyId: widget.companyId,
                          )
                        )
                      )
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: 
                      (_selectedProfileType == 'seller')
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          image: DecorationImage(image: CachedNetworkImageProvider(data[i]['company_logo_image'], headers: {'Host': API_HOST}), fit: BoxFit.fill)
                        )
                      : BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          image: DecorationImage(image: AssetImage('resources/images/default_profile_image.png'), fit: BoxFit.fill)
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
                          child: Text(data[i]['company_name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.clip, maxLines: 2)
                        ),
                        Container(
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
                        (_selectedProfileType == 'seller' && data[i].containsKey('company_description') && data[i]['company_description'].isNotEmpty)
                        ? Container(
                            width: 200,
                            child: Text(data[i]['company_description'], style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2,)
                          )
                        : Container()
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

    var profiles = await Manager.getProfiles(widget.auth, _selectedProfileType, widget.companyId);

    return profiles;
  }

  __updateProfiles()
  {
    setState(() {
      _loaded = false;
    });
  }
}