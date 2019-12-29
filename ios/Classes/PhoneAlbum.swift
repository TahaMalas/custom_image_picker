//
//  PhoneAlbum.swift
//  custom_image_picker
//
//  Created by Malas Taha on 12/29/19.
//

import Foundation

class PhoneAlbum {
    
    let id:Int
    let name:String
    let coverUri:String
    let albumPhotos: Array<PhonePhoto>
    
    init(id: Int, name: String, coverUri: String, albumPhotos: Array<PhonePhoto>) {
        self.id = id
        self.name = name
        self.coverUri = coverUri
        self.albumPhotos = albumPhotos
    }
    
}
