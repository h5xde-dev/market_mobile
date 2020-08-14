import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/settings.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class SellerCreatePage extends StatefulWidget{

  final profiles;  
  Map errors;

  SellerCreatePage({
    this.profiles,
    Key key
  }) : super(key: key);

  @override
  _SellerCreatePageState createState() => _SellerCreatePageState();
}

class _SellerCreatePageState extends State<SellerCreatePage> {

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController indexController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController numberHomeController = TextEditingController();
  final TextEditingController numberBuildController = TextEditingController();
  final TextEditingController numberRoomController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController patronymicController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController numberPhoneController = MaskedTextController(mask: '00000000000');
  final TextEditingController numberPhoneMobileController = MaskedTextController(mask: '00000000000');
  

  final TextEditingController companyDescriptionController = TextEditingController();
  final TextEditingController companyYoutubeLinkController = TextEditingController();

  List<CameraDescription> cameras = [];
  CameraController cameraController;
  FileImage avatar;
  Map userInfo;
      
  @override
  Widget build(BuildContext context) {
    
    return __content(context);
  }

  __content(context)
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
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [__accountEdit(context)]
                      )
                    )
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
                            onPressed: () async {
                              cameraController.dispose();

                              File _avatar = await FilePicker.getFile(
                                type: FileType.custom,
                                allowedExtensions: ['jpg','png','jpeg']
                              ); 

                              setState((){
                                cameras = cameras;
                                avatar = FileImage(_avatar);
                                cameraController = null;
                              });
                            }
                          ),
                          SizedBox(width: 10),
                          CustomRaisedButton(
                            child: Icon(Icons.photo_camera),
                            onPressed: () async {

                              String path = join(
                                (await getTemporaryDirectory()).path,
                                '${DateTime.now()}.png',
                              );

                              await cameraController.takePicture(path);

                              cameraController.dispose();

                              setState((){
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
                              onPressed: () => _toggleCameraLens()
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

  void _toggleCameraLens() async {
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

  Widget __accountEdit(context)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Информация о компании', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: 10),
        CustomInput(label: 'Название компании', controller: companyNameController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('company_name') == true)
          ? widget.errors['company_name']
          : null ),
        SizedBox(height: 10),
        CountryCodePicker(
          onChanged: (CountryCode item){
            print(item.code);
          },
          initialSelection: 'RU',
          showCountryOnly: true,
          showOnlyCountryWhenClosed: true,
          alignLeft: false,
        ),
        SizedBox(height: 10),
        CustomInput(label: 'Область/Штат/республика/край', controller: regionController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('region') == true)
          ? widget.errors['region']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Город', controller: cityController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('city') == true)
          ? widget.errors['city']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Индекс', controller: indexController, type: TextInputType.number, errorText: 
          (widget.errors != null && widget.errors.containsKey('index') == true)
          ? widget.errors['index']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Улица', controller: streetController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('street') == true)
          ? widget.errors['street']
          : null ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomInput(label: 'Дом', width: 100, controller: numberHomeController, type: TextInputType.number, errorText: 
              (widget.errors != null && widget.errors.containsKey('number_home') == true)
              ? widget.errors['number_home']
              : null ),
            SizedBox(width: 10),
            CustomInput(label: 'Корпус', width: 100, controller: numberBuildController, type: TextInputType.number, errorText: 
              (widget.errors != null && widget.errors.containsKey('number_build') == true)
              ? widget.errors['number_build']
              : null ),
            SizedBox(width: 10),
            CustomInput(label: 'Помещение', width: 120, controller: numberRoomController, type: TextInputType.number, errorText: 
              (widget.errors != null && widget.errors.containsKey('number_room') == true)
              ? widget.errors['number_room']
              : null ),
          ],
        ),
        SizedBox(height: 10),
        Text('Контактная информация', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: 10),
        CustomInput(label: 'Имя', controller: nameController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('name') == true)
          ? widget.errors['name']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Фамилия', controller: lastNameController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('last_name') == true)
          ? widget.errors['last_name']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Отчество', controller: patronymicController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('patronymic') == true)
          ? widget.errors['patronymic']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Телефон', controller: numberPhoneController, type: TextInputType.number, errorText: 
          (widget.errors != null && widget.errors.containsKey('number_phone') == true)
          ? widget.errors['number_phone']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Должность', controller: positionController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('position') == true)
          ? widget.errors['position']
          : null ),
        SizedBox(height: 10),
        CustomInput(label: 'Мобильный телефон', controller: numberPhoneMobileController, type: TextInputType.number, errorText: 
          (widget.errors != null && widget.errors.containsKey('number_phone_mobile') == true)
          ? widget.errors['number_phone_mobile']
          : null ),
        SizedBox(height: 10),
        Text('Главный баннер магазина: '),
        SizedBox(height: 5),
        Container(
          child: Column(
            children: <Widget>[
              CustomRaisedButton(
                color: Colors.white,
                child: Icon(Icons.photo_album),
                onPressed: (){}
              )
            ]
          )
        ),
        SizedBox(height: 10),
        Text('Логотип компании: '),
        SizedBox(height: 5),
        Container(
          child: Column(
            children: <Widget>[
              CustomRaisedButton(
                color: Colors.white,
                child: Icon(Icons.photo_album),
                onPressed: (){}
              )
            ]
          )
        ),
        SizedBox(height: 10),
        Text('Изображения для рекламного баннера: '),
        SizedBox(height: 5),
        Container(
          child: Column(
            children: <Widget>[
              CustomRaisedButton(
                color: Colors.white,
                child: Icon(Icons.photo_album),
                onPressed: (){}
              )
            ]
          )
        ),
        SizedBox(height: 10),
        Text('Фото для блока описание: '),
        SizedBox(height: 5),
        Container(
          child: Column(
            children: <Widget>[
              CustomRaisedButton(
                color: Colors.white,
                child: Icon(Icons.photo_album),
                onPressed: (){}
              )
            ]
          )
        ),
        SizedBox(height: 10),
        Text('Другие фото компании: '),
        SizedBox(height: 5),
        Container(
          child: Column(
            children: <Widget>[
              CustomRaisedButton(
                color: Colors.white,
                child: Icon(Icons.photo_album),
                onPressed: (){}
              )
            ]
          )
        ),
        Center(
          child: CustomRaisedButton(
            //onPressed: () => __saveData(data),
            color: Colors.white,
            child: Text('Сохранить'),
          )
        )
      ]
    );
  }

  /* Future __saveData(data) async
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

      setState(() {
        _loaded = false;
      });

      if(result == false)
      {
        //return null;
      }
    } else
    {
      setState(() {
        widget.errors = errors;
      });
    }
  } */
}