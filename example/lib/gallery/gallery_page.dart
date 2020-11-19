import 'dart:async';
import 'dart:io';

import 'package:custom_image_picker/custom_image_picker.dart';
import 'package:custom_image_picker_example/gallery/gallery_images_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<PhoneAlbum> phoneAlbums = [];
  final customImagePicker = CustomImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getGallery());
  }

  Future<void> getGallery() async {
    try {
      await customImagePicker.getAlbums(callback: (msg) {
        print('the message is $msg');
        setState(() {
          phoneAlbums = msg;
        });
      });
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 61, 61, 61),
      body: Column(
        children: <Widget>[
          AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: false,
            elevation: 0,
            title: const Text('Select Album'),
          ),
          phoneAlbums.isNotEmpty
              ? Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: phoneAlbums.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GalleryImagesPage(
                                albumID: phoneAlbums[index].id,
                              ),
                            ),
                          );
                        },
                        title: Text(
                          phoneAlbums[index].name,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          phoneAlbums[index].photosCount.toString(),
                          style: TextStyle(color: Colors.grey.withAlpha(200)),
                        ),
                        leading: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
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
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
