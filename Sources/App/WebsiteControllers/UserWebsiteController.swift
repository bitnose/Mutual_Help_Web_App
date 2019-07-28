//
//  UserWebsiteController.swift
//  App
//
//  Created by Sötnos on 15/07/2019.
//

import Foundation
import Vapor
import Leaf


/// WebsiteController which handles user routes.
struct UserWebsiteController : RouteCollection  {
    
    
// Implement boot(router:) as required by RouteCollection.
    func boot(router: Router) throws {
        
        /// A group of routes which handles authentication
        let userRoutes = router.grouped("")
        
        /// Routes which requires users to be authenticated. If user is not authenticated, it redirects user to the "login" page.
        let protectedRoutes = userRoutes.grouped(RedirectMiddleware())
        
        
        /// 1. GET request - Get the login view.
        /// 2. POST request - Post LoginPostData to the API to auhtenticate the user.
        
        
        /// 3. Protected Routes
 
        userRoutes.get("login", use: loginHandler) // 1
        userRoutes.post(LoginPostData.self, at: "login", use: signInPostHandler) // 2
        protectedRoutes.get("index", use: indexHandler)
        
        
    }
    
    
/// Handler to get the login view.
/// 1. Context
/// 2. If there are no login error, set the boolean value to be false and create a context. Otherwise set the boolean value to be true.
/// 3. Return Future<View> and pass the context to the view.
  
    func loginHandler(_ req: Request) throws -> Future<View> {
        let context: LoginContext // 1
        // 2
        if req.query[Bool.self, at: "error"] != nil {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        // 3
        return try req.view().render("login", context)
    }
    
    
/// Handler to post credentials to authenticate user. Returns Future<Response>.
/// 1. Create a client to make an API request.
/// 2. Encode username.
/// 3. Encode password.
/// 4. Create a loginPostData object with encoded password and username.
/// 5. Sends an HTTP POST Request to a server with a configuration closure that will run before sending.
/// 6. Encode loginPostData
/// 7. Maps a Future to a Future of a different type.
/// 8. Decode a content of the response to a <Token> and map the result to Response.
/// 9. Set the token of the User to be the token we received. This helper function saves the token to a session.
/// 10. Redirect to the index page.
/// 11. If the chained Future resolves to an Error, call the supplied closure with 'catchMap'.
/// 12. In the closure redirect to the login page to show an error.

    
    func signInPostHandler(_ req: Request, data: LoginPostData) throws -> Future<Response> {
        
        let client = try req.make(Client.self) // 1
        let encodedUsername = data.username.toBase64() // 2
        let encodedPassword = data.password.toBase64() // 3
        let loginPostData = LoginPostData(username: encodedUsername, password: encodedPassword) // 4
        
        return client.post("http://localhost:9090/api/users/login", beforeSend: { req in // 5
            
            try req.content.encode(loginPostData) // 6
            
        }).flatMap(to: Response.self) { res in // 7
            
           return try res.content.decode(Token.self).map(to: Response.self) { token in // 8
            
                Auth.init(req: req).token = token.token // 9
                return req.redirect(to: "index") // 10
            
            }.catchMap({ error in // 11
                return req.redirect(to: "/login?error") // 12
            })
        }
    }
    
///  1. JWT is saved on the session
///  2. Pass the JWT as a bearer to the http request.
///  3. Make a client.
///  4. Make a get request to get all the ads.
///  5. Parse the result. If error, redirect the user to login page (error occurs if there are an auth error)
///  6. Create context.
///  7. Render the view.
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        guard let token = Auth.init(req: req).token else {throw Abort.redirect(to: "login")}
        var headers: HTTPHeaders = [HTTPHeaderName.contentType.description : "application/json"]
        headers.bearerAuthorization = BearerAuthorization(token: token)
        
        let client = try req.make(Client.self) //
        return client.get("http://localhost:9090/api/ads", headers: headers).flatMap(to: View.self) { res in
            
            do {
                
                let ads = try res.content.decode([Ad].self)
                let context = AllAdsContext(title: "All ads", ads: ads)
                return try req.view().render("index", context)
        
            } catch {
               throw Abort.redirect(to: "login")
            }
        }
    }
}

/// Title for the page and a flag to indicate a login error.
struct LoginContext : Encodable {
    let title = "Log in"
    let loginError : Bool
    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

/// LoginPostData Type contains a username and a password
struct LoginPostData : Content {
    let username : String
    let password : String
}



