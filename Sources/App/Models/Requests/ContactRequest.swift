//
//  ContactRequest.swift
//  App
//
//  Created by Sötnos on 24/09/2019.
//

import Foundation
import Vapor
import Leaf
import Crypto
/// Contact : Data type which handles making the contact requests to the API
/// - resource : The base URL to make the request to the API
/// - ending : Ending of the URL / API
struct ContactRequest {
    
    let resource: URL
    private let config = EegjAPIConfiguration()
    init(ending: String) throws {
        // Get the configurations
        let eegjConfig = config.setup()
        
        let resourceString = "http://\(eegjConfig.hostname):\(eegjConfig.port)/users/\(ending)"
        // Creates an url combining the resourceString and resource URL
        guard let resourceURL = URL(string: resourceString) else {
             throw Abort.redirect(to: "/error")
        }
        // Return the resourceURL
        self.resource = resourceURL
    }

    // MARK: - Contact Requests
    
    /**
    # Send a request to make a contact request
    - parameters:
        - req: Request
        - adID : UUID
    - Returns: Future Response
    - Throws: AbortError
    2.  Auth helper
    3. Get the Auth token; if error occurs redirect to the login page.
    4. Add token to the headers (bearer)
    5. Make a client.
    6. Make a post request to the resource with the headers. Map to the Future Response.
    7. Look if the user is authorized.
    8. If not logout the user.
    9. If the response status is code is equal to 201, redirect the user to the other page.
    10. Otherwise redirect to the error page.
    11. If future resolves as an error, throw abort and redirect to the error.leaf page.
     */
    func sendContactRequest(_ req: Request, adID: UUID) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
        
        let client = try req.make(Client.self) // 5
        
        return client.post(resource, headers: auth.headers).map(to: Response.self) { res in // 6
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 7
                throw Abort.redirect(to: "/login") // 8
            } else if res.http.status.code == 201 { // 9
                print("The Request has been sent!")
                return req.redirect(to: "/\(adID)/ads/contact")
                
            } else { // 10
                throw Abort.redirect(to: "/error")
            }
        }.catchMap { error in
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    /**
     # Make a request to get contact requests
     - parameters:
        - req: Request
     - returns: Future : [ContactRequestFromData]
     - throws: AbortError
     1.  Auth helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3. Add token to the headers (bearer)
     4. Make a client.
     5. Make a get request to the resource with the headers. Map to the Future  [ContactRequestFromData].
     6. Look if the user is authorized.
     7. If not logout the user.
     8. If the response status is code is equal to 200 try to decode and return the response data. If future resolves as an error, throw abort and redirect to the error.leaf page.
     9. Otherwise redirect to the error page.
     */
    func getContactRequests(_ req: Request) throws -> Future<[ContactRequestFromData]>? {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
           
        let client = try req.make(Client.self) // 4
        
        return client.get(resource, headers: auth.headers).flatMap(to: [ContactRequestFromData].self) { res in // 5
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 200 { // 8
                return try res.content.decode([ContactRequestFromData].self).catchMap { error in
                    print(error)
                    throw Abort.redirect(to: "/error")
                } // 9
          } else { // 10
              throw Abort.redirect(to: "/error")
          }
        }
    }
    
    /** # Request to accept the contact request
        - parameters:
            - req: Request
         - returns: Future : Response
         - throws: AbortError
     1.  Auth helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3. Add token to the headers (bearer)
     4. Make a client.
     5. Make and return a put request to the resource with the headers.
     6. Look if the user is authorized.
     7. If not logout the user.
     8. If the response status is code is equal to 202, redirect the user to the other page.
     9. Otherwise redirect to the error page.
     10. If future resolves as an error, throw abort and redirect to the error.leaf page.
     */
    func acceptContactRequest(_ req: Request, to page: String) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
                  
        let client = try req.make(Client.self) // 4
               
        return client.put(resource, headers: auth.headers).map(to: Response.self) { res in // 5
                   
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 202 { // 8
                return req.redirect(to: page)
            } else { // 9
                throw Abort.redirect(to: "/error")
            }
        }.catchMap { error in // 10
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    /** # Request to decline the contact request
        - parameters:
            - req: Request
            - page: Stirng
         - returns: Future : Response
         - throws: AbortError
     1.  Auth helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3. Add token to the headers (bearer)
     4. Make a client.
     5. Make and return a put request to the resource with the headers.
     6. Look if the user is authorized.
     7. If not logout the user.
     8. If the response status is code is equal to 204, redirect the user to the other page.
     9. Otherwise redirect to the error page.
     10. If future resolves as an error, throw abort and redirect to the error.leaf page.
     */
    func declineContactRequest(_ req: Request, to page: String) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
                  
        let client = try req.make(Client.self) // 4
               
        return client.delete(resource, headers: auth.headers).map(to: Response.self) { res in // 5
                   
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 204 { // 8
                return req.redirect(to: page)
            } else { // 9
                throw Abort.redirect(to: "/error")
            }
        }.catchMap { error in // 10
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    
    /**
     # Get Contacts
     - parameters:
        - req: Request
     - returns: Future : [ContactInfoData]?
     - throws: AbortError
     1.  Auth helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3. Add token to the headers (bearer)
     4. Make a client.
     5. Make a get request to the resource with the headers. Map to the Future [ContactInfoData].
     6. Look if the user is authorized.
     7. If not logout the user.
     8. If the response status is code is equal to 200 request was completed successfully.
     9. Return and decode to [ContactInfoData]. If future resolves as an error, throw abort and redirect to the error.leaf page.
     10. Otherwise redirect to the error page.
     */
    
    func getContacts(_ req: Request) throws -> Future<[ContactInfoData]>? {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
           
        let client = try req.make(Client.self) // 4
        
        return client.get(resource, headers: auth.headers).flatMap(to: [ContactInfoData].self) { res in // 5
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 200 { // 8
                return try res.content.decode([ContactInfoData].self).catchMap { error in // 9
                    print(error)
                    throw Abort.redirect(to: "/error")
                }
          } else { // 10
              throw Abort.redirect(to: "/error")
          }
        }
    }
    
    /**
     # Handler to get a single contact
        - parameters:
            - req: Request
         - returns: Future : ContactData
         - throws: AbortError
         1.  Auth helper
         2. Get the Auth token; if error occurs redirect to the login page.
         3. Add token to the headers (bearer)
         4. Make a client.
         5. Make a get request to the resource with the headers. Map to the Future ContactData.
         6. Look if the user is authorized.
         7. If not logout the user.
         8. If the response status is code is equal to 200 request was completed successfully.
         9. Return and decode to ContactData. If future resolves as an error, throw abort and redirect to the error.leaf page.
         10. Otherwise redirect to the error page.
     */
    func getContactOfAd(_ req: Request) throws -> Future<ContactData> {
    
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
    
        let client = try req.make(Client.self) // 4
        
        return client.get(resource, headers: auth.headers).flatMap(to: ContactData.self) { res in // 5
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 200 { // 8
                return try res.content.decode(ContactData.self).catchMap({ error in
                    print(error)
                    throw Abort.redirect(to: "/error")
                }) // 9
            } else { // 10
                throw Abort.redirect(to: "/error")
            }
        }
    }
}
