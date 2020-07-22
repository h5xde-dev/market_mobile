import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/widgets/cabinet_button.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/settings.dart';

class SettingsPage extends StatelessWidget {

  SettingsPage({
    this.fromMain: false,
  });

  final bool fromMain;
      
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
              return SignInPage();
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
                      (fromMain == true)
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
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: CachedNetworkImageProvider(data['avatar'], headers: {'Host': 'g2r-market.mobile'}),
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
                    child: ListView(
                      children: [__cabinetMenu()]
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
    
    Navigator.pushReplacement(context, AnimatedSizeRoute(
        builder: (context) => LandingPage(selectedPage: 1)
      )
    );
  }

  Widget __cabinetMenu()
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
          onPressed: (){},
        ),
        CabinetButton(
          text: Text('Мои профили'),
          icon: SvgPicture.asset('resources/svg/main/users.svg'),
          color: Colors.white,
          width: 300,
          onPressed: (){},
        ),
        CabinetButton(
          text: Text('Сообщения'),
          icon: SvgPicture.asset('resources/svg/main/messages.svg'),
          color: Colors.white,
          width: 300,
          onPressed: (){},
        ),
        Divider(),
        CabinetButton(
          text: Text('Товары'),
          icon: SvgPicture.asset('resources/svg/main/package.svg'),
          counter: 1,
          color: Colors.white,
          width: 300,
          onPressed: (){},
        ),
      ]
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

    return userInfo;
  }
}