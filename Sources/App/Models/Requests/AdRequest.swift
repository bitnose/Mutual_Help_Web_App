//
//  adRequest.swift
//  App
//
//  Created by Sötnos on 07/09/2019.
//
import Foundation
import Vapor
import Leaf

// MARK: - AdRequest

/// # AdRequest : Helper to create an ad requests
/// - resource : The base URL to make an ad request to the API
/// - config = EegjAPIConfiguration
/// - ending : Ending of the URL / API


struct AdRequest {
    
    let resource: URL
    private let config = EegjAPIConfiguration()
    init(ending: String) {
        
        let eegjConfig = config.setup()
        
        let resourceString = "http://\(eegjConfig.hostname):\(eegjConfig.port)/api/ads/\(ending)"
        /// Creates an url combining the resourceString and resource URL
        
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    // MARK: - Get Requests
    
    /**
    # Request to get ad 
    - parameters:
        - req: Request
        - returns: Future : AdData
    - throws: Abort Redirect ("error.leaf")

    1. Make a client.
    2. Make a get request to the resource. Map to the Future AdData
    3. If the response status is code is equal to 200 request was completed successfully.
    4. Return and decode the content of the request to AdDataContext. If resolving future resolves as an error, catch it and throw abort to redirect to the error page.
    5. Otherwise redirect to the error page.
    */

    func getAd(_ req: Request) throws ->  Future<AdData> {
        
        let client = try req.make(Client.self) // 1
                   
        return client.get(resource).flatMap(to: AdData.self) { res in // 2
                       
            if res.http.status.code == 200 { // 3
                return try res.content.decode(AdData.self).catchMap { error in // 4
                    print(error, "Error with decoding data from the response")
                    throw Abort.redirect(to: "/error")
                }
            } else { // 5
                   print("Errow with returning data")
                   throw Abort.redirect(to: "/error")
               }
           }
       }
       
    
    /**
    # Request to get all the ads with the user data
    - parameters:
        - req: Request
    - returns: Future : [AdWithUser]
    - throws: Abort Redirect ("error.leaf")

    1.  Auth helper
    2. Get the Auth token; if error occurs redirect to the login page.
    3. Add token to the headers (bearer)
    4. Make a client.
    5. Make a get request to the resource with the headers. Map to the Future AdWithUser.
    6. Look if the user is authorized.
    7. If not logout the user.
    8. If the response status is code is equal to 200 request was completed successfully.
    9. Return and decode the content of the request to AdWIthUser. If resolving future resolves as an error, catch it and throw abort to redirect to the error page.
    10. Otherwise redirect to the error page.
    */
    func getAdsWithUser(_ req: Request) throws -> Future<[AdWithUser]> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
                       
        let client = try req.make(Client.self) // 4
        return client.get(resource, headers: auth.headers).flatMap(to: [AdWithUser].self) { res in // 5
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 200 { // 8
                return try res.content.decode([AdWithUser].self).catchMap({ error in // 9
                    print(error)
                    throw Abort.redirect(to: "/error")
                })
            } else { // 10
                throw Abort.redirect(to: "/error")
            }
        }
    }
    
   /**
    # Request to get all the ads
    - parameters:
       - req: Request
    - returns: Future : AdsOfPerimeterData
    - throws: Abort Redirect ("error.leaf")
  
    1. Make a client.
    2. Make a get request to the resource. Map to the Future AdsOfPerimeterData.
    3. If the response status is code is equal to 200 request was completed successfully.
    4. Return and decode the content of the request to AdsOfPerimeterData. If resolving future resolves as an error, catch it and throw abort to redirect to the error page.
    5. Otherwise redirect to the error page.
   */

    func getAll(_ req: Request) throws -> Future<AdsOfPerimeterData> {
       
       let client = try req.make(Client.self) // 1
               
       return client.get(resource).flatMap(to: AdsOfPerimeterData.self) { res in // 2
                   
            if res.http.status.code == 200 { // 3
                // 4
               return try res.content.decode(AdsOfPerimeterData.self).catchMap { error in
                   print(error, "Error with decoding data from the response")
                   throw Abort.redirect(to: "/error")
               }
           } else { // 5
               print("Errow with returning data")
               throw Abort.redirect(to: "/error")
           }
       }
    }
    
    /**
    # Request to get ad of the user
    - parameters:
        - req: Request
        - returns: Future : AdDataContext
    - throws: Abort Redirect ("error.leaf")
    1.  Auth helper
    2. Get the Auth token; if error occurs redirect to the login page.
    3. Add token to the headers (bearer)
    4. Make a client.
    5. Make a get request to the resource with the headers. Map to the Future AdDataContext.
    6. Look if the user is authorized.
    7. If not logout the user.
    8. If the response status is code is equal to 200 request was completed successfully.
    9. Return and decode the content of the request to AdDataContext. If resolving future resolves as an error, catch it and throw abort to redirect to the error page.
    10. Otherwise redirect to the error page.
    */
    
    func getAdOfUser(_ req: Request) throws ->  Future<AdDataContent> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
                
        let client = try req.make(Client.self) // 4
                
