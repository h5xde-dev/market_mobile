import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/pages/auth/registration.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/sign_in_button.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/authorisation.dart';
import 'dart:async';

// ignore: must_be_immutable
class SignInPage extends StatefulWidget {

  final bool fromMain;

  Map errors;

  SignInPage({
    Key key,
    this.fromMain: false
  }) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}


class _SignInPageState extends State<SignInPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
              (!widget.fromMain)
              ? InkWell(
                child: Icon(Icons.arrow_back_ios),
                onTap:  () => Navigator.pop(context),
              )
              : Center()                
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SvgPicture.asset('resources/svg/main/logo.svg', width: 200),
                    SizedBox(height: 48.0),
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
                    SignInButton(
                      text: 'Войти',
                      textColor: Colors.black,
                      color: Colors.white,
                      onPressed: () => __authValidation(context),
                    ),
                    Divider(color: Colors.black),
                    SizedBox(height: 8.0),
                    SignInButton(
                      text: 'Регистрация',
                      textColor: Colors.white,
                      color: Colors.deepPurple[700],
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) =>RegistrationPage()
                          )
                        );
                      },
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: Text('Забыли пароль')
                    )
                  ],
                )
              )
            ],
          )
        )
      ],
    );
  }

  Future __authValidation(context) async
  {

    Map errors = {};

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

    setState(() {
      widget.errors = errors;
    });

    if(errors.length == 0)
    {
      bool result = await Auth.login(emailController.text, passwordController.text);

      if(result)
      {
        (widget.fromMain)
        ? Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => new LandingPage(selectedPage: 0)
          )
        )
        : Navigator.pop(context);

      } else
      {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)
              ),
              title: Text('Неправильно указаны данные для входа'),
            );
          },
        );
      }
    }
  }
}