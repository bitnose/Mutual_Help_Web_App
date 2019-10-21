//
//  CityRequest.swift
//  App
//
//  Created by Sötnos on 12/09/2019.
//

import Foundation
import Vapor
import Leaf

/// CityRequest : Helper to do the city request to the API
/// - resource : The base URL to make a city request to the API
/// - ending : Ending of the URL / API
struct CityRequest {
    let resource: URL
    
    init(ending: String) {
        /// Creates an url combining the resourceString and resource URL
        let resourceString = "http://localhost:9090/api/cities/\(ending)"
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    /**
    # Helper function to create a new city. Returns Future<Void>
    - parameters:
        - req: Request
        - city : String
        - departmentID : UUID
    - throws: Abort redirect
    - returns: Future<City>
    1. Auht helper
    2. Get the Auth token; if error occurs redirect to the login page.
    3. Add token to the headers (bearer)
    4. Make a client.
    5. Make a post request, pass the headers in and before the sending execute the completion handler.
    6. Create a Offer object.
    7. Encode the offer object
    8. Map the response to the Future<Void> and execute the completion handler.
    9. Look if the http response status is 401, if yes.
    10. Logout the user.
    11 If the response status code is 200, decode the contetnt to <City>  If future resolves as an error, catch it and throw abort and redirect the user to the login page.
    13.If response status code is something else, throw abort and redirect to error page.
    */
    func createCity(_ req: Request, city: String, departmentID: UUID) throws -> Future<City> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        let client = try req.make(Client.self) // 4
        
        return client.post(resource, headers: auth.headers, beforeSend: { req in // 5
            
            let city = City(city: city, departmentID: departmentID) // 6
            try req.content.encode(city, as: .json) // 7
            
        }).flatMap(to: City.self) { res in // 8
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 9
                throw Abort.redirect(to: "/login") // 10
            } else if res.http.status.code == 200 { // 11
                return try res.content.decode(City.self).catchMap { error in // 13
                    print(error, "Error with creating city")
                    throw Abort.redirect(to: "/error")
                }
            } else { // 13
                throw Abort.redirect(to: "/error")
            }
        }
    }
}
