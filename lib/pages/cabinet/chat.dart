import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/profile.dart';
import 'package:g2r_market/services/chat.dart';
import 'package:g2r_market/widgets/flat_chat/action_button.dart';
import 'package:g2r_market/widgets/flat_chat/chat_message.dart';
import 'package:g2r_market/widgets/flat_chat/message_input.dart';
import 'package:g2r_market/widgets/flat_chat/page_header.dart';
import 'package:g2r_market/widgets/flat_chat/page_wrapper.dart';
import 'package:g2r_market/widgets/flat_chat/profile_image.dart';

class ChatPage extends StatefulWidget {

  ChatPage({
    Key key,
    @required this.auth,
    @required this.chat
  }) : super(key: key);

  final auth;
  final Map chat;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final ScrollController scrollController = ScrollController();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool _loaded = false;
  List<Widget> _data = [];
  int _page = 0;

  @override
  void initState() {
    scrollController.addListener(_scrollListener);
    super.initState();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {

        bool isMine = false;

        if(message['data']['type'] == 'user')
        {
          var userInfo = await DBProvider.db.getAccountInfo();
          isMine = (message['data']['from_id'].toString() == userInfo['user_id'].toString());
        }

        if(message['data']['type'] == 'profile')
        {
          var currentProfile = await ProfileHelper.getSelectedProfile();

          isMine = (message['data']['from_id'].toString() == currentProfile.toString());
        }

        _data.insert(0, FlatChatMessage(
          message: message['notification']['body'],
          messageType: (isMine) ? MessageType.sent : MessageType.received,
          showTime: true,
          time: message['data']['created_at'],
        ));

        setState(() {
          _page = _page;
          _data = _data;
          _loaded = true;
        });

      }
    );
  }

  _scrollListener() async {
      
    if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {

      await __getContent();

      setState(() {
        _page = _page;
        _data = _data;
        _loaded = true;
      });
    }
}

  @override
  Widget build(BuildContext context) {
    
    return _loaded ? __content(context, _data) : FutureBuilder(
      future: __getContent(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null);
          case ConnectionState.waiting:
            return __content(context, null);
          default:
            if (snapshot.hasError)
              return __content(context, null);
            else {
              return __content(context, snapshot.data);
            }
        }
      },
    );
  }

  __content(context, data) {

    final TextEditingController textController = TextEditingController();

    return Scaffold(
      body: FlatPageWrapper(
        backgroundColor: Colors.white,
        scrollType: ScrollType.floatingHeader,
        scrollController: scrollController,
        reverseBodyList: true,
        header: FlatPageHeader(
          prefixWidget: FlatActionButton(
            iconSize: 25,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          textColor: Colors.black,
          textSize: 20,
          title: widget.chat['chat_name'],
          suffixWidget: FlatProfileImage(
            onlineColor: Colors.green,
            size: 35.0,
            onlineIndicator: true,
            imageUrl: widget.chat['chat_image'],
            onPressed: () {
              print("Clicked Profile Image");
            },
          ),
        ),
        children: (data != null) ? data : [],
        footer: FlatMessageInputBox(
          roundedCorners: true,
          textController: textController,
          onSubmitted: () async {

            textController.text = null;

            (widget.chat['type'] == 'support')
            ? await Chat.sendSupport(widget.auth, widget.chat['id'], textController.text)
            : await sendProfile(textController.text);

            setState(() {
              _page = _page;
              _data = _data;
              _loaded = true;
            });
          },
        ),
      ),
    );
  }

  Future sendProfile(String message) async
  {
    var profileId = await ProfileHelper.getSelectedProfile();

    if(profileId.runtimeType != Null)
    {
      await Chat.sendProfile(widget.auth, widget.chat['id'], profileId, widget.chat['profile_id'], message);

    } else
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13)
            ),
            title: Text('Не выбран профиль для этого диалога'),
          );
        },
      );
    }
  }

  Future<List> __getContent() async
  {
    if(_data.length == 0)
    {
      _data = [];
    }

    if(widget.chat['type'] == 'support')
    {
      _page = _page + 1;

      List newData = await Chat.getMessagesSupport(widget.auth, widget.chat['id'], _page);

      for (var message in newData)
      {
        _data.add(
          FlatChatMessage(
            message: message['message'],
            messageType: message['mine'] ? MessageType.sent : MessageType.received,
            showTime: true,
            time: message['created_at'],
          )
        );
      }
    }

    if(widget.chat['type'] == 'profile')
    {
      _page = _page + 1;

      var profileId = await ProfileHelper.getSelectedProfile();

      if(profileId.runtimeType != Null)
      {
        List newData = await Chat.getMessages(widget.auth, widget.chat['id'], profileId, _page);

        for (var message in newData)
        {
          _data.add(
            FlatChatMessage(
              message: message['message'],
              messageType: message['mine'] ? MessageType.sent : MessageType.received,
              showTime: true,
              time: message['created_at'],
            )
          );
        }

      } else
      {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)
              ),
              title: Text('Не выбран профиль для этого диалога'),
            );
          },
        );
      }
    }

    return _data;
  }
}