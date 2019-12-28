import 'dart:async';

import 'package:flutter/services.dart';

class CustomImagePicker {
  static const MethodChannel _channel =
      const MethodChannel('custom_image_picker');

  static Future<Object> get getAllImages async {
    Map<dynamic, dynamic> object = await _channel.invokeMethod('getAllImages');
    return object;
  }
}
