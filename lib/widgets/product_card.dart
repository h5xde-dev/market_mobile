import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/pages/products/index.dart';

class ProductCard extends StatelessWidget {

  ProductCard({
    @required this.name,
    this.image,
    this.prices,
    this.minOrder,
    this.id
  });

  final String name;
  final String image;
  final Map minOrder;
  final Map prices;
  final int id;

  @override
  Widget build(BuildContext context) {
    
    return new ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 300,
        width: 100,
        decoration:  (image != null)
        ? BoxDecoration(
            image: DecorationImage(image: CachedNetworkImageProvider(image, headers: {'Host': 'g2r-market.mobile'}), fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(13),
          )
        : BoxDecoration(
            color: Colors.purple[900],
            borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: InkWell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(13)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: SvgPicture.asset('resources/svg/catalog/favorite-colored.svg')
                  )
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(13)),
                    ),
                    child: Padding(
                      padding:EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(name, style: TextStyle(fontSize:18), maxLines: 2),
                          SizedBox(height: 10),
                          Text('${prices['min']}\$ - ${prices['max']}\$', style: TextStyle(fontSize:12, fontWeight: FontWeight.bold), maxLines: 2),
                          SizedBox(height: 10),
                          Text('От ${minOrder['value']} ${minOrder['type']}', style: TextStyle(fontSize:10), maxLines: 2)
                        ]
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () => {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ProductPage(
                  productId: id,
                )
              )
            )
          },
        ),
      )
    );
  }
}