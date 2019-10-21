//
//  Heart.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
/**
 # Heart Model
 - id : UUID?
 - heartCreatedAt : Date?
 - adID : UUID
 - userID : UUID
*/
final class Heart : Codable {
    
    var id : UUID?
    var heartCreatedAt : Date?
    var adID : UUID
    var userID : UUID
    /// # Init
    init(adID: UUID, userID : UUID) {

        self.adID = adID
        self.userID = userID
    }
}
