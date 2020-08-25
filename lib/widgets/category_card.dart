import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'dart:ui';
import 'package:g2r_market/pages/products/catalog.dart';
import 'package:g2r_market/static/api_methods.dart';

class CategoryCard extends StatelessWidget {

  CategoryCard({
    @required this.name,
    this.image,
    this.id,
    this.children,
  });

  final String name;
  final String image;
  final int id;
  final List children;

  @override
  Widget build(BuildContext context) {
    
    return new ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 300,
        width: 100,
        decoration:  (image != null)
        ? BoxDecoration(
            image: DecorationImage(image: CachedNetworkImageProvider(image, headers: {'Host': API_HOST}), fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(13),
          )
        : BoxDecoration(
            color: Colors.purple[900],
            borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BackdropFilter(
                filter: ImageFilter.blur(),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
                  ),
                  child: Padding(
                    padding:EdgeInsets.all(16),
                    child: Text(name, style: TextStyle(fontSize:10), maxLines: 2)
                  ),
                ),
              )
            ],
          ),
          onTap: () => {
            Navigator.push(context, AnimatedScaleRoute(
              builder: (context) => CatalogPage(
                  category: {'id': id, 'children': children},
                  childs: children,
                )
              )
            )
          },
        ),
      )
    );
  }
}