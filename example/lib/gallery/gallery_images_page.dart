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

  final customImagePicker = CustomImagePicker();
  final _controller = ScrollController();
  int page = 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels ==
          _controller.position.maxScrollExtent) {
        print('get new images $page');
        page++;
        getImagesOfGallery();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => getImagesOfGallery());
  }

  Future<void> getImagesOfGallery() async {
    try {
      await customImagePicker.getPhotosOfAlbum(widget.albumID, page: page,
          callback: (msg) {
        print('the message is $msg');
        setState(() {
          images.addAll(msg);
        });
      });
    } on PlatformException {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom image picker plugin'),
      ),
      body: images.isNotEmpty
          ? GridView.builder(
              controller: _controller,
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
                      repeat: ImageRepeat.noRepeat,
                      fit: BoxFit.cover,
                      matchTextDirection: true,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.none,
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
