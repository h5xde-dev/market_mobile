import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/pages/cabinet/favorites.dart';
import 'package:g2r_market/pages/cabinet/settings.dart';
import 'package:g2r_market/pages/home.dart';
import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';
import 'main.dart';

final Map<String, Item> _items = <String, Item>{};

Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..status = data['status'];
  return item;
}

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

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text("Item ${item.itemId} has been updated"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  List<Widget> pageList = List<Widget>();

  @override
  void initState() {

    super.initState();

    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
    ]);

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {

      print(token);
      assert(token != null);
      setState(() {

      });
    });
    
    pageList.add(HomePage());
    pageList.add(FavoritePage(fromMain: true));
    pageList.add(HomePage());
    pageList.add(SettingsPage(fromMain: true));

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
        icon: 'ic_launcher',
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