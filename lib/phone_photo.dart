class PhonePhoto {
  final String id;
  final String albumName;
  final String photoUri;

  PhonePhoto(this.id, this.albumName, this.photoUri);

  factory PhonePhoto.fromMap(Map<String, dynamic> map) {
    return PhonePhoto(map["id"], map["albumName"], map["photoUri"]);

  }

  @override
  String toString() {
    return 'PhonePhoto{id: $id, albumName: $albumName, photoUri: $photoUri}';
  }
}
