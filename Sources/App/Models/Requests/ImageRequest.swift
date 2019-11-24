//
//  ImageRequest.swift
//  App
//
//  Created by Sötnos on 18/09/2019.
//

import Foundation
import Vapor
import Leaf

/// CityRequest : Helper to do the city request to the API
/// - resource : The base URL to make a city request to the API
/// - ending : Ending of the URL / API
struct ImageRequest {
    let resource: URL
    private let config = EegjAPIConfiguration()
    init(ending: String) throws {
        
        // Get the configurations
        let eegjConfig = config.setup()
        
        let resourceString = "http://\(eegjConfig.hostname):\(eegjConfig.port)/aws/\(ending)"
        /// Creates an url combining the resourceString and resource URL
           
        guard let resourceURL = URL(string: resourceString) else {
             throw Abort.redirect(to: "/error")
        }
        
        self.resource = resourceURL
    }
    

    /// 1. Auht helper
    /// 2. Get the Auth token; if error occurs redirect to the login page.
    /// 3. Add token to the headers (bearer)
    /// 4. Make a client.
    /// 5. Make a post request, pass the headers in and before the sending execute the completion handler.
    /// 6. Create a data and encode it. Do this in do catch block, if errors occur throw abort and redirect to the error.leaf page.
    /// 7. Map the response to the Future<Response> and execute the completion handler.
    /// 8. Look if the http response status is 401, if yes
    /// 9. Logout the user.
    /// 10. Throw an abort and redirect the user to the login page.
    /// 11. If the item was uploaded successfully, print a message. 
    /// 12. In other cases, throw abort and redirect the user to the error page.
    
    func postImageData(_ req: Request, to adID: UUID, data: Data) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
    
        let client = try req.make(Client.self) // 4
    
        return client.post(resource, headers: auth.headers, beforeSend: { req in // 5
            do {
                try req.content.encode(ImageData(image: data, adID: adID), as: .json) // 6
            } catch let error {
                print(error)
                throw Abort.redirect(to: "/error")
            }
            
    
        }).map(to: Response.self) { res in // 7
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 8-10
                throw Abort.redirect(to: "/login") 
            } else if res.http.status.code == 200 { // 11
                return req.redirect(to: "/\(adID)/edit/image")
            } else { // 12

                throw Abort.redirect(to: "/error")
            }
        }
    }
    
    /// Delete Image Request
    /// 1. Auht helper.
    /// 2. Get the Auth token; if error occurs redirect to the login page.
    /// 3. Add token to the headers (bearer).
    /// 4. Make a client.
    /// 5. Make a get request with the headers and map the future to <Future>Response.
    /// 6. Look if the http response status is 401, if yes
    /// 7. Logout the user.
    /// 8. Throw an abort and redirect the user to the login page.
    /// 9. If the item was deleted successfully, print a message and redirect the user to the edit.leaf.
    /// 10. In other cases, throw abort and redirect the user to the error page.
    func deleteImageRequest(_ req: Request, adID: UUID) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        let client = try req.make(Client.self) // 4
        
        return client.get(resource, headers: auth.headers).map(to: Response.self) { res in // 5
            
            if res.http.status.code == 401 { // 6
                auth.logout() // 7
                throw Abort.redirect(to: "/login") // 8
                
            } else if res.http.status.code == 204 { // 9
                print("Item deleted succesfully")
                return req.redirect(to: "/\(adID)/edit/image")
            
            } else { // 10
                print("Failure")
                throw Abort.redirect(to: "/error")
            }
        }
    }
    
    
    /**
     # Get Images
     1. Make a client
     2. Make a get request to the api and return the response.
     */
    func getImages(_ req: Request) throws -> Future<Response> {
        
        let client = try req.make(Client.self) // 1
        
        return client.get(resource) // 2
    }
    
    
}
