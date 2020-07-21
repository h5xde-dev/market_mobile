import 'package:flutter/material.dart';

class AnimatedSizeRoute<T> extends MaterialPageRoute<T> {
  AnimatedSizeRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child)
    {
      return new SizeTransition(sizeFactor: animation, child: child);
    }
}

class AnimatedScaleRoute<T> extends MaterialPageRoute<T> {
  AnimatedScaleRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child)
    {
      return new ScaleTransition(scale: animation, child: child);
    }
}