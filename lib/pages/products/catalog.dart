import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:g2r_market/helpers/db.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/widgets/bottom_navbar.dart';
import 'package:g2r_market/widgets/product_card.dart';
import 'package:g2r_market/services/catalog.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CatalogPage extends StatefulWidget {

  final Map category;
  final List childs;
  final int page;

  CatalogPage({
    Key key,
    this.category,
    this.childs,
    this.page: 1,
  }) : super(key: key);

  @override
  _CatalogPageState createState() => _CatalogPageState();
}


class _CatalogPageState extends State<CatalogPage> {
      
  @override
  Widget build(BuildContext context) {

    final spinkit = Center(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SpinKitRing(color: Colors.blue[900], size: 175),
          SvgPicture.asset('resources/svg/main/spinner.svg', alignment: Alignment.center, width: 150),
        ],
      )
    );
    
    return FutureBuilder(
      future: __getContent(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return __content(context, null, spinkit);
          case ConnectionState.waiting:
            return __content(context, null, spinkit);
          default:
            if (snapshot.hasError)
              return __content(context, null, spinkit);
            else {
              return __content(context, snapshot.data, null);
            }
        }
      },
    );
  }

  __content(context, data, spinkit)
  {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: BottomNavBar(),
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height * .35,
            decoration: BoxDecoration(
              color: Color.fromRGBO(247,247,247, 100)
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height:20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Icon(Icons.arrow_back_ios),
                        onTap:  () => Navigator.pop(context),
                      ),
                      InkWell(
                        child: Icon(Icons.filter_list),
                        onTap:  () => {},
                      ),               
                    ],
                  ),
                  SizedBox(height:20),
                  Column(
                    children: <Widget>[
                      ([null].contains(spinkit) && ![null].contains(widget.childs))
                      ?  Container(
                          height: 50,
                          width: size.width,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.childs.length,
                            itemBuilder: (BuildContext context, int i)
                            {
                              return InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(color: Colors.black54)
                                  ),
                                  margin: EdgeInsets.only(left: 10),
                                  height: 50,
                                  child: Center(
                                    child: Text('${widget.childs[i]['title']}'),
                                  )
                                ),
                                onTap: () => Navigator.push(context, AnimatedSizeRoute(
                                    builder: (context) => CatalogPage(category: widget.childs[i], childs: widget.childs[i]['children'])
                                  )
                                )
                              );
                            }
                          ),
                        ) 
                      : Center(),
                    ],
                  ),
                  Expanded(
                    child: ([null].contains(spinkit)) ? __productCards(data) : spinkit,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          ),
        ]
      ),
    );
  }

  __productCards(products)
  {

    var auth = DBProvider.db.getAuth(1);

    return StaggeredGridView.countBuilder(
      itemCount: products.length,
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      staggeredTileBuilder: (int index) =>  new StaggeredTile.count(2, 3),
      itemBuilder: (BuildContext context, int index) {
        return ProductCard(
          name: products[index]['title'],
          image: products[index]['preview_image'],
          prices: {'min': products[index]['price_min'], 'max': products[index]['price_max']},
          minOrder: {'value': products[index]['min_order'], 'type': products[index]['order_type']},
          id: products[index]['id'],
          auth: auth,
          favorite: (products[index].containsKey('favorite') == true) ? products[index]['favorite'] : false,
        );
      });
  }

  Future __getContent() async
  {
    var data = await Catalog.getProducts(widget.category['id'], widget.page);

    return data;
  }
}