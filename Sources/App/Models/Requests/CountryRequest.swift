//
//  CountryRequest.swift
//  App
//
//  Created by Sötnos on 15/10/2019.
//

import Foundation
import Vapor
import Leaf


/// CountryRequest : Data type which handles making a country requests to the API
/// - resource : The base URL to make an ad request to the API
/// - ending : Ending of the URL / API
struct CountryRequest {
    
    let resource: URL
    private let config = EegjAPIConfiguration()
    init(ending: String) {
        
        // Get the configurations
        let eegjConfig = config.setup()
        
        let resourceString = "http://\(eegjConfig.hostname):\(eegjConfig.port)/countries/\(ending)"
        /// Creates an url combining the resourceString and resource URL
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    /**
     # Create Country
      - Parameters:
            - req: Request
         - Throws: Abort Redirect
         - Returns: Response
         
     1. Auht helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3.  Add token to the headers (bearer)
     4. Make a client.
     5. Make a post request to the API with the headers. Before sending the request, execute the completion handler.
     6. Create a data object (<Country>)
     7. Encode the date to the content.
     8. Map the response to the Future<Response>.
     9. If the user is not authorized.
     10. Logout the user and throw abort and redirect to the login page.
     11. If the response status code is equal to 201, it means that the creation was success so return the redirect to the countries.leaf page.
     12.  If the http status is something else redirect the user to the error page.
     13. If the resolving future resolves as an error, catch the error and throw abort to redirect to the error.leaf page.
     */
    func createCountry(_ req: Request, name: String) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        let client = try req.make(Client.self) // 4
              
        return client.post(resource, headers: auth.headers, beforeSend: { req in // 5
            
            let data = Country(country: name) // 6
            try req.content.encode(data, as: .json) // 7
                   
        }).map(to: Response.self) { res in // 8
                   
            if !Auth.init(req: req).isAuthorized(response: res) { // 9
                throw Abort.redirect(to: "/login") // 10
            } else if res.http.status.code == 201 { // 11
                return req.redirect(to: "/admin/countries/all")
            } else { // 12
                return req.redirect(to: "/error")
            }
        
        }.catchMap { error in // 13
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    
    /**
     # Delete Country Request
     - Parameters:
        - req: Request
     - Throws: Abort Redirect
     - Returns: Response
     
     1. Auht helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3.  Add token to the headers (bearer)
     4. Make a client.
     5. Make a delete request to the API with the headers. Map the response to the Future<Response>.
     6. If the status code is equal to 401.
     7. Logout the user.
     8. Throw abort and redirect to the login page.
     9. If the response status code is equal to 204, it means that the deletion was successfull.
     10. Return and redirect the user to the  page.
     11.  Otherwise redirect the user to the error page.
     12. If the resolving future resolves as an error, catch the error and throw abort to redirect to the error.leaf page.
     */
    
    func deleteCountry(_ req: Request) throws -> Future<Response> {
        
       let auth = Auth(req: req) // 1
       guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
       auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
       let client = try req.make(Client.self) // 4
       
       return client.delete(resource, headers: auth.headers).map(to: Response.self) { res in // 5
           if !Auth.init(req: req).isAuthorized(response: res) { // 6...
               throw Abort.redirect(to: "/login") // ...8
           } else if res.http.status.code == 204 { // 9
               return req.redirect(to: "/admin/countries/all") // 10
           } else { // 11
               return req.redirect(to: "/error")
           }
       }.catchMap { error in // 12
           print(error)
           throw Abort.redirect(to: "/error")
       }
    }
    
    /**
     # Get countries
     - Parameters:
            - req: Request
     - Throws: Abort Redirect
     - Returns: Response
     
     1. Make a client.
     2. Make a get request to the api. FlatMap the response to the Future<[Country]>.
     3. If the status code is equal to 200.
     4. Try to decode the content of the response to <[Country]>. If the resolving future resolves as an error, throw abort and redirect the user to the error.leaf page.
     5. If the response is something else throw abort and redirect the user to the error.leaf page.
     
     */
    
    func getCountries(_ req: Request) throws -> Future<[Country]> {
        
        let client = try req.make(Client.self) // 1

        return client.get(resource).flatMap(to: [Country].self) { res in // 2
            
            if res.http.status.code == 200 { // 3
                // 4
                return try res.content.decode([Country].self).catchMap({ error in
                    print(error)
                    throw Abort.redirect(to: "/error")
                })
            } else { // 5
                throw Abort.redirect(to: "/error")
            }
        }
    }
    
    
    /**
    # Method to fetch all the countries with their departments
     - Parameters:
            - req: Request
     - Throws: Abort Redirect
     - Returns: Future[CountryWithDepartments]
     
     1. Make a client
     2. Make a get request and map the response to Future<[CountryWithDepartments]>
     3. If the http status code is equal to 200, decode the response data to <[CountryWithDepartments]>. If the resolving future resolves as an error, catch it and throw abort to redirect the user to the error.leaf page.
     4. Otherwise throw aboirt and redirect to the error.leaf page.
    */
    func getCountriesWithDepartments(_ req: Request) throws -> Future<[CountryWithDepartments]> {
        
        let client = try req.make(Client.self) // 1
        
        return client.get(resource).flatMap(to: [CountryWithDepartments].self) { res in // 2
            // 3
            if res.http.status.code == 200 {
                return try res.content.decode([CountryWithDepartments].self).catchMap({ error in
                    print(error)
                    throw Abort.redirect(to: "/error")
                }) // 4
            } else {
                throw Abort.redirect(to: "/error")
            }
        }
    }
    
    
}

