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
        
        
        let websiteRoutes = router.grouped("")
        /*
         Public Routes
         1. Get Request - GET SINGLE AD
         2. Get Request - GET ALL THE COUNTRIES
         3. Get Request - GET ADS OF THE PERIMETER OF THE SELECTED DEPARTMENT
         4. Get Request - GET THE CONTACT OF THE AD
         9. Post Request - POST/REMOVE HEART TO THE AD
         */
        websiteRoutes.get("ads", String.parameter, use: getAdHandler) // 1.
        websiteRoutes.get("countries", use: countryHandler) // 2.
        websiteRoutes.get("countries", "ads", use: adsOfPerimeterHandler) // 3.
        websiteRoutes.get("ads", "contact", String.parameter, use: getContactHandler) // 4.
       
    }
    
    /*
     Function to make an API request to get all the countries and render the landing view.
     1. Function return Future<View>
     2. Creates a generic Client which Connects to remote HTTP servers and sends HTTP requests receiving HTTP responses.
     3. Sends an HTTP GET Request to a server and returns a view
     4. Return and Decode JSON response to the array of future countries. This is possible because Country conforms Encodable. FlatMap future to View.self.
     5. Create an empty array of CountryData objects.
     6. Loop countries.
     7. Get departments of the country by calling getDepartments -method.
     8. Create data object and pass the fetched data in.
     9. Add the new object to the arrayOfCountries.
     10. Create a response context which contains data (arrayOfCountries and the title) for the landing.leaf page.
     11. Return and render the view and pass the context in.
     */
    
    
    func countryHandler(_ req: Request) throws -> Future<View> { // 1.
        
        let client = try req.make(Client.self) // 2.
        
        return client.get("http://localhost:9090/api/countries/").flatMap(to: View.self) { res in // 3.
            return try res.content.decode([Country].self).flatMap(to: View.self) { countries in // 4.
                
                var arrayOfCountries = [CountryData]() // 5.
                
                for country in countries { // 6.
                    
                    let departments = try country.getDepartments(country: country, on: req) // 7.
                    let data = CountryData(country: country, departments: departments) // 8.
                    arrayOfCountries.append(data) // 9.
                }
                
                let context = CountryContext(countries: arrayOfCountries, title: "Home") // 10.
                return try req.view().render("landing", context) // 11.
            }
        }
    }
    
    
    /*
     Function to make an API request to get all the ads of the selected department and ads of the sibling department. Returns the adList view.
     1. Function return Future<View>
     2. Creates a generic Client which Connects to remote HTTP servers and sends HTTP requests receiving HTTP responses.
     3. Decode filter and unwrap rhe string.
     4. Sends an HTTP GET Request to a server and returns a view
     5. Return and Decode JSON response to AdsOfPerimeterData. FlatMap future to View.self.
     6. Return and render the view and pass the data in.
     */
  
    func adsOfPerimeterHandler(_ req: Request) throws -> Future<View> { // 1.
        
        let client = try req.make(Client.self) // 2.
        // 3.
        let filters = try req.query.decode(DepartmentFilters.self)
        guard let departmentString = (filters.department) else {throw Abort(.internalServerError)}
        
        return client.get("http://localhost:9090/api/ads/all/\(departmentString)/").flatMap(to: View.self) { res in // 4.
            return try res.content.decode(AdsOfPerimeterData.self).flatMap(to: View.self) { data in // 5.
              
                return try req.view().render("adList", data) // 6.
                
            }
        }
    }
    
    /*
     Function to make an API request to get a single ad. Returns the offer view.
     1. Function return Future<View>
     2. Creates a generic Client which Connects to remote HTTP servers and sends HTTP requests receiving HTTP responses.
     3. Decode filter and unwrap the string.
     4. Sends an HTTP GET Request to a server and returns a view
     5. Return and Decode JSON response to AdData. FlatMap future to View.self.
     6. Return and render the view and pass the data in.
     */
    
    func getAdHandler(_ req: Request) throws -> Future<View> { // 1.
        let client = try req.make(Client.self) // 2.
        let string = try req.parameters.next(String.self) // 3.
       
        return client.get("http://localhost:9090/api/ads/\(string)/").flatMap(to: View.self) { res in // 4.
            return try res.content.decode(AdData.self).flatMap(to: View.self) { data in // 5.
                return try req.view().render("offer", data) // 6.
                
            }
        }
    }
    
    /*
     Function to make an API request to get a contact. Returns the contact view.
     1. Function return Future<View>
     2. Creates a generic Client which Connects to remote HTTP servers and sends HTTP requests receiving HTTP responses.
     3. Decode filter and unwrap the string.
     4. Sends an HTTP GET Request to a server and returns a view
     5. Return and Decode JSON response to Contact. FlatMap future to View.self.
     6. Create a link by calling a method which creates one.
     7. Create a context.
     8. Return and render the view and pass the data in.
     */
    
    func getContactHandler(_ req: Request) throws -> Future<View> { // 1.
        let client = try req.make(Client.self) // 2.
        let string = try req.parameters.next(String.self) // 3.
    
        return client.get("http://localhost:9090/api/contacts/\(string)/contact").flatMap(to: View.self) { res in // 4.
        return try res.content.decode(Contact.self).flatMap(to: View.self) { data in // 5.
            
           let link = data.manipulateFBProfileLink(fbProfileURL: data.facebookLink) ?? "This link is broken" // 6.
            
            let context = ContactContext(title: "Contact", name: data.contactName, messenger: link) // 7.
            return try req.view().render("contact", context) // 8.
    
            }
        }
    }  
    
}


struct DepartmentFilters: Content {
    var country: String?
    var department: String?
}

struct Filters: Content {
    var ad : String?
}

