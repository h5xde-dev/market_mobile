import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorPage extends ErrorWidget {

  ErrorPage({
    Key key
  }):super({
    key: key
  });
  
  Widget buildError(BuildContext context, FlutterErrorDetails errorDetails) {

    print(errorDetails.stack);

    return Scaffold(
      body: Center(
        child: Text(
          "Произошла ошибка, проверьте соединение с интернетом",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
 }
}