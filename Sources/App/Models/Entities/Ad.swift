//
//  Ad.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation

/// # Ad Class which comforms Codable
/// - id : <UUID?>
/// - note : <String>
/// - generosity : <Int>
/// - images : <[Strings]>?
/// - contactID : UUID
/// - cityID : UUID
/// - userID : UUID (The user who created the ad)

final class Ad : Codable {
    
    var id : UUID?
    var note : String
    var generosity : Int?
    var images : [String]?
    var cityID : UUID
    var userID : UUID
    
    /// # Initialize
    init(note: String, generosity : Int?, images: [String]? = nil, cityID: UUID, userID: UUID) {
        
        self.note = note
        self.generosity = generosity
        self.images = images
        self.cityID = cityID
        self.userID = userID
    }
}
