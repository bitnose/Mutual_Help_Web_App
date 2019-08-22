//
//  OfferRequest.swift
//  App
//
//  Created by Sötnos on 05/08/2019.
//

import Foundation
import Vapor
import Leaf


/// OfferRequest : Helper to create a offer requests
/// - resource : The base URL to make a offer request to the API
/// - ending : Ending of the URL / API
struct OfferRequest {
    let resource: URL
    
    init(ending: String) {
        /// Creates an url combining the resourceString and resource URL
        let resourceString = "http://localhost:9090/api/offers/\(ending)"
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    /// Helper function to create a new offer. Returns Future<Void>
    /// 1. Auht helper
    /// 2. Get the Auth token; if error occurs redirect to the login page.
    /// 3. Add token to the headers (bearer)
    /// 4. Make a client.
    /// 5. Get the id of the ad (parent of the offer)
    /// 6. Make a post request, pass the headers in and before the sending execute the completion handler.
    /// 7. Create a Offer object.
    /// 8. Encode the offer object
    /// 9. Map the response to the Future<Void> and execute the completion handler.
    /// 10. Look if the http response status is 401, if yes
    /// 11. Logout the user.
    /// 12. Throw an abort and redirect the user to the login page.
    /// 14. If no, return void.
    
    func createOffer(_ req: Request, ad: Ad, offer: String) throws -> Future<Void> {
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        
        let client = try req.make(Client.self) // 9
        guard let adID = ad.id else {throw Abort(.notFound)}
        
        return client.post(resource, headers: auth.headers, beforeSend: { req in
            
            let data = Offer(offer: offer, adID: adID)
            try req.content.encode(data, as: .json) // 10
            
        }).map(to: Void.self) { res in
            
            if res.http.status.code == 401 { // 12
                auth.logout() // 13
                throw Abort.redirect(to: "/login") // 14
            }
        
            return ()
        }
    }
    
    

}
