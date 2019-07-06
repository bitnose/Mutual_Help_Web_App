//
//  Ad.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation

final class Ad : Codable {
    
    var id : UUID?
    var note : String
    var generosity : Int
    var images : [String]?
    var show : Bool = true
    
    // Initialize
    init(note : String, generosity: Int, images: [String]? = nil, show: Bool = true) {
        
        self.note = note
        self.generosity = generosity
        self.images = images
        self.show = show
    }
}
