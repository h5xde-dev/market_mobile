import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/helpers/profile.dart';
import 'package:g2r_market/pages/cabinet/chat.dart';
import 'package:g2r_market/services/chat.dart';
import 'package:g2r_market/widgets/flat_chat/add_story.dart';
import 'package:g2r_market/widgets/flat_chat/chat_item.dart';
import 'package:g2r_market/widgets/flat_chat/counter.dart';
import 'package:g2r_market/widgets/flat_chat/page_header.dart';
import 'package:g2r_market/widgets/flat_chat/profile_image.dart';
import 'package:g2r_market/widgets/flat_chat/section_header.dart';

class ChatItems extends StatefulWidget {
  
  ChatItems({
    Key key,
    this.auth
  }) : super(key: key);

  final auth;

  @override
  _ChatItemsState createState() => _ChatItemsState();
}

class _ChatItemsState extends State<ChatItems> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool _loaded = false;
  Map _data;

  @override
  void initState()
  {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        
        List chats = _data['chats'];

        var chatId = chats.indexWhere((element) => element['id'].toString() == message['data']['chat_id'].toString());

        _data['chats'][chatId]['last_message'] = message['notification']['body'];
        _data['chats'][chatId]['messages_count'] = _data['chats'][chatId]['messages_count'] + 1;

        setState(() {
          _loaded = true;
          _data = _data;
        });
        
      },
    );
  }

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
    
    return _loaded ? __content(context, _data, null) : FutureBuilder(
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
    List<Widget> chats = new List<Widget>();

    if(data != null)
    {
      for (var chat in data['chats'])
      {
        chats.add(
          new FlatChatItem(
            profileImage: FlatProfileImage(
              imageUrl: chat['chat_image'].toString().replaceAll(new RegExp(r'g2r.market'), '176.99.5.64'),
              outlineIndicator: false,
              onlineIndicator: chat['status'] == 'online' ? true : false,
            ),
            name: chat['chat_name'],
            message: chat['last_message'],
            counter: FlatCounter(
              text: "${chat['messages_count']}",
            ),
            multiLineMessage: true,
            onPressed: () {
              Navigator.push(context, AnimatedScaleRoute(
                builder: (context) => ChatPage(
                    chat: chat,
                    auth: widget.auth,
                  )
                )
              );
            },
          )
        );
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            SizedBox(height:20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    child: Icon(Icons.arrow_back_ios),
                    onTap: () => Navigator.pop(context, true),
                  ),
                  Text('Мои сообщения', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(width: 20)
                ],
              ),
            ),
            FlatPageHeader(
              title: "",
            ),
            FlatSectionHeader(
              title: "Контакты",
            ),
            Container(
              height: 108.0,
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16.0),
                    child: FlatAddStoryBtn(
                      backgroundColor: Colors.deepPurple[700],
                      onPressed: () {
                        print("Button Pressed");
                      },
                    ),
                  ),
                  /* FlatProfileImage(
                    outlineIndicator: true,
                    onlineIndicator: true,
                    imageUrl: 'https://images.pexels.com/photos/3866555/pexels-photo-3866555.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
                  ),
                  FlatProfileImage(
                    outlineIndicator: true,
                    onlineIndicator: false,
                    outlineColor: Color(0xFF262833).withOpacity(0.3),
                    imageUrl: 'https://images.pexels.com/photos/4618392/pexels-photo-4618392.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
                  ),
                  FlatProfileImage(
                    outlineIndicator: true,
                    onlineIndicator: false,
                    outlineColor: Color(0xFF262833).withOpacity(0.3),
                    imageUrl: 'https://images.pexels.com/photos/1261731/pexels-photo-1261731.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
                  ),
                  FlatProfileImage(
                    outlineIndicator: true,
                    onlineIndicator: false,
                    imageUrl: 'https://images.pexels.com/photos/3699259/pexels-photo-3699259.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
                  ),
                  FlatProfileImage(
                    outlineIndicator: true,
                    onlineIndicator: false,
                    outlineColor: Color(0xFF262833).withOpacity(0.3),
                    imageUrl: 'https://images.pexels.com/photos/3078831/pexels-photo-3078831.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
                  ) */
                ],
              ),
            ),
            /* FlatSectionHeader(
              title: "Marked Important",
            ),
            FlatChatItem(
              profileImage: FlatProfileImage(
                onlineIndicator: true,
                imageUrl: 'https://images.pexels.com/photos/3866555/pexels-photo-3866555.png?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
              ),
              name: "Alix Cage",
              message: "Something new here, wasup chan",
              multiLineMessage: true,
              onPressed: () {
                Navigator.push(context, AnimatedSizeRoute(
                    builder: (context) => ChatPage(auth: widget.auth)
                  )
                );
              },
            ), */
            FlatSectionHeader(
              title: "Сообщения",
            ),

            Column(children: chats)
            
          ],
        ),
      ),
    );
  }

  Future<Map> __getContent() async
  {
    var profile;
    
    var profileId = await ProfileHelper.getSelectedProfile();

    if(profileId != Null)
    {
      profile = profileId;
    }

    _data = await Chat.getInfo(widget.auth, profile);

    setState(() {
      _data = _data;
      _loaded = true;
    });

    return _data;
  }
}