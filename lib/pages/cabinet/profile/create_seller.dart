import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/services/profile.dart';
import 'package:g2r_market/services/settings.dart';
import 'package:g2r_market/widgets/custom__file_picker.dart';
import 'package:g2r_market/widgets/custom__multiple_file_picker.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class SellerCreatePage extends StatefulWidget{
  

  final double padding = 10;

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

  File companyLogo;
  List<FileImage> mainBanner = [];
  List<FileImage> promoBanner = [];
  File descriptionBanner;
  List<FileImage> otherImages = [];


  bool _loaded = false;
  Map userInfo;

  Map allowedCountries = {
    'RU': 'Русский',
    'ZH': 'Китайский',
    'EN': 'Английский'
  };
      
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
    ? __content(context, allowedCountries, null)
    : FutureBuilder(
      future: __getProfilesList(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError || snapshot.data == 'NOT_AUTHORIZED')
              return SignInPage(fromMain: false);
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
                    child: (spinkit != null) ? spinkit : ListView(
                      children: [__accountEdit(context)]
                    )
                  )
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

  Widget __accountEdit(context)
  {

    List<DropdownMenuItem> countries = [];

    for(var country in allowedCountries.entries)
    {
      countries.add(
        DropdownMenuItem(
          child: Text('${country.value}'),
          value: country.key.toString().toLowerCase()
        ),
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Информация о компании', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: widget.padding),
        DropdownButton(
          hint: SizedBox(width: MediaQuery.of(context).size.width - 64, child:Text('Язык профиля')),
          items: countries,
          onChanged: (item)
          {
            print(item);
          }
        ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Название компании', controller: companyNameController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('company_name') == true)
          ? widget.errors['company_name']
          : null ),
        SizedBox(height: widget.padding),
        CountryCodePicker(
          onChanged: (CountryCode item){
            print(item.code);
          },
          initialSelection: 'RU',
          showCountryOnly: true,
          showOnlyCountryWhenClosed: true,
          alignLeft: false,
        ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Область/Штат/республика/край', controller: regionController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('region') == true)
          ? widget.errors['region']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Город', controller: cityController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('city') == true)
          ? widget.errors['city']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Индекс', controller: indexController, type: TextInputType.number, errorText: 
          (widget.errors != null && widget.errors.containsKey('index') == true)
          ? widget.errors['index']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Улица', controller: streetController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('street') == true)
          ? widget.errors['street']
          : null ),
        SizedBox(height: widget.padding),
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
        SizedBox(height: widget.padding * 2),
        Text('Контактная информация', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Имя', controller: nameController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('name') == true)
          ? widget.errors['name']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Фамилия', controller: lastNameController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('last_name') == true)
          ? widget.errors['last_name']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Отчество', controller: patronymicController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('patronymic') == true)
          ? widget.errors['patronymic']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Телефон', controller: numberPhoneController, type: TextInputType.number, errorText: 
          (widget.errors != null && widget.errors.containsKey('number_phone') == true)
          ? widget.errors['number_phone']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Должность', controller: positionController, type: TextInputType.text, errorText: 
          (widget.errors != null && widget.errors.containsKey('position') == true)
          ? widget.errors['position']
          : null ),
        SizedBox(height: widget.padding),
        CustomInput(label: 'Мобильный телефон', controller: numberPhoneMobileController, type: TextInputType.number, errorText: 
          (widget.errors != null && widget.errors.containsKey('number_phone_mobile') == true)
          ? widget.errors['number_phone_mobile']
          : null ),
        SizedBox(height: widget.padding),
        SizedBox(height: 5),
        CustomMultipleFilePicker(
          choosenImages: mainBanner,
          text: "Баннер компании",
          onPressed: () async {

            List<FileImage> _mainBanner = [];

            List<File> _images = await FilePicker.getMultiFile(
              type: FileType.image,
              allowCompression: true
            );

            if( _images.isNotEmpty)
            {
              for (var _banner in _images)
              {
                _mainBanner.add(FileImage(_banner));
              }

              setState((){
                mainBanner = _mainBanner;
              });
            }
          },
          afterRemove: () {
            setState((){
              mainBanner = mainBanner;
            });
          }
        ),
        SizedBox(height: widget.padding),
        SizedBox(height: 5),
        CustomFilePicker(
          text: "Логотип компании",
          choosenImage: companyLogo,
          onPressed: () async {
            companyLogo = await FilePicker.getFile(
              type: FileType.image,
              allowCompression: true
            );

            setState(() {
              companyLogo = companyLogo;
            });
          },
          afterRemove: (){
            setState(() {
              companyLogo = null;
            });
          },
        ),
        SizedBox(height: widget.padding),
        CustomMultipleFilePicker(
          choosenImages: promoBanner,
          text: "Изображения для рекламного баннера",
          onPressed: () async {

            List<FileImage> _promoBanner = [];

            List<File> _images = await FilePicker.getMultiFile(
              type: FileType.image,
              allowCompression: true
            );

            if( _images.isNotEmpty)
            {
              for (var _banner in _images)
              {
                _promoBanner.add(FileImage(_banner));
              }

              setState((){
                promoBanner = _promoBanner;
              });
            }
          },
          afterRemove: () {
            setState((){
              promoBanner = promoBanner;
            });
          }
        ),
        SizedBox(height: widget.padding),
        CustomFilePicker(
          text: "Фото для блока описание",
          choosenImage: companyLogo,
          onPressed: () async {
            companyLogo = await FilePicker.getFile(
              type: FileType.image,
              allowCompression: true
            );

            setState(() {
              companyLogo = companyLogo;
            });
          },
          afterRemove: (){
            setState(() {
              companyLogo = null;
            });
          },
        ),
        SizedBox(height: widget.padding),
        SizedBox(height: 5),
        CustomMultipleFilePicker(
          choosenImages: otherImages,
          text: "Другие фото компании",
          onPressed: () async {

            List<FileImage> _otherImages = [];

            List<File> _images = await FilePicker.getMultiFile(
              type: FileType.image,
              allowCompression: true
            );

            if( _images.isNotEmpty)
            {
              for (var _banner in _images)
              {
                _otherImages.add(FileImage(_banner));
              }

              setState((){
                otherImages = _otherImages;
              });
            }
          },
          afterRemove: () {
            setState((){
              otherImages = otherImages;
            });
          }
        ),
        SizedBox(height: widget.padding),
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

  Future __getProfilesList() async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return 'NOT_AUTHORIZED';
    }

    var profiles = await Profile.getProfiles(auth, 'seller');

    for (var profile in profiles)
    {
      allowedCountries.remove(profile['localisation'].toString().toUpperCase());
    }

    setState(() {
      allowedCountries = allowedCountries;
      _loaded = true;
    });

    return allowedCountries;
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