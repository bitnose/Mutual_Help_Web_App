//
//  Token.swift
//  App
//
//  Created by Sötnos on 26/07/2019.
//

import Foundation

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: UUID
    
    init(token: String, userID: UUID) {
        self.token = token
        self.userID = userID
    }
}
