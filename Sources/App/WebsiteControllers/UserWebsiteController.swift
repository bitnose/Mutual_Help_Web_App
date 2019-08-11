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
    
    /// Implement boot(router:) as required by RouteCollection.
    func boot(router: Router) throws {
        
        /// A group of routes which handles authentication
        let userRoutes = router.grouped("")
        
        /// Routes which requires users to be authenticated. If user is not authenticated, it redirects user to the "login" page.
        let protectedRoutes = userRoutes.grouped(RedirectMiddleware())
        
        /// 1. GET request - Get the login view.
        /// 2. POST request - Post LoginPostData to the API to auhtenticate the user.
        /// 3. Protected GET request - Get the index page
        /// 4. Protected GET request - Logout user and go back to the login page.
 
        userRoutes.get("login", use: loginHandler) // 1
        userRoutes.post(LoginPostData.self, at: "login", use: signInPostHandler) // 2
        protectedRoutes.get("index", use: indexHandler) // 3
        protectedRoutes.get("logout", use: logoutPostHandler) // 4
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
    
    /// Handler to Render a protected Index view
    ///     Auth helper
    ///  1. Look an id of the token is saved in the session, if not destroy the session and redirect user to the login page.
    ///  2. Create HTTPHeaders
    ///  3. Set the token to the Authorization: Bearer: ... header.
    ///  4. Make a client.
    ///  5. Make a get request with the headers to get all the ads and map the result to the Future<View>
    ///  6. Look if the user is authorized, if yes return true and continue execution.
    ///  7. Try to decode the content of the response to the [Ad]
    ///  8. Create a context with a title and the ads.
    ///  9. Render the view and pass the context in.
    /// 10. If the user is not authorized throw an Abort and redirect the user to the login page (isAuthorized function calls destroys the session token if the user is not authorized).
    /// 11. Calls the supplied closure if the chained Future resolves to an Error.
    /// 12. Logout the user (destroy the session).
    /// 13. Throw an abort and redirect the user to the login page.
    
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        let auth = Auth(req: req) //
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 1
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        let client = try req.make(Client.self) // 4
        return client.get("http://localhost:9090/api/ads", headers: auth.headers).flatMap(to: View.self) { res in // 5
            
            if auth.isAuthorized(response: res) == true { // 6
                
                let ads = try res.content.decode([Ad].self) // 7
                let context = AllAdsContext(title: "All ads", ads: ads) // 8
                return try req.view().render("index", context) // 9
                
            } else { // 10
                throw Abort.redirect(to: "/login")
            }
        }.catchMap({ error in // 11
            auth.logout() // 12
            throw Abort.redirect(to: "/login") // 13
        })
    }
    
    /// Logout Handler
    ///  1. Auht helper.
    ///  2. Get the token from the session: if it doesn't exist logout the user.
    ///  3. Set the token to the Authorization: Bearer: ... header.
    ///  4. Make a client.
    ///  5. Make a get request with headers to delete the token and map the response to Future<Response>.
    ///  6. Call logout which deletes the token in the session. Redirect user to the login page
    ///  7. Calls the supplied closure if the chained Future resolves to an Error: Logout and redirect the user to the login page.
    
    func logoutPostHandler(_ req: Request) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = Auth(req: req).token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        let client = try req.make(Client.self) // 4
        return client.delete("http://localhost:9090/api/users/logout", headers: auth.headers).map(to: Response.self) { _ in // 5
            // 6
            auth.logout()
            print("User has loged out")
            return req.redirect(to: "/login")
            
        // 7
        }.catchMap { error in
            auth.logout()
            print("User has loged out with catchmap")
            throw Abort.redirect(to: "/login")
        }
    }
    
    
    
}
