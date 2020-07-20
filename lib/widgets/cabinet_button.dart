import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CabinetButton extends StatelessWidget {
  
  CabinetButton({
    this.text,
    this.icon,
    this.counter,
    this.color,
    this.borderRaius: 8.0,
    this.onPressed,
    this.height: 50.0,
    this.width: 300
  }) : assert(borderRaius != null);

  final Text text;
  final SvgPicture icon;
  final int counter;
  final Color color;
  final double borderRaius;
  final double height;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
        height: 50.0,
        width: width,
        child: RaisedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              (icon == null) ? Center() : icon,
              text,
              (counter == null) ? Center() : Container(
                height: 30,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.deepPurple
                ),
                child: Center(
                  child: Text('$counter', style: TextStyle(color: Colors.white, fontSize: 10), maxLines: 1,),
                )
              )
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