//
//  City.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation

/// # City Model which Comforms Codable
/// - id : <UUID?>
/// - city : <String>
/// - departmentID : <UUID>
final class City : Codable {
    
    var id : UUID?
    var city : String
    var departmentID : UUID
    
    /// # Initialization
    init(city : String, departmentID : UUID) {
        self.city = city
        self.departmentID = departmentID
    }
}