        return client.get(resource, headers: auth.headers).flatMap(to: AdDataContent.self) { res in // 5
                    
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 200 { // 8
                return try res.content.decode(AdDataContent.self).catchMap { error in // 9
                    print(error, "Error with decoding data from the response")
                    throw Abort.redirect(to: "/error")
                }
            } else { // 10
                print("Errow with returning data")
                throw Abort.redirect(to: "/error")
            }
        }
    }

    /**
     # AdRequest to (soft)delete the ad.
     - parameters:
         - req: Request
         - returns: Future : AdDataContext
     - throws: Abort Redirect ("error.leaf")
    /// 1. Route handler takes a request as a parameter and returns Future<Response>. Function throws if errors occur.
    /// 2. Auht helper
    /// 3. Get the Auth token; if error occurs redirect to the login page.
    /// 4. Add token to the headers (bearer)
    /// 5. Make a client.
    /// 6. Make a delete request to the API with the headers. Map the response to the Future<Response>.
    /// 7. If the status code is equal to 401.
    /// 8. Logout the user.
    /// 9. Throw abort and redirect to the login page.
    /// 10. If the response status code is equal to 204, it means that the deletion was successfull.
    /// 11. Return and redirect the user to the index page.
    /// 12. Otherwise redirect the user to the error page.
    */
    func softDelete(_ req: Request) throws -> Future<Response> { // 1
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
        let client = try req.make(Client.self) // 5
        
        return client.delete(resource, headers: auth.headers).map(to: Response.self) { res in // 6
            if !Auth.init(req: req).isAuthorized(response: res) { // 7 - 9
                throw Abort.redirect(to: "/login")
            } else if res.http.status.code == 204 { // 10
                return req.redirect(to: "/self/index") // 11
            } else { // 12
                return req.redirect(to: "/error")
            }
        }.catchMap { error in
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    /**
     # AdRequest to make a post request to create a new ad.
     - parameters:
         - req: Request
         - note : String
         - cityID : UUID
     - returns: Future : Ad
     - throws: Abort Redirect ("error.leaf")
    /// 1. Route handler's parameters: Request, Note, CityID. Returns Future<Ad> and this function throws if errors occur.
    /// 2. Auht helper
    /// 3. Get the Auth token; if error occurs redirect to the login page.
    /// 4. Add token to the headers (bearer)
    /// 5. Make a client.
    /// 6. Make a post request to the API with the headers. Before sending execute in the completion handler:
    /// 7. Make a data object what will be sent to the API (contains data to create a new ad)
    /// 8. Encode the data to a json object.
    /// 9. FlatMap the Future<Response> of the API request to the Future<Ad>.
    /// 10. If the status code is equal to 401.
    /// 11. Logout the user.
    /// 12. If the response code is 200, try to decode the data. If errors, catch them and throw abort and redirect to the login page.
    /// 13. Otherwise throw abort and redirect to the error page.
    */
    func createAD(_ req: Request, note: String, cityID: UUID) throws -> Future<Ad> { // 1
        
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
        
        let client = try req.make(Client.self) // 5
       
        return client.post(resource, headers: auth.headers, beforeSend: { req in // 6
            
            try req.content.encode(DataForAd(note: note, cityID: cityID), as: .json) // 7-8
            
        }).flatMap(to: Ad.self) { res in // 9
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 10
                throw Abort.redirect(to: "/login") // 11
            } else if res.http.status.code == 200  { // 12
                return try res.content.decode(Ad.self).catchMap { error in
                    print(error, "Error with creating ad")
                    throw Abort.redirect(to: "/error")
                }
            } else {
                throw Abort.redirect(to: "/error") // 13
            }
        }
    }
    
    /**
     # Put request to send the edited ad
     - parameters:
        - req: Request
        - data: AdInfoPostData
     - returns: Future : Response
     - throws: Abort Redirect ("error.leaf")
     1.  Auth helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3. Add token to the headers (bearer)
     4. Make a client.
     5. Make a put request to the resource with the headers. Before the sending the request, execute completion handler.
     6. Endoce the data.
     7. Map the resolving future to Future<Response>.
     8. Look if the user is authorized.
     9. If not logout the user.
     10. If the response status is code is equal to 201 request was completed successfully.
     11. Return and redirect to the index page.
     12. Otherwise redirect to the error page.
    */

    func sendEditedAd(_ req: Request, data: AdInfoPostData) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        let client = try req.make(Client.self) // 4
        
        return client.put(resource, headers: auth.headers, beforeSend: { req in // 5
           
            try req.content.encode(data) // 6
           
        }).map(to: Response.self) { res in // 7
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 8
                throw Abort.redirect(to: "/login") // 9
            } else if res.http.status.code == 200  { // 10
                 return req.redirect(to: "/self/index") // 11
           } else { // 12
               throw Abort.redirect(to: "/error")
           }
        }
    }
    
    /**
    # Post request to send the heart
    - parameters:
        - req: Request
        - page: Endpoint
    - returns: Future : Response
    - throws: Abort Redirect ("error.leaf")
    1.  Auth helper
    2. Get the Auth token; if error occurs redirect to the login page.
    3. Add token to the headers (bearer)
    4. Make a client.
    5. Make a postt request to the resource with the headers. Map the resolving future to Future<Response>.
    6. Look if the user is authorized.
    7. If not logout the user.
    8. If the response status is code is equal to 200 request was completed successfully. Return and redirect to the endpoint.
    9. If resolving future resolves as an error, cath it and throw abort and redirect to the error.leaf page.
    */
        
    func likeAd(_ req: Request, to page: String) throws -> Future<Response> {
    
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        let client = try req.make(Client.self) // 4
        
        return client.post(resource, headers:  auth.headers).map(to: Response.self) { res in // 5
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 200 { // 8
                return req.redirect(to: page)
            } else { // 9
                throw Abort.redirect(to: "/error")
            }
        }.catchMap { error in // 10
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
}

