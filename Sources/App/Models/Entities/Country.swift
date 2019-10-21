//
//  Country.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

/// #  Country Model conforms Codable
/// - id : <UUID>?
/// - country : String
final class Country : Codable {
    
    var id : UUID?
    var country : String
    /// # Init
    init(country : String) {
        self.country = country
        
    }


}



