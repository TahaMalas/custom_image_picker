import 'dart:async';
import 'dart:io';

import 'package:custom_image_picker/custom_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagesPage extends StatefulWidget {
  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  List<dynamic> images = [];

  @override
  void initState() {
    super.initState();
    getGallery();
  }

  Future<void> getGallery() async {
    List<dynamic> allImages;
    try {
      allImages = await CustomImagePicker.getAllImages;
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
                        images[index],
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
