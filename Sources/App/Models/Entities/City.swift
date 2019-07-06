//
//  City.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation

// City Model

final class City : Codable {
    
    var id : UUID?
    var city : String
   
    
    init(city : String) {
        self.city = city        
    }
}
