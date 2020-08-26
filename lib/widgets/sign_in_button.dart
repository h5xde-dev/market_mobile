import 'package:flutter/material.dart';
import 'custom_raised_button.dart';

class SignInButton extends CustomRaisedButton {
  SignInButton({
    @required String text,
    Color color,
    Color textColor,
    bool isLoading: false,
    VoidCallback onPressed
  }) :  assert(text != null),
        super(
          child: (isLoading == true) 
          ? CircularProgressIndicator()
          : Text(
            text, style:TextStyle(color: textColor, fontSize: 15.0)
          ),
          color:color,
          onPressed: onPressed,
        );
}