package com.tahamalas.custom_image_picker

class PhoneAlbum(val id: Int, val name: String, val coverUri: String, val albumPhotos: MutableList<PhonePhoto>) {

    private var photosCount = 0

    fun fromJson(): String {
        var string = "{\"id\": $id, \"name\": \"$name\", \"coverUri\": \"$coverUri\", \"photosCount\": $photosCount, \"albumPhotos\": [ "
        for (phonePhoto in albumPhotos) {
            string += phonePhoto.toJson()
            if (albumPhotos.indexOf(phonePhoto) != albumPhotos.size - 1)
                string += ", "
        }
        string += "]}"
        return string
    }

    fun increasePhotosCount() {
        photosCount++
    }

}