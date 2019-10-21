//
//  Offer.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
/**
 # Offer Model
 - id : UUID?
 - offer : String
 - adID : UUID
*/
final class Offer : Codable {
    
    var id : UUID?
    var offer : String
    var adID : UUID
    /// # Init
    init(offer: String, adID: UUID) {
        self.offer = offer
        self.adID = adID
      
    }
}
