//
//  Country.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation

// Country Model
final class Country : Codable {
    
    var id : UUID?
    var country : String

    init(country : String) {
        self.country = country
        
    }
}
