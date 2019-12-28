package com.tahamalas.custom_image_picker

import java.util.*

data class PhoneAlbum(val id: Int, val name: String, val coverUri: String, val albumPhotos: Vector<PhonePhoto>)