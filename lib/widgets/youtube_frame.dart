import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeFrame extends StatelessWidget {
  
  YouTubeFrame({
    this.url
  });

  final String url;

  @override
  Widget build(BuildContext context) {

    var videoId = RegExp(r"v=(.*)").firstMatch(url).group(1);

    var thumbnail = 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

    return InkWell(
      onTap: () => _launchURL(),
      child: Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(image: CachedNetworkImageProvider(thumbnail), fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(13)
        ),
        child: Center(
          child: Icon(Icons.play_circle_filled, color: Colors.white, size: 100,),
        )
      )
    );
  }

  _launchURL() async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}