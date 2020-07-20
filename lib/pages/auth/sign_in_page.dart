import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/widgets/custom_input.dart';
import 'package:g2r_market/widgets/sign_in_button.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/authorisation.dart';
import 'dart:async';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

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

  Padding __buildContent(context) {
    return Padding(
      padding:EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SvgPicture.asset('resources/svg/main/logo.svg', width: 200),
          SizedBox(height: 48.0),
          CustomInput(placeholder: 'E-mail', controller: emailController, type: TextInputType.emailAddress, errorText: 'E-mail неверный'),            
          SizedBox(height: 8.0),
          CustomInput(placeholder: 'Пароль', controller: passwordController, type: TextInputType.visiblePassword, errorText: 'Пароль неверный',),  
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
            onPressed: (){},
          ),
          SizedBox(height: 16.0),
          Center(
            child: Text('Забыли пароль')
          )
        ],
      )
    );
  }

  Future __authValidation(context) async
  {
    bool result = await Auth.login(emailController.text, passwordController.text);

    if(result)
    {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => LandingPage(selectedPage: 1)
        )
      );

    } else
    {
      
    }
  }
}