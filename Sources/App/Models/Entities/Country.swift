//
//  Country.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

/// Country Model conforms Codable
/// - id : <UUID>?
/// - country : String
final class Country : Codable {
    
    var id : UUID?
    var country : String

    init(country : String) {
        self.country = country
        
    }
    
    /// Method to fetch departments of the selected country
    /// 1. Make a client
    /// 2. Get the country ID
    /// 3. Make a get request and map the response to Future<[Department]>
    /// 4. Decode the response data to <[Department]>
    /// 5. Return departments
    
    func getDepartments(country: Country, on req: Request) throws -> Future<[Department]> {
        
        let client = try req.make(Client.self) // 1
        
        guard let id = country.id else {throw Abort(.internalServerError)} // 2
        return client.get("http://localhost:9090/api/countries/\(id)/departments/").flatMap(to: [Department].self) { response in // 3
            let departments = try response.content.decode([Department].self) // 4
            return departments // 5
        }
    }

}



