import 'dart:async';
import 'dart:convert';
import 'package:custom_image_picker/phone_album.dart';
import 'package:custom_image_picker/phone_photo.dart';
import 'package:flutter/services.dart';
import 'package:custom_image_picker/custom_image_picker.dart';

export 'package:custom_image_picker/phone_album.dart';
export 'package:custom_image_picker/phone_photo.dart';

class CustomImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('custom_image_picker');

  static Future<List<dynamic>> get getAllImages async {
    List<dynamic> object = await _channel.invokeMethod('getAllImages');
    return object;
  }

  static Future<List<PhoneAlbum>> get getAlbums async {
    String jsonString = await _channel.invokeMethod('getAlbums');
    print('json String is $jsonString');
    final list = json.decode(jsonString) as List<dynamic>;
    final List<PhoneAlbum> phoneAlbums = [];
    for (dynamic item in list) {
      phoneAlbums.add(PhoneAlbum.fromMap(item as Map<String, dynamic>));
    }
    return phoneAlbums;
  }

  static Future<List<PhonePhoto>> getPhotosOfAlbum(int albumID) async {
    String jsonString =
        await _channel.invokeMethod('getPhotosOfAlbum', albumID);
    print('json String is $jsonString');
    final list = json.decode(jsonString) as List<dynamic>;
    final List<PhonePhoto> phonePhoto = [];
    for (dynamic item in list) {
      phonePhoto.add(PhonePhoto.fromMap(item as Map<String, dynamic>));
    }
    return phonePhoto;
  }
}
