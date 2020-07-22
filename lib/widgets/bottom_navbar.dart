import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:g2r_market/landing_page.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key key,
    this.activeId: 1,
  }) : super(key: key);

  final int activeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      height: 80,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BottomNavItem(
            iconPath: 'resources/svg/main/home.svg',
            isActive: (activeId ==1) ? true : false,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => LandingPage(selectedPage: 0)
              )
            ),
          ),
          BottomNavItem(
            iconPath: 'resources/svg/main/list.svg',
            isActive: (activeId == 2) ? true : false,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => LandingPage(selectedPage: 1)
              )
            ),
          ),
          BottomNavItem(
            iconPath: 'resources/svg/main/order.svg',
            isActive: (activeId == 3) ? true : false,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => LandingPage(selectedPage: 2)
              )
            ),
          ),
          BottomNavItem(
            iconPath: 'resources/svg/main/cog.svg',
            isActive: (activeId == 4) ? true : false,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) => LandingPage(selectedPage: 3)
              )
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  
  const BottomNavItem({
    Key key,
    this.iconPath,
    this.onTap,
    this.isActive = false,
  }) : super(key: key);

  final String iconPath;
  final onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SvgPicture.asset(iconPath, color: isActive ? Colors.deepPurple : Colors.black)
        ],
      ),
    );
  }
}