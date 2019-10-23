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
    private let config = EegjAPIConfiguration()
    init(ending: String) {
        
        // Get the configurations
        let eegjConfig = config.setup()
        
        let resourceString = "http://\(eegjConfig.hostname):\(eegjConfig.port)/demands/\(ending)"
        /// Creates an url combining the resourceString and resource URL
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    /// # Helper function to create a new model. Returns Future<Void>
    /// - parameters:
    ///     - req: Request
    ///     - demands : <[String]>
    ///     - ad : UUID
    /// - throws: Abort Redirect
    /// - returns: Future Void
    /// 
    /// 1. Auht helper
    /// 2. Get the Auth token; if error occurs redirect to the login page.
    /// 3. Add token to the headers (bearer)
    /// 4. Make a client.
    /// 5. Make a post request, pass the headers in and before the sending execute the completion handler.
    /// 6. Create a data and encode it.
    /// 7. Map the response to the Future<Void> and execute the completion handler.
    /// 8. Look if the http response status is 401, if yes
    /// 9. Logout the user.
    /// 10. Throw an abort and redirect the user to the login page.
    /// 11. If http status code is 201, return void.
    /// 12. Otherwise Throw an abort and redirect the user to the login page.
    /// 13. If errors occur, catch them and throw abort to redirect the user to the error page.
    func createDemand(_ req: Request, demands: [String], ad: UUID) throws -> Future<Void> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        let client = try req.make(Client.self) // 4
        
        return client.post(resource, headers: auth.headers, beforeSend: { req in // 5
        
            try req.content.encode(DemandOfferData(strings: demands, adID: ad), as: .json) // 6
            
        }).map(to: Void.self) { res in // 7
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 8-10
                throw Abort.redirect(to: "/login") 
            } else if res.http.status.code == 200 { // 11
                return ()
            } else { // 12
                throw Abort.redirect(to: "/error")
            }

                // 13
        }.catchMap({ error in
            print(error)
            throw Abort.redirect(to: "/error")
        })
    }
}
