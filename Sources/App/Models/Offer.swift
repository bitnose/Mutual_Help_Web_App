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
   
    init(offer : String) {
        self.offer = offer
      
    }
}
