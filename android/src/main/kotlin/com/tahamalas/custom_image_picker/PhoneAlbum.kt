package com.tahamalas.custom_image_picker

class PhoneAlbum(val id: String, val name: String, val coverUri: String, val photosCount: Int) {

    fun toJson(): String {
        var string = "{\"id\": \"$id\", \"name\": \"$name\", \"coverUri\": \"$coverUri\", \"photosCount\": $photosCount} "
        return string
    }
}