import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:g2r_market/helpers/navigator.dart';
import 'package:g2r_market/pages/auth/sign_in_page.dart';
import 'package:g2r_market/pages/category.dart';
import 'package:g2r_market/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:g2r_market/landing_page.dart';
import 'package:g2r_market/services/categories.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:g2r_market/helpers/db.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

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

    return Stack(
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
                    SvgPicture.asset('resources/svg/main/logo.svg', alignment: Alignment.bottomLeft,),

                    InkWell(
                      child: SvgPicture.asset('resources/svg/main/user.svg', alignment: Alignment.bottomRight,),
                      onTap: () => {__checkAuth(context)},
                    ),                        
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(
                      color: Colors.black
                    )]
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      border: InputBorder.none
                    ),
                  )
                ),
                Expanded(
                  child: spinkit ?? __categoriesCards(data)
                ),
                SizedBox(height: 20),
              ],
            ),
          )
        ),
      ]
    );
  }

  __categoriesCards(categories)
  {
    return StaggeredGridView.countBuilder(
      itemCount: categories.length,
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      staggeredTileBuilder: (int index) =>  new StaggeredTile.count( (index == categories.length - 1) ? 4 : 2, (index == categories.length - 1) ? 1 : 2.2),
      itemBuilder: (BuildContext context, int index) {
        if(index != categories.length - 1)
        {
          return CategoryCard(
            name: categories[index]['title'],
            image: categories[index]['banner'],
            id: categories[index]['id'],
            children: categories[index]['children'],
          );
        } else
        {
          return ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.purple[900],
                  borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: InkWell(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Все категории', style: TextStyle(fontSize:20, color: Colors.white), maxLines: 2)
                  ],
                ),
                onTap: () => {
                  Navigator.push(context, AnimatedScaleRoute(
                      builder: (context) => CategoryPage()
                    )
                  )
                },
              ),
            )
          );
        }
      });
  }

  Future __getContent() async
  {
    var data = await Category.getPopular();

    setState(() {
      _data = data;
      _loaded = true;
    });

    return data;
  }

  Future __checkAuth(context) async
  {
    var auth = await DBProvider.db.getAuth();

    [Null].contains(auth)

    ? Navigator.push(context, AnimatedSizeRoute(
          builder: (context) => SignInPage()
        )
      )

    : Navigator.push(context, AnimatedSizeRoute(
          builder: (context) => LandingPage(selectedPage: 3)
        )
      );
  }
}