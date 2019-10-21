//
//  Token.swift
//  App
//
//  Created by Sötnos on 26/07/2019.
//

import Foundation

/**
 # Token Model
 - id : UUID?
 - token : String
 - userID : UUID
 */
final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: UUID
    /// # Init
    init(token: String, userID: UUID) {
        self.token = token
        self.userID = userID
    }
}
