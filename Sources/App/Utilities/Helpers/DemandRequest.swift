//
//  DemandRequest.swift
//  App
//
//  Created by Sötnos on 05/08/2019.
//

import Foundation
import Vapor
import Leaf

/// DemandRequest : Helper to create a demand requests
/// - resource : The base URL to make a demand request to the API
/// - ending : Ending of the URL / API
struct DemandRequest {
    let resource: URL
    
    init(ending: String) {
        /// Creates an url combining the resourceString and resource URL
        let resourceString = "http://locahost:9090/api/demands/\(ending)"
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    /// Helper function to create a new demand. Returns Future<Void>
    /// 1. Auht helper
    /// 2. Get the Auth token; if error occurs redirect to the login page.
    /// 3. Add token to the headers (bearer)
    /// 4. Make a client.
    /// 5. Get the id of the ad (parent of the demand)
    /// 6. Make a post request, pass the headers in and before the sending execute the completion handler.
    /// 7. Create a Demand object.
    /// 8. Encode the demand object
    /// 9. Map the response to the Future<Void> and execute the completion handler.
    /// 10. Look if the http response status is 401, if yes
    /// 11. Logout the user.
    /// 12. Throw an abort and redirect the user to the login page.
    /// 14. If no, return void.
    
    func createDemand(_ req: Request, ad: Ad, demand: String) throws -> Future<Void> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        let client = try req.make(Client.self) // 4
        guard let adID = ad.id else {throw Abort(.notFound)} // 5
        
        return client.post(resource, headers: auth.headers, beforeSend: { req in // 6
            
            let data = Demand(demand: demand, adID: adID) // 7
            try req.content.encode(data, as: .json) // 8
            
        }).map(to: Void.self) { res in // 9
            
            if res.http.status.code == 401 { // 10
                auth.logout() // 11
                throw Abort.redirect(to: "/login") // 12
            }
            return () // 13
        }
    }
}
