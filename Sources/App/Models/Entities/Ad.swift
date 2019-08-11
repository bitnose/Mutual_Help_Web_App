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
/// - show : <Bool> = true
/// - contactID : UUID
/// - cityID : UUID

final class Ad : Codable {
    
    var id : UUID?
    var note : String
    var generosity : Int
    var images : [String]?
    var show : Bool = true
    var contactID : UUID
    var cityID : UUID
    
    /// Initialize
    init(note: String, generosity: Int, images: [String]? = nil, show: Bool = true, contactID: UUID, cityID: UUID) {
        
        self.note = note
        self.generosity = generosity
        self.images = images
        self.show = show
        self.contactID = contactID
        self.cityID = cityID
    }
}
