import 'dart:io';

import 'package:flutter/material.dart';
import 'package:g2r_market/widgets/custom_raised_button.dart';

class CustomFilePicker extends StatelessWidget {

  CustomFilePicker({
    @required this.text,
    @required this.choosenImage,
    this.color: Colors.white,
    this.onPressed,
    this.afterRemove,
    this.crossAxisCount: 2,
    this.mainAxisSpacing: 2,
    this.crossAxisSpacing: 2,
  });
  
  final String text;
  final Color color;
  final File choosenImage;
  final Function onPressed;
  final Function afterRemove;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    
    return new Column(
      children: <Widget>[
        (choosenImage == null)
        ? Center()
        : Container(
            height: 200,
            child: new GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, mainAxisSpacing: mainAxisSpacing, crossAxisSpacing: crossAxisSpacing),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(image: FileImage(choosenImage), fit: BoxFit.fill),
                    color: Colors.black
                  ),
                  height: 200,
                  width: 200,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Icon(Icons.close, color: Colors.white),
                        )
                      ),
                      onTap: (){
                        choosenImage.delete();
                        afterRemove();
                      }
                    ),
                  )
                )
              ],
            ),
          ),
        CustomRaisedButton(
          color: color,
          child: Text(text),
          onPressed: onPressed,
          width: MediaQuery.of(context).size.width,
        )
      ]
    );
  }
}