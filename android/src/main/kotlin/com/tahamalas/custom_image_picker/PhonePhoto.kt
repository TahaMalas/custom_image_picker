package com.tahamalas.custom_image_picker

class PhonePhoto(val id: Int, val albumName: String, val photoUri: String) {
    fun toJson() : String{
        return "{\"id\": $id, \"albumName\": \"$albumName\", \"photoUri\": \"$photoUri\"}"
    }
}