import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/settings.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class AccountEditPage extends StatefulWidget{
  
  Map errors;

  AccountEditPage({
    Key key
  }) : super(key: key);

  @override
  _AccountEditPageState createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController patronymicController = TextEditingController();
  final TextEditingController birthdayController = MaskedTextController(mask: '00.00.0000');
  final TextEditingController phoneController = MaskedTextController(mask: '00000000000');

  List<CameraDescription> cameras = [];
  CameraController cameraController;
  FileImage avatar;
  bool _loaded = false;
  Map userInfo;
      
  @override
  Widget build(BuildContext context) {

    print(avatar);

    final spinkit = Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SpinKitRing(color: Colors.blue[900], size: 175),
          SvgPicture.asset('resources/svg/main/spinner.svg', alignment: Alignment.center, width: 150),
        ],
      )
    );
    
    return (_loaded == true)
    ? __content(context, userInfo, null)
    : FutureBuilder(
      future: __getUserInfo(),
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
    Size size = MediaQuery.of(context).size;

    /* if(data != null)
    {
      nameController.text = data['name'];
      lastNameController.text = data['last_name'];
      patronymicController.text = data['patronymic'];
      birthdayController.text = data['birthday'];
      phoneController.text = data['phone'];
    } */

    return Scaffold(
      body: Visibility(
        visible: (cameraController != null && cameraController.value.isInitialized == true) ? false : true,
        child: Stack(
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
                        InkWell(
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
                          [null].contains(spinkit) 
                          ? InkWell(
                              child: Center(
                                child: (data.containsKey('avatar') != false && data['avatar'] != '' || avatar != null)
                                ? CircleAvatar(
                                    radius: 40,
                                    backgroundImage: (avatar == null) ? CachedNetworkImageProvider(data['avatar'] , headers: {'Host': 'g2r-market.mobile'}) : avatar,
                                    child: Icon(Icons.photo_camera),
                                  )
                                : CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.deepPurple[700],
                                    child: Icon(Icons.photo_camera),
                                  )
                              ) ,
                              onTap: () async {
                                if(cameras.length != 0)
                                {
                                  if(cameraController != null && cameraController.value.isInitialized == true)
                                  {
                                    cameraController.dispose();
                                  }

                                  cameraController = CameraController(cameras[0], ResolutionPreset.high);

                                  await cameraController.initialize();

                                  cameraController.addListener(() {
                                    if (mounted) setState(() {
                                        _loaded = true;
                                        userInfo = data;
                                        cameras = cameras;
                                        cameraController = cameraController;
                                      });
                                    if (cameraController.value.hasError) {
                                      print('ERROR BLYAT');
                                    }
                                  });

                                  setState(() {
                                    _loaded = true;
                                    userInfo = data;
                                    cameras = cameras;
                                    cameraController = cameraController;
                                  });
                                }
                              },
                            )
                          : Center(),
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
                        children: [__accountEdit(context, data)]
                      )
                    )
                    : Center(),
                  ],
                ),
              )
            ),
          ]
        ),
        replacement: (cameraController != null && cameraController.value.isInitialized == true) ? 
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Transform.scale(
              scale: cameraController.value.aspectRatio / (MediaQuery.of(context).size.width / MediaQuery.of(context).size.height),
              child: Center(
                  child: AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: CameraPreview(cameraController),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          InkWell(
                            child: Icon(Icons.arrow_back_ios, color: Colors.white),
                            onTap: () => {
                              cameraController.dispose(),

                              setState((){
                                userInfo = data;
                                _loaded = true;
                                cameras = cameras;
                                cameraController = null;
                              })
                            }
                          ),
                        ]
                      )
                    ]
                  )
                )
              ),
              Container(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CustomRaisedButton(
                            child: Icon(Icons.filter),
                            onPressed: () => {
                              cameraController.dispose(),

                              setState((){
                                userInfo = data;
                                _loaded = true;
                                cameras = cameras;
                                cameraController = null;
                              })
                            }
                          ),
                          SizedBox(width: 10),
                          CustomRaisedButton(
                            child: Icon(Icons.photo_camera),
                            onPressed: () async {

                              String path = join(
                                // Store the picture in the temp directory.
                                // Find the temp directory using the `path_provider` plugin.
                                (await getTemporaryDirectory()).path,
                                '${DateTime.now()}.png',
                              );

                              await cameraController.takePicture(path);

                              cameraController.dispose();

                              setState((){
                                userInfo = data;
                                _loaded = true;
                                cameras = cameras;
                                avatar = FileImage(File(path));
                                cameraController = null;
                              });
                            }
                          ),
                          SizedBox(width: 10),
                          (cameras[1] != null)
                          ? CustomRaisedButton(
                              child: Icon(Icons.switch_camera),
                              onPressed: () => _toggleCameraLens(data)
                            )
                          : SizedBox(width: 10),
                        ],
                      ),
                      SizedBox(height: 10)
                    ],
                  ),
                )
              )
            ],
          )
        : Center(),
      )
    );
  }

  void _toggleCameraLens(data) async {
    final lensDirection =  cameraController.description.lensDirection;
    CameraDescription newDescription;
    if(lensDirection == CameraLensDirection.front){
        newDescription = cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.back);
    }
    else{
        newDescription = cameras.firstWhere((description) => description.lensDirection == CameraLensDirection.front);
    }

    if(newDescription != null){

      CameraController _cameraController = CameraController(newDescription, ResolutionPreset.high);

      await _cameraController.initialize();

      setState(() {
        _loaded = true;
        userInfo = data;
        cameras = cameras;
        cameraController = _cameraController;
      });
    }
    else{
      print('Asked camera not available');
    }
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

  Widget __accountEdit(context, data)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CustomInput(label: 'Имя', controller: nameController, placeholder: data['name'], type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('name') == true)
          ? widget.errors['name']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Фамилия', controller: lastNameController, placeholder: data['last_name'], type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('last_name') == true)
          ? widget.errors['last_name']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Отчество', controller: patronymicController, placeholder: data['patronymic'], type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('patronymic') == true)
          ? widget.errors['patronymic']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'День рождения', controller: birthdayController, placeholder: data['birthday'], type: TextInputType.number, errorText: 
          (widget.errors != null && widget.errors.containsKey('birthday') == true)
          ? widget.errors['birthday']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Телефон', controller: phoneController, placeholder: data['phone'], type: TextInputType.phone, errorText: 
          (widget.errors != null && widget.errors.containsKey('phone') == true)
          ? widget.errors['phone']
          : null ),
        SizedBox(height: 10),
        /* Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text('Мужчина'),
            RadioListTile(value: null, groupValue: null, onChanged: null)
          ]
        ), */
        Center(
          child: CustomRaisedButton(
            onPressed: () => __saveData(data),
            color: Colors.white,
            child: Text('Сохранить'),
          )
        )
      ]
    );
  }

  Future __saveData(data) async
  {
    Map errors = {};

    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return null;
    }

    if(nameController.text.length == 0)
    {
      errors.addEntries([MapEntry('name', 'Имя не должно быть пустым')]);
    }

    if(errors.length == 0)
    {
      var result = await Settings.changeAccountInfo(
        auth,
        (nameController.text == null) ?  data['name'] : nameController.text,
        (lastNameController.text == null) ? data['last_name'] : lastNameController.text,
        (patronymicController.text == null) ? data['patronymic'] : patronymicController.text,
        (birthdayController.text == null) ? data['birthday'] : birthdayController.text,
        (phoneController.text == null) ? data['phone'] : phoneController.text,
        (avatar == null) ? data['avatar'] : avatar.file
      );

      if(result == false)
      {
        //return null;
      }
    }

    setState(() {
        widget.errors = errors;
    });

  }

  Future __getUserInfo() async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return null;
    }

    await Settings.getAccountInfo(auth);

    var _userInfo = await DBProvider.db.getAccountInfo();

    cameras = await availableCameras();

    setState(() {
      cameras = cameras;
      _loaded = true;
      userInfo = _userInfo;
    });

    return _userInfo;
  }
}