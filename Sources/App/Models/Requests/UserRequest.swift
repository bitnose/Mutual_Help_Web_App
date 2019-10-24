//
//  UserRequest.swift
//  App
//
//  Created by Sötnos on 10/09/2019.
//

import Foundation
import Vapor
import Leaf
import Crypto
/// UserRequest : Data type which handles making the user requests to the API
/// - resource : The base URL to make an ad request to the API
/// - ending : Ending of the URL / API
struct UserRequest {
    
    let resource: URL
    private let config = EegjAPIConfiguration()
    init(ending: String) {
        
        // Get the configurations
        let eegjConfig = config.setup()
        
        let resourceString = "http://\(eegjConfig.hostname):\(eegjConfig.port)/users/\(ending)"
        /// Creates an url combining the resourceString and resource URL
            
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    /// # Register User
    /// - parameters:
    ///     - req: Request
    ///     - data: RegisterPostData
    /// - throws: Abort Redirect
    /// - returns: Future : Response
    ///
    /// 1. Helper function to register a new user; Parameters: Request, RegisterPostData; Throws if errors occur. Returns a Future<Response>.
    /// 2. Make a client.
    /// 3. Make a post request to the resource. Before sending the request execute the completion handler.
    /// 4. Encode the content of the data.
    /// 5. Map to the Future<Response>.
    /// 6. If the status code is 200 the user was registered successfully.
    /// 7. Decode the content of the response to Token.
    /// 8. Save a token to the session.
    /// 9. Add a userID to the session.
    /// 10. Redirect the to the index.leaf.
    /// 11. If there are errors with decoding the response data, catch them and throw abort to redirect to the login.leaf.
    /// 12. If the status code is anything else throw abort to redirect to the register.leaf.
    func registerUser(_ req: Request, data: RegisterPostData) throws -> Future<Response> { // 1
        
        let client = try req.make(Client.self) // 2
        return client.post(resource, beforeSend: { req in // 3

            try req.content.encode(data.self, as: .json) // 4
            
        }).flatMap(to: Response.self) { res in // 5
          if res.http.status.code == 200 { // 6
    
                return try res.content.decode(Token.self).map(to: Response.self) { token in    // 7
                    
                    Auth.init(req: req).token = token.token // 8
                    Auth.init(req: req).userID = token.userID.uuidString // 9
                    return req.redirect(to: "/self/index") // 10
                    // 11
                    }.catchMap({ error in
                        print("Error with decoding the token")
                        throw Abort.redirect(to: "/login")
                    })
            } else { // 12
                throw Abort.redirect(to: "/register")
            }
        }
        
    }
    
    
    
    ///# Request to get the user's user data from the database.
    /// - parameters:
    ///     - req: Request
    /// - throws: Abort Redirect
    /// - returns: Future : User.Public
    ///
    /// 1. Helper function to get the user data of the user. Returns Future<User.Public>
    /// 2. Auht helper.
    /// 3. Get the Auth token; if error occurs redirect to the login page.
    /// 4. Add token to the headers (bearer)
    /// 5. Make a client.
    /// 6. Make a get request to the API with the headers. Return future<User.Public>.
    /// 7. Look if the http response status is 401, if yes
    /// 8. Logout the user.
    /// 9. Throw an abort and redirect the user to the login page.
    /// 10. If the code is 200, try to decode the content. If future resolves as an error, catch it and throw abort to redirect to the error.leaf page
    /// 11. Otherwise, throw an abort and redirect the user.
    
    func getUserData(_ req: Request) throws -> Future<User.Public> { // 1
        
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
        
        let client = try req.make(Client.self) // 5
        
        return client.get(resource, headers: auth.headers).flatMap(to: User.Public.self) { res in // 6
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 7...
                throw Abort.redirect(to: "/login") // ...9
            } else if res.http.status.code == 200 { // 10
                return try res.content.decode(User.Public.self).catchMap { error in
                    print(error, "Error with fetching the users.")
                    throw Abort.redirect(to: "/error")
                }
            } else { // 11
                throw Abort.redirect(to: "/error")
            }
        }
    }
    
    
    /**
     # Request to get the list of the users from the database.
      - parameters:
        - req: Request
        - throws: Abort Redirect
      - returns: Future : [User.Public]
     
    1. Helper function to get the list of users. Returns Future<[User.Public]>
    2. Auht helper.
    3. Get the Auth token; if error occurs redirect to the login page.
    4. Add token to the headers (bearer)
    5. Make a client.
    6. Make a get request to the API with the headers. Return future<[User.Public]>.
    7. Look if the http response status is 401, if yes
    8. Logout the user.
    9. Throw an abort and redirect the user to the login page.
    10. If the code is 200, try to decode the content.  If future resolves as an error, catch it and print out. Return an empty array
    11. Otherwise, throw an abort and redirect the user.
    */
    func getUsers(_ req: Request) throws -> Future<[User.Public]> { // 1
        
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
        
        let client = try req.make(Client.self) // 5
        
        return client.get(resource, headers: auth.headers).flatMap(to: [User.Public].self) { res in // 6
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 7...
                throw Abort.redirect(to: "/login") // ...9
            } else if res.http.status.code == 200 { // 10
                return try res.content.decode([User.Public].self).catchMap { error in
                    print(error, "Error with fetching the users.")
                    return []
                }
            } else { // 11
                throw Abort.redirect(to: "/error")
            }
        }
    }

    
    
    // MARK: - EDIT USERDATA
    /**
     # Helper function to update the user data of the user
     - parameters:
       - req: Request
       - data: UserData
     - throws: Abort Redirect
     - returns: Future : Response
    /// 1. Helper function to update the user data of the user.
    /// 2. Auht helper.
    /// 3. Get the Auth token; if error occurs redirect to the login page.
    /// 4. Add token to the headers (bearer)
    /// 5. Make a client.
    /// 6. Make a put request to the api with the headers.
    /// 7. Encode the data.
    /// 8. Map to Future<Response>.
    /// 9. Look if the http response status is 401, if yes
    /// 10. Logout the user.
    /// 11. Throw an abort and redirect the user to the login page.
    /// 12. If the status code is 200, update was successfull.
    /// 13. Else throw an abort to redirect the user to the error page.
    /// 14. If future resolves as an error, catch it and throw abort to redirect to the error.leaf page
    */
    func editUserData(_ req: Request, data: UserData) throws -> Future<Response> { // 1
    
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
    
        let client = try req.make(Client.self) // 5
        
        return client.put(resource, headers: auth.headers, beforeSend: { req in // 6
            
            try req.content.encode(data.self, as: .json) // 7
            
        }).map(to: Response.self) { res in // 8
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 9-10
                throw Abort.redirect(to: "/login") // 11
            } else if res.http.status.code == 200 { // 12
                print("Updated successfully.")
                return req.redirect(to: "/self/index")
            } else { // 13
                throw Abort.redirect(to: "/error")
            }
        }.catchMap { error in // 14
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    // MARK: - CHANGE THE PASSWORD
    
    /**
    # Helper function to update the user data of the user
    - parameters:
        - req: Request
        - data: ChangePasswordData
    - throws: Abort Redirect
    - returns: Future : Response
    /// 1. Helper function updates the password of the user; Parameters: Request, ChangePasswordData; Function throws if errors; Returns Future<Response>.
    /// 2. Auht helper.
    /// 3. Get the Auth token; if error occurs redirect to the login page.
    /// 4. Add token to the headers (bearer)
    /// 5. Base64 Encode the old password.
    /// 6. Base64 Encode the new password.
    /// 7. Make a client.
    /// 8. Make a put request with the headers to the api. Before sending the request encode the data.
    /// 9. Encode the content of the request to a json.
    /// 10. Map to Future<Response>.
    /// 11. Look if the http response status is 401, if yes
    /// 12. Logout the user.
    /// 13. Throw an abort and redirect the user to the login page.
    /// 14. If the status code is 200, update was successfull.
    /// 15. Else throw an abort to redirect the user to the error page.
    /// 16. If future resolves as an error, catch it and throw abort to redirect to the error.leaf page
    */
    func changePassword(_ req: Request, data: ChangePasswordData) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
        
        let encodedOldPassword  = data.oldPassword.toBase64() // 5
        let hashedNewPassword = data.newPassword.toBase64() // 6
        
        let client = try req.make(Client.self) // 7
    
        return client.put(resource, headers: auth.headers, beforeSend: { req in // 8
        
            try req.content.encode(PasswordData(oldPassword: encodedOldPassword, newPassword: hashedNewPassword).self, as: .json) // 9
            
        }).map(to: Response.self) { res in // 10
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 11-12
                throw Abort.redirect(to: "/login") // 13
            } else if res.http.status.code == 202 { // 14
                print("Updated successfully.")
                return req.redirect(to: "/self/index")
            } else { // 15
                throw Abort.redirect(to: "/error")
            }
        }.catchMap { error in
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    /**
     # DELETE USER HANDLER
     - parameters:
        - req: Request
     - returns: Response
     - throws: AbortError
     
     1. Auht helper.
     2.  Get the Auth token; if error occurs redirect to the login page.
     3. Add token to the headers (bearer)
     4. Make a client.
     5. Make a delete request to the api with the headers.
     6. Map to Future<Response>.
     7. Look if the http response status is 401, if yes
     8. Logout the user.
     9. Throw an abort and redirect the user to the login page.
     10. If the status code is 204, deletion was successfull.
     11.  Else throw an abort to redirect the user to the error page.
     12. If future resolves as an error, catch it and throw abort to redirect to the error.leaf page
     */
    
    func deleteUser(_ req: Request) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        let client = try req.make(Client.self) // 4
        
        return client.delete(resource, headers: auth.headers) // 5
            .map(to: Response.self) { res in // 6
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 7 - 8
                throw Abort.redirect(to: "/login") // 9
            } else if res.http.status.code == 204 { // 10
                return req.redirect(to: "/self/index")
            } else { // 11
                return req.redirect(to: "/error")
            }
        }.catchMap { error in // 12
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    

}
