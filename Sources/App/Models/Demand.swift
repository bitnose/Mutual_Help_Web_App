//
//  Demand.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
// Demand Model

final class Demand : Codable {
    
    var id : UUID?
    var demand : String
    
    init(demand : String) {
        self.demand = demand
       
    }
}
