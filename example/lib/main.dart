import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:custom_image_picker/phone_album.dart';
import 'package:flutter/services.dart';
import 'package:custom_image_picker/custom_image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<PhoneAlbum> phoneAlbums;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Custom image picker plugin'),
        ),
        body: ListView.builder(
          itemCount: phoneAlbums.length,
          itemBuilder: (context, index) {
            return ListTile(
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
        ),
      ),
    );
  }
}
