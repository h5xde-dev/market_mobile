import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/pages/cabinet/profile/profile.dart';
import 'package:g2r_market/pages/manager/create_company.dart';
import 'package:g2r_market/pages/manager/list_profiles.dart';
import 'package:g2r_market/services/manager.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:g2r_market/static/api_methods.dart';

class CompanyListPage extends StatefulWidget {
  
  final auth;

  CompanyListPage({
    Key key,
    @required this.auth
  }) : super(key: key);

  @override
  _CompanyListPageState createState() => _CompanyListPageState();
}


class _CompanyListPageState extends State<CompanyListPage> {

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
      future: __getCompaniesList(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            return __content(context, snapshot.data, null);
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
                      Text("Компании", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 20)
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                      ],
                    )
                  ),
                  Expanded(
                    child: ([null].contains(spinkit)) ? __getProfiles(data) : spinkit
                  ),
                  CustomRaisedButton(
                    color: Colors.deepPurple[700],
                    child: Text('Создать компанию', style: TextStyle(color: Colors.white)),
                    onPressed: () => {
                      Navigator.push(context, AnimatedSizeRoute(
                          builder: (context) => CompanyCreatePage(auth: widget.auth)
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
      onRefresh: () => __updateCompanies(),
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int i){

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
                        builder: (context) => CompanyProfileListPage(
                            auth: widget.auth,
                            companyId: data[i]['id'],
                          )
                        )
                      )
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: 
                      BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        image: DecorationImage(image: AssetImage('resources/images/default_profile_image.png'), fit: BoxFit.fill)
                      ),
                      child: Center()
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
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                            ],
                          ),
                        ),
                        SizedBox(height: 20),
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

  Future __getCompaniesList() async
  {
    List companies = await Manager.getCompanies(widget.auth);

    return companies;
  }

  __updateCompanies()
  {
    setState(() {
      _loaded = false;
    });
  }
}