import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/user.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/pages/cabinet/profile/list.dart';
import 'package:g2r_market/pages/manager/list_profiles.dart';
import 'package:g2r_market/services/profile.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';
import 'package:country_code_picker/country_code_picker.dart';

// ignore: must_be_immutable
class BuyerCreatePage extends StatefulWidget{
  

  final double padding = 10;
  final profiles;
  final companyId;

  BuyerCreatePage({
    @required this.profiles,
    this.companyId: 0,
    Key key
  }) : super(key: key);

  @override
  _BuyerCreatePageState createState() => _BuyerCreatePageState();
}

class _BuyerCreatePageState extends State<BuyerCreatePage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController indexController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController numberHomeController = TextEditingController();
  final TextEditingController numberBuildController = TextEditingController();
  final TextEditingController numberRoomController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController patronymicController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController numberPhoneController = MaskedTextController(mask: '00000000000');
  final TextEditingController numberPhoneMobileController = MaskedTextController(mask: '00000000000');

  String countryCompany;
  String languageCompany;

  bool _loaded = false;
  Map userInfo;

  Map allowedCountries = {
    'RU': 'Русский',
    'ZH': 'Китайский',
    'EN': 'Английский'
  };

  String selectedCountryHint;
      
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
                      children: [
                        Form(
                          key: _formKey,
                          child: __accountEdit(context),
                        )
                      ]
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
          value: country
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
          hint: SizedBox(
            width: MediaQuery.of(context).size.width - 64,
            child: Text((selectedCountryHint == null) ? 'Язык профиля' : selectedCountryHint)
          ),
          items: countries,
          onChanged: (item)
          {
            setState(() {
              languageCompany = item.key.toString();
              selectedCountryHint = item.value.toString();
            });
          }
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Название компании',
          placeholder: companyNameController.text,
          controller: companyNameController,
          type: TextInputType.text,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          },  
        ),
        SizedBox(height: widget.padding),
        CountryCodePicker(
          onChanged: (CountryCode item){
            setState(() {
              countryCompany = item.code.toLowerCase();
            });
          },
          initialSelection: 'RU',
          showCountryOnly: true,
          showOnlyCountryWhenClosed: true,
          alignLeft: false,
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Область/Штат/республика/край',
          controller: regionController,
          placeholder: regionController.text,
          type: TextInputType.text,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          },
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Город',
          placeholder: cityController.text,
          controller: cityController,
          type: TextInputType.text,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          },
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Индекс',
          placeholder: indexController.text,
          controller: indexController,
          type: TextInputType.number,
          validator: (value) {
            return null;
          }
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Улица',
          controller: streetController,
          placeholder: streetController.text,
          type: TextInputType.text,
          validator: (value) {
            return null;
          }, 
        ),
        SizedBox(height: widget.padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomInput(
              label: 'Дом',
              width: 100,
              placeholder: numberHomeController.text,
              controller: numberHomeController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
            SizedBox(width: 10),
            CustomInput(
              label: 'Корпус',
              width: 100,
              placeholder: numberBuildController.text,
              controller: numberBuildController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
            SizedBox(width: 10),
            CustomInput(
              label: 'Помещение',
              placeholder: numberRoomController.text,
              width: 120,
              controller: numberRoomController,
              type: TextInputType.number,
              validator: (value) {
                return null;
              }
            ),
          ],
        ),
        SizedBox(height: widget.padding * 2),
        Text('Контактная информация', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold
        )),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Имя',
          placeholder: nameController.text,
          controller: nameController,
          type: TextInputType.text,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          }, 
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Фамилия',
          placeholder: lastNameController.text,
          controller: lastNameController,
          type: TextInputType.text,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          },
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Отчество',
          placeholder: patronymicController.text,
          controller: patronymicController,
          type: TextInputType.text,
          validator: (value) {
            return null;
          }, 
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Телефон',
          placeholder: numberPhoneController.text,
          controller: numberPhoneController,
          type: TextInputType.number,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          },
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Должность',
          placeholder: positionController.text,
          controller: positionController,
          type: TextInputType.text,
          validator: (value) {
            if(value.isEmpty)
            {
              return 'Поле не заполнено';
            }

            return null;
          },
        ),
        SizedBox(height: widget.padding),
        CustomInput(
          label: 'Мобильный телефон',
          placeholder: numberPhoneMobileController.text,
          controller: numberPhoneMobileController,
          type: TextInputType.number,
          validator: (value) {
            return null;
          }
        ),
        SizedBox(height: widget.padding),
        Center(
          child: CustomRaisedButton(
            onPressed: () async => await createProfile(context),
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

  Future createProfile(context) async
  {
    var auth = await DBProvider.db.getAuth();
    
    if(auth == Null)
    {
      return null;
    }

    if(languageCompany == null)
    {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13)
            ),
            title: Text('Не выбран язык профиля'),
          );
        },
      );

      return false;
    }

    if(countryCompany == null)
    {
      countryCompany = "ru";
    }

    if (_formKey.currentState.validate())
    {

      Map<String, String> _data = {};
      Map _files = {};

      List roles = await UserHelper.getRoles();

      _data = {
        'company_name': companyNameController.text.toString(),
        'region': regionController.text.toString(),
        'country': countryCompany.toUpperCase(),
        'city': cityController.text.toString(),
        'index': indexController.text.toString(),
        'street': streetController.text.toString(),
        'number_home': numberHomeController.text.toString(),
        'number_build': numberBuildController.text.toString(),
        'number_room': numberRoomController.text.toString(),
        'name': nameController.text.toString(),
        'last_name': lastNameController.text.toString(),
        'patronymic': patronymicController.text.toString(),
        'position': positionController.text.toString(),
        'number_phone': numberPhoneController.text.toString(),
        'profile_type': 'buyer',
        'localisation': languageCompany.toLowerCase(),
      };

      if(roles.contains('site_manager'))
      {
        _data['company_user'] = widget.companyId.toString();
      }

      var result = await Profile.create(auth, _data, _files);

      if(result == true)
      {
        (widget.companyId == 0)
        ? Navigator.pushReplacement(context, AnimatedScaleRoute(
            builder: (context) => ProfileListPage(
                auth: auth,
              )
            )
          )
        : Navigator.pushReplacement(context, AnimatedScaleRoute(
            builder: (context) => CompanyProfileListPage(
                auth: auth,
                companyId: widget.companyId,
              )
            )
          );
      }
    }
  }
}