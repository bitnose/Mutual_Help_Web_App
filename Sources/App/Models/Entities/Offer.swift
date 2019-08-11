//
//  Offer.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
// Offer Model

final class Offer : Codable {
    
    var id : UUID?
    var offer : String
    var adID : UUID
   
    init(offer: String, adID: UUID) {
        self.offer = offer
        self.adID = adID
      
    }
}
