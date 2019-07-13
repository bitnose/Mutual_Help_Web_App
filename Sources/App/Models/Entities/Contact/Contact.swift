//
//  Contact.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
// Contact Model

final class Contact : Codable {
    
    var id : UUID?
    var adLink : String
    var facebookLink : String
    var contactName : String
    
    // Initialize
    init(adLink : String, facebookLink : String, contactName : String) {
        
        self.adLink = adLink
        self.facebookLink = facebookLink
        self.contactName = contactName
    }
}
