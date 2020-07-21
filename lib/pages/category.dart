import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/products/catalog.dart';
import 'package:g2r_market/widgets/category_button.dart';
import 'package:g2r_market/services/categories.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}


class _CategoryPageState extends State<CategoryPage> {

  bool _loaded = false;
  var _data;
      
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
    
    return _loaded ? __content(context, _data, null) : FutureBuilder(
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
                      Center()                
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                    child: Center()
                  ),
                  Expanded(
                    child: spinkit ?? __categoriesList(data)
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

  __categoriesList(categories)
  {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index){
        return CategoryButton(
          text: Text(categories[index]['title'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12),),
          color: Colors.white,
          onPressed: () => Navigator.push(context, AnimatedSizeRoute(
              builder: (context) => CatalogPage(category: categories[index], childs: categories[index]['children'])
            )
          )
           /* () => setState((){
            _prevData = categories;
            _data = categories[index]['children'];
            _loaded = true;
          }) */
        );
      }
    );
  }

  Future __getContent() async
  {
    var data = await Category.getAll();

    setState(() {
      _data = data;
      _loaded = true;
    });

    return data;
  }
}