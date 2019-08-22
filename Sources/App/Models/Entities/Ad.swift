//
//  Ad.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation

/// Ad Class which comforms Codable
/// - id : <UUID?>
/// - note : <String>
/// - generosity : <Int>
/// - images : <[Strings]>?
/// - contactID : UUID
/// - cityID : UUID

final class Ad : Codable {
    
    var id : UUID?
    var note : String
    var generosity : Int
    var images : [String]?
    var contactID : UUID
    var cityID : UUID
    
    /// Initialize
    init(note: String, generosity: Int, images: [String]? = nil, contactID: UUID, cityID: UUID) {
        
        self.note = note
        self.generosity = generosity
        self.images = images
        self.contactID = contactID
        self.cityID = cityID
    }
}
