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
    var adID : UUID
    
    init(demand : String, adID: UUID) {
        self.demand = demand
        self.adID = adID
    }
}
