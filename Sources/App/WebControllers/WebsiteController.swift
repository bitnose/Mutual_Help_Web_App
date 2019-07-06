//
//  WebsiteController.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor
import Leaf

/*
 Controller which handles API calls and rendering pages. This Controller conforms RouteCollection
 1. Implement boot(router:) as required by RouteCollection.
 */

struct WebsiteController : RouteCollection {
    
    // 1
    func boot(router: Router) throws {
        
        
        let websiteRoutes = router.grouped("api")
        /*
         Public Routes
         4. Get Request - GET SINGLE AD
         5. Get Request - GET ALL THE COUNTRIES
         6. Get Request - GET DEPARTMENTS OF THE COUNTRY
         7. Get Request - GET ADS OF THE PERIMETER OF THE SELECTED DEPARTMENT
         8. Get Request - GET THE CONTACT OF THE AD
         9. Post Request - POST/REMOVE HEART TO THE AD
         */
        
        websiteRoutes.get("countries", use: countryHandler)
        
    }
    
    /*
     Function to make an API request to get all the countries and render the landing view.
     1.
     2.
     3.
     */
    
    
    func countryHandler(_ req: Request) throws -> Future<View> { // 1
        // Creates a generic Client
        let client = try req.make(Client.self)
        
        return client.get("http://localhost:8080/api/countries/").flatMap(to: View.self) { res in
            let countries = try res.content.decode([Country].self)
            let context = CountryContext(countries: countries)
            return try req.view().render("landing", context)
        }
    }
}

struct CountryContext : Encodable {
    let countries : Future<[Country]>
}
