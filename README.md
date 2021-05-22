# custom_image_picker

A flutter plugin that allows you to retrieve the device's images and albums in order to customize your image picker depending on your needs.


## Getting Started

### Add dependency

```yaml
dependencies:
  custom_image_picker: ^0.5.0
```


## Usage

### Import the library

```dart
import 'package:custom_image_picker/custom_image_picker.dart';
```

### Get albums:

```dart
List<PhoneAlbum> albums = [];
final customImagePicker = CustomImagePicker();
customImagePicker.getAllImages(callback: (retrievedAlbums) {
     albums = retrievedAlbums;
});
```

Each [album](https://github.com/TahaMalas/custom_image_picker/blob/master/lib/phone_album.dart) contains the following data

```dart
class PhoneAlbum {
  final String id;
  final String name;
  final String coverUri;
  final int photosCount;

  PhoneAlbum(this.id, this.name, this.coverUri, this.photosCount);

  ...
}
```

### Get photos of an album:

```dart
List<PhonePhoto> imagesOfAlbum = [];
final customImagePicker = CustomImagePicker();
 customImagePicker.getPhotosOfAlbum(
     albumID, // The id of the album you want to retrieve the images for
     page: page, // The page number defaults to '1', in each page the library returns 50 images of the album
     callback: (images) {
         imagesOfAlbum.addAll(images);
     },
   );
```

Each [photo](https://github.com/TahaMalas/custom_image_picker/blob/master/lib/phone_photo.dart) contains the following data

```dart
class PhoneAlbum {
  final String id;
  final String albumName;
  final String photoUri;

  PhonePhoto(this.id, this.albumName, this.photoUri);

  ...
}
```

## Platforms:

The library works for both Android & iOS, but it doesn't support pagination for iOS yet, we are working on delivering this feature ASAP.

## Where we are going with this

We are currently trying to make more functions available to the package, so please feel free to add any suggestions in the [issues](https://github.com/TahaMalas/custom_image_picker/issues)