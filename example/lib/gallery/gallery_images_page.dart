import 'dart:async';
import 'dart:io';

import 'package:custom_image_picker/custom_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GalleryImagesPage extends StatefulWidget {

  final String albumID;

  const GalleryImagesPage({Key key, @required this.albumID}) : super(key: key);

  @override
  _GalleryImagesPageState createState() => _GalleryImagesPageState();
}

class _GalleryImagesPageState extends State<GalleryImagesPage> {
  List<PhonePhoto> images = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Future.delayed(Duration(milliseconds: 1000)).then((_) => getGallery()));
  }



  Future<void> getGallery() async {
    List<PhonePhoto> allImages = [];
    try {
      allImages = await CustomImagePicker.getPhotosOfAlbum(widget.albumID);
    } on PlatformException {}

    setState(() {
      images = allImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom image picker plugin'),
      ),
      body: images.isNotEmpty
          ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 4 / 5,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Center(
            child: Container(
              child: Image.file(
                File(
                  images[index].photoUri,
                ),
              ),
            ),
          );
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
