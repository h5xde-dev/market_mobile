import 'package:flutter/material.dart';
import 'package:g2r_market/widgets/flat_chat/action_button.dart';

class FlatMessageInputBox extends StatelessWidget {
  final Widget prefix;
  final Widget suffix;
  final TextEditingController textController;
  final bool roundedCorners;
  final Function onChanged;
  final Function onSubmitted;
  FlatMessageInputBox({this.prefix, this.suffix, this.roundedCorners, this.onChanged, this.onSubmitted, this.textController});

  @override
  Widget build(BuildContext context) {

    double cornerRadius() {
      if(roundedCorners != null && roundedCorners == true) {
        return 60.0;
      } else {
        return 0.0;
      }
    }

    double padding() {
      if(roundedCorners != null && roundedCorners == true) {
        return 12.0;
      } else {
        return 8.0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cornerRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 20,
            blurRadius: 20,
            offset: Offset(0, -5), // changes position of shadow
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cornerRadius()),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: padding(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            prefix ?? SizedBox(width: 0, height: 0,),
            Expanded(
              child: TextField(
                //onSubmitted: onSubmitted,
                controller: textController,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: "Введите сообщение...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0,),
                ),
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark
                ),
              ),
            ),
            suffix ?? SizedBox(width: 0, height: 0,),
            FlatActionButton(
              icon: Icon(
                Icons.send,
                size: 24.0,
                color: Colors.deepPurple[700],
              ),
              onPressed: onSubmitted
            ),
          ],
        ),
      ),
    );
  }
}