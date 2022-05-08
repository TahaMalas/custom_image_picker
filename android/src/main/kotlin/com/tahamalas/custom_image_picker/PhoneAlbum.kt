package com.tahamalas.custom_image_picker

class PhoneAlbum(val id: String, val name: String, val coverUri: String, val photosCount: Int) {

    override fun toString(): String {
        return "{\"id\": \"$id\", \"name\": \"$name\", \"coverUri\": \"$coverUri\", \"photosCount\": $photosCount} "
    }
}