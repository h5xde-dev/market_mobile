import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/helpers/profile.dart';
import 'package:g2r_market/helpers/user.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/pages/cabinet/account_edit.dart';
import 'package:g2r_market/pages/cabinet/chat_items.dart';
import 'package:g2r_market/pages/cabinet/product/list.dart';
import 'package:g2r_market/pages/cabinet/profile/list.dart';
import 'package:g2r_market/pages/manager/list_companies.dart';
import 'package:g2r_market/widgets/cabinet_button.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/settings.dart';
import 'package:g2r_market/static/api_methods.dart';

class SettingsPage extends StatefulWidget {
  

  SettingsPage({
    Key key,
    this.fromMain: false,
  });

  final bool fromMain;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  Map mainProfile = {};
  List roles = [];
      
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
      future: __getUserInfo(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError || snapshot.data == null)
              return SignInPage(fromMain: widget.fromMain);
            else {
              return __content(context, snapshot.data, null);
            }
        }
      },
    );
  }

  __content(context, data, spinkit)
  {
    Size size = MediaQuery.of(context).size;

    return Scaffold(

      body: Stack(
        children: <Widget>[
          Container(
            height: size.height * .25,
            decoration: BoxDecoration(
              color: Color.fromRGBO(247,247,247, 100)
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height:20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      (widget.fromMain == true)
                      ? Center()
                      : InkWell(
                        child: Icon(Icons.arrow_back_ios),
                        onTap: () => Navigator.pop(context, true),
                      ),
                      InkWell(
                        child: Text('Выход'),
                        onTap: () => __logout(context),
                      ), 
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Column(
                      children: <Widget>[
                        [null].contains(spinkit) ?
                        Center(
                          child: (data['avatar'] != '') 
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: CachedNetworkImageProvider(data['avatar'], headers: {'Host': API_HOST}),
                            )
                          : CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.deepPurple[700],
                            )
                        ) : Center(),
                        SizedBox(height:10),
                        [null].contains(spinkit) ? Text("${data['name']}  ${data['last_name'] ?? ''}", style: TextStyle(fontSize: 20),) : Center(),
                      ]
                    )
                  ),
                  [null].contains(spinkit) ? Center() : Expanded(
                    child: spinkit
                  ),
                  SizedBox(height: 20),
                  [null].contains(spinkit)
                  ? Expanded(
                    child: RefreshIndicator(
                       onRefresh: () => __updateUserInfo(context),
                       child: ListView(
                          children: [__cabinetMenu(context)]
                        )
                    )
                  )
                  : Center(),
                ],
              ),
            )
          ),
        ]
      ),
    );
  }

  Future __logout(context) async
  {
    await DBProvider.db.deleteAccountInfo();
    await DBProvider.db.deleteAuth();
    
    Navigator.pushReplacement(context, AnimatedScaleRoute(
        builder: (context) => LandingPage(selectedPage: 1)
      )
    );
  }

  Widget __cabinetMenu(context)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CabinetButton(
          text: Text('Учётная запись'),
          icon: SvgPicture.asset('resources/svg/main/user.svg'),
          color: Colors.white,
          width: 300,
          onPressed: (){
            Navigator.push(context, AnimatedScaleRoute(
                builder: (context) => AccountEditPage()
              )
            );
          },
        ),
        Visibility(
          visible: (roles.isNotEmpty && roles.contains('site_manager')),
          child: CabinetButton(
            text: Text('Кабинет менеджера'),
            icon: SvgPicture.asset('resources/svg/main/operator.svg'),
            color: Colors.white,
            width: 300,
            onPressed: () async {
              var auth = await DBProvider.db.getAuth();

              Navigator.push(context, AnimatedScaleRoute(
                  builder: (context) => CompanyListPage(auth: auth)
                )
              );
            },
          )
        ),
        CabinetButton(
          text: Text('Мои профили'),
          icon: SvgPicture.asset('resources/svg/main/users.svg'),
          color: Colors.white,
          width: 300,
          onPressed: () async {
            var auth = await DBProvider.db.getAuth();

            Navigator.push(context, AnimatedScaleRoute(
                builder: (context) => ProfileListPage(auth: auth)
              )
            );
          },
        ),
        CabinetButton(
          text: Text('Сообщения'),
          icon: SvgPicture.asset('resources/svg/main/messages.svg'),
          color: Colors.white,
          width: 300,
          onPressed: () async {
            var auth = await DBProvider.db.getAuth();

            Navigator.push(context, AnimatedScaleRoute(
                builder: (context) => ChatItems(auth: auth)
              )
            );
          },
        ),
        Divider(),
        (mainProfile != null && mainProfile['type'] == 'seller')
        ? CabinetButton(
            text: Text('Товары'),
            icon: SvgPicture.asset('resources/svg/main/package.svg'),
            counter: 1,
            color: Colors.white,
            width: 300,
            onPressed: () async {
              var auth = await DBProvider.db.getAuth();

              Navigator.push(context, AnimatedScaleRoute(
                  builder: (context) => ProductListPage(auth: auth, profileId: mainProfile['id'])
                )
              );
            },
          )
        : (mainProfile['type'] == 'buyer')
          ? CabinetButton(
              text: Text('Запросы'),
              icon: SvgPicture.asset('resources/svg/main/order.svg'),
              counter: 1,
              color: Colors.white,
              width: 300,
              onPressed: (){},
            )
          : Center()
      ]
    );
  }

  Future __updateUserInfo(context) async
  {
    Navigator.push(context, AnimatedScaleRoute(
        builder: (context) => LandingPage(selectedPage: 3)
      )
    );
  }

  Future __getUserInfo() async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return null;
    }

    await Settings.getAccountInfo(auth);

    var userInfo = await DBProvider.db.getAccountInfo();

    if(mainProfile.isEmpty)
    {
      int profileId = await ProfileHelper.getSelectedProfile();

      String profileType = await ProfileHelper.getProfileType(profileId);

      mainProfile = {'id': profileId, 'type': profileType};

      setState(() {
        mainProfile = mainProfile;
      });
    }

    if(roles.isEmpty)
    {
      List _roles = await UserHelper.getRoles();

      setState(() {
        roles = _roles;
      });
    }

    return userInfo;
  }
}