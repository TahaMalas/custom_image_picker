package com.tahamalas.custom_image_picker

class PhonePhoto(val id: String, val albumName: String, val photoUri: String) {
    fun toJson() : String{
        return "{\"id\": \"$id\", \"albumName\": \"$albumName\", \"photoUri\": \"$photoUri\"}"
    }
}