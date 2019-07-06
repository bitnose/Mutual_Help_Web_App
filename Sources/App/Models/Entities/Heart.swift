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
    
    init(token: String) {
        self.token = token
    }
}
