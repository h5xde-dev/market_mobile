import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/pages/products/index.dart';
import 'package:g2r_market/services/favorite.dart';

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  ProductCard({
    Key key,
    @required this.name,
    this.image,
    this.prices,
    this.minOrder,
    this.id,
    this.favorite,
    this.auth
  }) : super(key: key);

  final String name;
  final String image;
  final Map minOrder;
  final Map prices;
  final int id;
  bool favorite;
  final auth;

  @override
  _ProductCardState createState() => _ProductCardState();
}
class _ProductCardState extends State<ProductCard> {

  @override
  Widget build(BuildContext context) {
    
    return new ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 300,
        width: 100,
        decoration:  (widget.image != null)
        ? BoxDecoration(
            image: DecorationImage(image: CachedNetworkImageProvider(widget.image, headers: {'Host': 'g2r-market.mobile'}), fit: BoxFit.cover),
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
                  child: InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: (widget.favorite != false) ? SvgPicture.asset('resources/svg/catalog/favorite-colored-active.svg') : SvgPicture.asset('resources/svg/catalog/favorite-colored.svg')
                    ),
                    onTap: () => __updateFavorite(),
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
                          Text(widget.name, style: TextStyle(fontSize:18), maxLines: 2),
                          SizedBox(height: 10),
                          Text('${widget.prices['min']}\$ - ${widget.prices['max']}\$', style: TextStyle(fontSize:12, fontWeight: FontWeight.bold), maxLines: 2),
                          SizedBox(height: 10),
                          Text('От ${widget.minOrder['value']} ${widget.minOrder['type']}', style: TextStyle(fontSize:10), maxLines: 2)
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
                  productId: widget.id,
                  auth: widget.auth,
                )
              )
            )
          },
        ),
      )
    );
  }

  Future __updateFavorite() async
  {
    var function;

    if(widget.auth != Null)
    {
      if (widget.favorite == true)
      {
        function = Favorite.removeProduct(await widget.auth, widget.id);

      } else
      {
        function = Favorite.addProduct(await widget.auth, widget.id);
      }

      await function;

      setState((){
        widget.favorite = (widget.favorite) ? false : true;
      });
    }
  }
}