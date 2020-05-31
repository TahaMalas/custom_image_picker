import 'dart:async';
import 'dart:convert';

import 'package:custom_image_picker/callbacks_enum.dart';
import 'package:custom_image_picker/custom_image_picker.dart';
import 'package:custom_image_picker/phone_album.dart';
import 'package:custom_image_picker/phone_photo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

export 'package:custom_image_picker/phone_album.dart';
export 'package:custom_image_picker/phone_photo.dart';

typedef void MultiUseCallback(dynamic msg);
typedef void CancelListening();

class CustomImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('custom_image_picker');

  Map<int, MultiUseCallback> _callbacksById = new Map();

  Future<void> _methodCallHandler(MethodCall call) async {
    print('arguments are ${call.arguments["id"]}');
    print('callbacks are $_callbacksById');
    switch (call.method) {
      case 'callListener':
        if (call.arguments["id"] as int == CallbacksEnum.GET_IMAGES.index) {
          _callbacksById[call.arguments["id"]](call.arguments["args"]);
        } else if (call.arguments["id"] as int ==
            CallbacksEnum.GET_GALLERY.index) {
          String jsonString = call.arguments["args"];

          print('json String is $jsonString');
          final list = json.decode(jsonString) as List<dynamic>;
          final List<PhoneAlbum> phoneAlbums = [];
          for (dynamic item in list) {
            phoneAlbums.add(PhoneAlbum.fromMap(item as Map<String, dynamic>));
          }
          print('items are $phoneAlbums');
          _callbacksById[call.arguments["id"]](phoneAlbums);
        } else if (call.arguments["id"] as int ==
            CallbacksEnum.GET_IMAGES_OF_GALLERY.index) {
          String jsonString = call.arguments["args"];

          print('json String is $jsonString');
          final list = json.decode(jsonString) as List<dynamic>;
          final List<PhonePhoto> phonePhoto = [];
          for (dynamic item in list) {
            phonePhoto.add(PhonePhoto.fromMap(item as Map<String, dynamic>));
          }
          _callbacksById[call.arguments["id"]](phonePhoto);
        }
//        _callbacksById[call.arguments["id"]](call.arguments["args"]);
        break;
      default:
        print(
            'TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
    }

    _channel.invokeMethod("cancelListening", call.arguments["id"]);
    _callbacksById.remove(call.arguments["id"]);
  }

  Future<CancelListening> _startListening(
      MultiUseCallback callback, CallbacksEnum callbacksEnum,
      {dynamic args}) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    int currentListenerId = callbacksEnum.index;
    _callbacksById[currentListenerId] = callback;
    await _channel.invokeMethod(
      "startListening",
      {
        'id': currentListenerId,
        'args': args,
      },
    );
    return () {
      _channel.invokeMethod("cancelListening", currentListenerId);
      _callbacksById.remove(currentListenerId);
    };
  }

  Future<CancelListening> getAllImages(
      {@required MultiUseCallback callback}) async {
    return await _startListening(callback, CallbacksEnum.GET_IMAGES);
//    List<dynamic> object = await _channel.invokeMethod('getAllImages');
//    return object;
  }

  Future<CancelListening> getAlbums(
      {@required MultiUseCallback callback}) async {
    return await _startListening(callback, CallbacksEnum.GET_GALLERY);

//    String jsonString = await _channel.invokeMethod('getAlbumList');
//    print('json String is $jsonString');
//    final list = json.decode(jsonString) as List<dynamic>;
//    final List<PhoneAlbum> phoneAlbums = [];
//    for (dynamic item in list) {
//      phoneAlbums.add(PhoneAlbum.fromMap(item as Map<String, dynamic>));
//    }
//    return phoneAlbums;
  }

  Future<CancelListening> getPhotosOfAlbum(String albumID,
      {@required MultiUseCallback callback, int page = 1}) async {
    return await _startListening(
      callback,
      CallbacksEnum.GET_IMAGES_OF_GALLERY,
      args: {
        'albumID': albumID,
        'page': page,
      },
    );

//    String jsonString =
//        await _channel.invokeMethod('getPhotosOfAlbum', albumID);
//    print('json String is $jsonString');
//    final list = json.decode(jsonString) as List<dynamic>;
//    final List<PhonePhoto> phonePhoto = [];
//    for (dynamic item in list) {
//      phonePhoto.add(PhonePhoto.fromMap(item as Map<String, dynamic>));
//    }
//    return phonePhoto;
  }
}
