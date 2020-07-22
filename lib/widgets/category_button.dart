import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CategoryButton extends StatelessWidget {
  
  CategoryButton({
    this.text,
    this.icon,
    this.color,
    this.borderRaius: 8.0,
    this.onPressed,
    this.width: 100.0
  }) : assert(borderRaius != null);

  final Text text;
  final SvgPicture icon;
  final Color color;
  final double borderRaius;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
        width: 100,
        child: RaisedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  width: 100,
                  child: text,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(borderRaius)
            )
          ),
          color: color,
          onPressed: onPressed,
        ),
      )
    );
  }
}