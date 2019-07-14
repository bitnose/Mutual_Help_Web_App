//
//  Heart.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
// Heart Model

final class Heart : Codable {
    
    var id : UUID?
    var heartCreatedAt : Date?
    var token : String
    var adID : UUID
    
    init(token: String, adID: UUID) {
        self.token = token
        self.adID = adID
    }
}
