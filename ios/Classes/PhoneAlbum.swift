//
//  PhoneAlbum.swift
//  custom_image_picker
//
//  Created by Malas Taha on 12/29/19.
//

import Foundation

class PhoneAlbum {
    
    let id:String
    let name:String
    let coverUri:String
    let photosCount: Int
    
    init(id: String, name: String, coverUri: String, photosCount: Int) {
        self.id = id
        self.name = name
        self.coverUri = coverUri
        self.photosCount = photosCount
    }
    
    func toJson() -> String {
        return "{\"id\": \"\(id)\", \"name\": \"\(name)\", \"coverUri\": \"\(coverUri)\", \"photosCount\": \(photosCount)}"
    }
    
}
