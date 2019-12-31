//
//  AlbumModel.swift
//  custom_image_picker
//
//  Created by Malas Taha on 12/29/19.
//

import Foundation

class PhonePhoto {
    let id:String
    let albumName:String
    let photoUri:String
    init(id:String, albumName:String, photoUri:String) {
      self.id = id
      self.albumName = albumName
      self.photoUri = photoUri
    }
}
