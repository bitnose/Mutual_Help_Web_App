//
//  City.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation

/// City Model which Comforms Codable
/// - id : <UUID?>
/// - city : <String>
final class City : Codable {
    
    var id : UUID?
    var city : String
    
    /// Initialization
    init(city : String) {
        self.city = city        
    }
}
