import 'dart:async';
import 'dart:convert';

import 'package:custom_image_picker/custom_image_picker.dart';
import 'package:custom_image_picker/phone_album.dart';
import 'package:custom_image_picker/phone_photo.dart';
import 'package:flutter/services.dart';

export 'package:custom_image_picker/phone_album.dart';
export 'package:custom_image_picker/phone_photo.dart';

typedef void MultiUseCallback(dynamic msg);
typedef void CancelListening();

class CustomImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('custom_image_picker');

  int _nextCallbackId = 0;
  Map<int, MultiUseCallback> _callbacksById = new Map();

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callListener':
        _callbacksById[call.arguments["id"]](call.arguments["args"]);
        break;
      default:
        print(
            'TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
    }
  }

  Future<CancelListening> startListening(MultiUseCallback callback) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    int currentListenerId = _nextCallbackId++;
    _callbacksById[currentListenerId] = callback;
    await _channel.invokeMethod("startListening", currentListenerId);
    return () {
      _channel.invokeMethod("cancelListening", currentListenerId);
      _callbacksById.remove(currentListenerId);
    };
  }

  static Future<List<dynamic>> get getAllImages async {
    List<dynamic> object = await _channel.invokeMethod('getAllImages');
    return object;
  }

  static Future<List<PhoneAlbum>> get getAlbums async {
    String jsonString = await _channel.invokeMethod('getAlbumList');
    print('json String is $jsonString');
    final list = json.decode(jsonString) as List<dynamic>;
    final List<PhoneAlbum> phoneAlbums = [];
    for (dynamic item in list) {
      phoneAlbums.add(PhoneAlbum.fromMap(item as Map<String, dynamic>));
    }
    return phoneAlbums;
  }

  static Future<List<PhonePhoto>> getPhotosOfAlbum(String albumID) async {
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
