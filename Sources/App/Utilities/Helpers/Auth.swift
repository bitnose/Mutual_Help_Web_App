//
//  Auth.swift
//  App
//
//  Created by Sötnos on 27/07/2019.
//
import Foundation
import Vapor

///
// MARK: - Helper Class to Help with Authentication
///
///     - DefaultsKey is the Name of the Session
///     - Request
///     - Token
///         Getter
///         - Try to get the token from the session
///         - Catch the errors if there are: If yes, return nil
///        Setter
///         - Add a new token to the session
///         - Catch errors if there are: If yes, stop execution and print a message
///     - userID : String?
///         Getter
///         - Try to get the token from the session
///         - Catch the errors if there are: If yes, return nil
///        Setter
///         - Add a new token to the session
///     - Headers : HTTPHeaders = ("application/json")
///     - usertype : String?
///         Getter
///         - Try to get the token from the session
///         - Catch the errors if there are: If yes, return nil
///        Setter
///         - Add a new token to the session
final class Auth {
    
    let userIDKey = "USER-ID-KEY"
    let defaultsKey = "MH-API-KEY"
    let accessKey = "ACCESS-KEY"
    let req: Request
    var token: String? {
        
        get {
            do {
                return try req.session()[defaultsKey]
            } catch {
                return nil
            }
        }
        set {
            do {
                try req.session()[defaultsKey] = newValue
            } catch {
                fatalError("Cache: Saving not successful")
            }
        }
    }
    /// User ID
    var userID: String? {
        
        get {
            do {
                return try req.session()[userIDKey]
            } catch {
                return nil
            }
        }
        set {
            do {
                try req.session()[userIDKey] = newValue
            } catch {
                fatalError("Cache: Saving not successful")
            }
        }
    }
    
    var usertype: String? {
           
           get {
               do {
                   return try req.session()[accessKey]
               } catch {
                   return nil
               }
           }
           set {
               do {
                   try req.session()[accessKey] = newValue
               } catch {
                   fatalError("Cache: Saving not successful")
               }
           }
       }

    var headers: HTTPHeaders = [HTTPHeaderName.contentType.description : "application/json"] // 2

///
///     - Initialization of the Request
///
    init(req: Request) {
        self.req = req
    }
///
///        Method which returns a boolean value
///         - True: Token exists in the session
///         - False : Token doesn't exist in the session
///
    func isAuthenticated() -> Bool {
        if let _ = token {
            return true
        } else {
            return false
        }
    }
///
///        Method to logout the user
///         - Destroys the current session, if one exists
///         - Catch errors if there are: If yes, stop execution and print a message
///
    func logout() {
        do {
            try req.destroySession()
        } catch {
            fatalError("Cache: Could not destroy session")
        }
    }
    
///
///     - Method which looks if the user is authorized.
///         - If response HTTPStatusCode is 401 (unauthorized) logout the user and return false 
///         - Otherwise return true
///
    
    func isAuthorized(response: Response) -> Bool {
        if response.http.status.code == 401 {
            Auth(req: req).logout()
            return false
        } else {
            return true
        }
    }
    
    /**
     # Mehtod to check if the authenticated user has an admin access.
     - Returns: Bool 
     */
    func isAdmin() -> Bool {
        
        if usertype == "admin" {
            
            return true
        } else {
            return false
        }
    }
}
