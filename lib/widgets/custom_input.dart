import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  
  const CustomInput({
    this.placeholder,
    this.height: 50,
    this.controller,
    this.errorText,
    this.type
  });

  final String placeholder;
  final double height;
  final TextEditingController controller;
  final TextInputType type;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: TextField(
        controller: controller,
        autofocus: false,
        style: TextStyle(fontSize: 15.0, color: Colors.black),
        keyboardType: type,
        decoration: InputDecoration(
          //errorText: errorText,
          filled: true,
          fillColor: Colors.white,
          hintText: placeholder,
          hintStyle: TextStyle(fontSize: 15.0, color: Colors.black),
          contentPadding:
          const EdgeInsets.only(left: 14.0, bottom: 12.0, top: 0.0),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple[700]),
            borderRadius: BorderRadius.circular(8),
          ),

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),

        ),
      ),
    );
  }
}