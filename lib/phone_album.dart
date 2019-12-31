class PhoneAlbum {
  final String id;
  final String name;
  final String coverUri;
  final int photosCount;

//  final List<PhonePhoto> albumPhotos;

  PhoneAlbum(this.id, this.name, this.coverUri, this.photosCount);

  factory PhoneAlbum.fromMap(Map<String, dynamic> item) {
//    final albums = item["albumPhotos"];
//    final List<PhonePhoto> albumsPhoto = [];
//    for (dynamic item in albums) {
//      albumsPhoto.add(PhonePhoto.fromMap(item as Map<String, dynamic>));
//    }
    return PhoneAlbum(
        item["id"], item["name"], item["coverUri"], item['photosCount']);
  }
}
