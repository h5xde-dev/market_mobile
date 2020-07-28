import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/sign_in_button.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/authorisation.dart';

// ignore: must_be_immutable
class RegistrationPage extends StatefulWidget {

  RegistrationPage({
    Key key
  }) : super(key: key);

  Map errors;

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}


class _RegistrationPageState extends State<RegistrationPage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: __buildContent(context)
    );
  }

  Column __buildContent(context) {
    return Column(
      children: <Widget>[
        Padding(
          padding:EdgeInsets.symmetric(horizontal: 16.0, vertical: 42),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: Icon(Icons.arrow_back_ios),
                onTap:  () => Navigator.pop(context),
              )               
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SvgPicture.asset('resources/svg/main/logo.svg', width: 200),
                    SizedBox(height: 48.0),
                    CustomInput(label: 'Имя', controller: nameController, type: TextInputType.text, errorText: 
                      (widget.errors != null && widget.errors.containsKey('name') == true)
                      ? widget.errors['name']
                      : null ),
                    SizedBox(height: 8.0),
                    CustomInput(label: 'E-mail', controller: emailController, type: TextInputType.emailAddress, errorText: 
                      (widget.errors != null && widget.errors.containsKey('email') == true)
                      ? widget.errors['email']
                      : null ),        
                    SizedBox(height: 8.0),
                    CustomInput(label: 'Пароль', controller: passwordController, type: TextInputType.visiblePassword, errorText:
                      (widget.errors != null && widget.errors.containsKey('password') == true)
                      ? widget.errors['password']
                      : null ),
                    SizedBox(height: 8.0),
                    CustomInput(label: 'Подтверждение пароля', controller: passwordConfirmController, type: TextInputType.visiblePassword, errorText: 
                      (widget.errors != null && widget.errors.containsKey('password_confirmation') == true)
                      ? widget.errors['password_confirmation']
                      : null ),
                    Divider(color: Colors.black),
                    SignInButton(
                      text: 'Зарегистрироваться',
                      textColor: Colors.white,
                      color: Colors.deepPurple[700],
                      onPressed: () => __authValidation(context)
                    ),
                  ],
                )
              )
            ],
          )
        )
      ],
    );
  }

  __authValidation(context) async
  {
    Map errors = {};

    if(passwordController.text != passwordConfirmController.text)
    {
      errors.addEntries([MapEntry('password_confirmation', 'Пароль не свопадает с подтверждением')]);
    }

    if(passwordController.text.length < 8)
    {
      errors.addEntries([MapEntry('password', 'Пароль должен быть от 8 символов')]);
    }

    if(emailController.text.length == 0)
    {
      errors.addEntries([MapEntry('email', 'Необходимо указать E-mail')]);
    }

    if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text))
    {
      errors.addEntries([MapEntry('email', 'E-mail указан неверно')]);
    }

    if(nameController.text.length <= 1)
    {
      errors.addEntries([MapEntry('name', 'Имя должно содержать более одного символа')]);
    }

    setState(() {
      widget.errors = errors;
    });

    if(errors.length == 0)
    {
      List serverErrors = await Auth.register(nameController.text, emailController.text, passwordController.text);

      if(serverErrors.length == 0)
      {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => LandingPage(selectedPage: 0)
          )
        );

      } else
      {
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)
              ),
              title: Text(serverErrors.first, style: TextStyle(fontSize: 12),overflow: TextOverflow.clip,),
            );
          }
        );
      } 
    }
  }
}