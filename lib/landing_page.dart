import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/pages/cabinet/favorites.dart';
import 'package:g2r_market/pages/cabinet/settings.dart';
import 'package:g2r_market/pages/home.dart';
import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';

// ignore: must_be_immutable
class LandingPage extends StatefulWidget {
  
  int selectedPage;

  LandingPage({
    Key key,
    this.selectedPage: 0
  }) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  List<Widget> pageList = List<Widget>();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
    ]);
    pageList.add(HomePage());
    pageList.add(FavoritePage(fromMain: true));
    pageList.add(HomePage());
    pageList.add(SettingsPage(fromMain: true));
    super.initState();

    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      setState(() {

      });
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      // NOTE: This first action icon will only work on iOS.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'action_one',
        localizedTitle: 'Настройки',
        icon: 'AppIcon',
      ),
      // NOTE: This second action icon will only work on Android.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
          type: 'action_two',
          localizedTitle: 'Избранное',
          icon: 'ic_launcher'),
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: widget.selectedPage,
        children: pageList,
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
        height: 80,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () => _onItemTapped(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SvgPicture.asset('resources/svg/main/home.svg', color: ((widget.selectedPage == 0) ? true : false ) ? Colors.deepPurple : Colors.black)
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SvgPicture.asset('resources/svg/main/list.svg', color: ((widget.selectedPage == 1) ? true : false ) ? Colors.deepPurple : Colors.black)
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SvgPicture.asset('resources/svg/main/order.svg', color: ((widget.selectedPage == 2) ? true : false ) ? Colors.deepPurple : Colors.black)
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _onItemTapped(3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SvgPicture.asset('resources/svg/main/cog.svg', color: ((widget.selectedPage == 3) ? true : false ) ? Colors.deepPurple : Colors.black)
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedPage = index;
    });
  }
}