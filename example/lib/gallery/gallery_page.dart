import 'dart:async';
import 'dart:io';

import 'package:custom_image_picker/custom_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<PhoneAlbum> phoneAlbums = [];

  @override
  void initState() {
    super.initState();
    getGallery();
  }

  Future<void> getGallery() async {
    List<PhoneAlbum> allImages;
    try {
      allImages = await CustomImagePicker.getAlbums;
    } on PlatformException {}

    setState(() {
      phoneAlbums = allImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Custom image picker plugin'),
      ),
      body: phoneAlbums.isNotEmpty
          ? ListView.builder(
              itemCount: phoneAlbums.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () async {
                    final photos = await CustomImagePicker.getPhotosOfAlbum(
                        phoneAlbums[index].id);
                    print('photos are ${photos.length}');
                  },
                  title: Text(
                    phoneAlbums[index].name,
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  subtitle: Text(
                    phoneAlbums[index].photosCount.toString(),
                    style: TextStyle(color: Colors.grey.withAlpha(200)),
                  ),
                  leading: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          File(phoneAlbums[index].coverUri),
                        ),
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
