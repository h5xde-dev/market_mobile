import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  
  const CustomInput({
    this.placeholder: '',
    this.height: 50,
    this.width: 0,
    this.controller,
    this.errorText,
    this.formatter,
    this.label,
    this.type,
  });

  final String placeholder;
  final String label;
  final double height;
  final double width;
  final TextEditingController controller;
  final TextInputFormatter formatter;
  final TextInputType type;
  final String errorText;

  @override
  Widget build(BuildContext context) {

    controller.text = placeholder;

    return Container(
      height: height,
      width: (width == 0) ? MediaQuery.of(context).size.width : width,
      child: TextFormField(
        controller: controller,
        obscureText: (type == TextInputType.visiblePassword),
        inputFormatters: (formatter != null)
        ? <TextInputFormatter>[
            formatter
          ]
        : null,
        autofocus: false,
        style: TextStyle(fontSize: 15.0, color: Colors.black),
        keyboardType: type,
        decoration: InputDecoration(
          errorText: errorText,
          hintText: placeholder,
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          hintStyle: TextStyle(fontSize: 15.0, color: Colors.black),
          contentPadding:
          const EdgeInsets.only(left: 14.0, bottom: 12.0, top: 0.0),

          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple[700]),
            borderRadius: BorderRadius.circular(8),
          ),

          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
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