//
//  Country.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

// Country Model
final class Country : Codable {
    
    var id : UUID?
    var country : String

    init(country : String) {
        self.country = country
        
    }
    
    func getDepartments(country: Country, on req: Request) throws -> Future<[Department]> {
        
        let client = try req.make(Client.self) // 2
        
        guard let id = country.id else {throw Abort(.internalServerError)}
        return client.get("http://localhost:9090/api/countries/\(id)/departments/").flatMap(to: [Department].self) { response in // 3
            let departments = try response.content.decode([Department].self)
            return departments
        }
        
    }

}



