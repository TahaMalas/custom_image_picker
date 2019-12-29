//
//  AlbumModel.swift
//  custom_image_picker
//
//  Created by Malas Taha on 12/29/19.
//

import Foundation

class PhonePhoto {
    let id:Int
    let albumName:String
    let photoUri:String
    init(id:Int, albumName:String, photoUri:String) {
      self.id = id
      self.albumName = albumName
      self.photoUri = photoUri
    }
}
