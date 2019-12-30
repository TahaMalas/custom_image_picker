import 'package:custom_image_picker_example/gallery/gallery_page.dart';
import 'package:custom_image_picker_example/images/images_page.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text('Gallery'),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => GalleryPage()));
            },
          ),
          RaisedButton(
            child: Text('Images'),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ImagesPage()));
            },
          ),
        ],
      ),
    );
  }
}
