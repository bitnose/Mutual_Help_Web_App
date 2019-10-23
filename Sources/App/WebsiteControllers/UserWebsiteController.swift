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
        
        // 1. GET request - Render the login view - /login
        // 2. POST request - Post LoginPostData to the API to auhtenticate the user - /login
        // 3. Protected GET request - Get the page to update the user data - /self/edit/user
        // 4. Protected GET request - Logout user and go back to the login page - /logout
        // 5. Protected POST request - Handler which updates the userdata - /self/edit/user
        // 6. Protected GET request - Handler which renders a view to change the password - /self/edit/password
        // 7. Protected POST request - Handler which changes the password - /self/edit/password
        // 8. GET request - Render the register view - /register
        // 9. POST request - Posts data to create a new user - /register
        
        userRoutes.get("login", use: loginHandler) // 1
        userRoutes.post(LoginPostData.self, at: "login", use: signInPostHandler) // 2
        protectedRoutes.get("self", "edit", "user", use: editUserDataHandler) // 3
        protectedRoutes.get("logout", use: logoutPostHandler) // 4
        protectedRoutes.post(PostUserData.self, at: "self", "edit", "user", use: postEditUserDataHandler) // 5
        protectedRoutes.get("self", "edit", "password", use: changePasswordHandler) // 6
        protectedRoutes.post(ChangePasswordData.self, at: "self", "edit", "password", use: postChangePasswordHandler) // 7
        userRoutes.get("register", use: registerHandler) // 8
        userRoutes.post(RegisterData.self, at: "register", use: postRegisterHandler) // 9
        
       
    }
    
    
    // MARK: - REGISTER USER
    
    /**
     # Handler to render register.leaf to register a new user
     - Parameters:
        - req: Request
     - Throws: Abort Redirect
     - Returns: Future : View
   
     1. Generate and set a token to the session.
     2. Temporary optional string what stores the message.
     3. Look up if there are a message in the http request.
     4. If yes, message is the message.
     5. Otherwise message is nil.
     6. Create a context.
     7. Render a view with a context.
     */
    func registerHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        var message : String? // 2
        
        if let messge = req.query[String.self, at: "message"] { // 3
            message = messge // 4
        } else { message = nil } // 5
        
        let context = TitleTokenMessageContext(title: "Register", csrfToken: token, message: message, userLoggedIn: false, isAdmin: false) // 6
        return try req.view().render("register", context) // 7
    }
    
    
    /**
    # Handler to post register data
    - Parameters:
        - req: Request
        - data: RegisterData
    - Throws: Abort Redirect
    - Returns: Future : Response
    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    4. Call validate() on the decded RegisterData, checking each validator. This can throw ValidationError and in this case, redirect the user back to the register.leaf.
    5. When validation fails, the route handler extracts the message from the ValidationError, escapes it properly for inlcusion in a URL, and adds it to the redirect URL. Then, it redirects the user back to the registration page.
    6. Create a data.
    7. Make a UserRequest to make a put request to the API to register a new user.
     */
    func postRegisterHandler(_ req: Request, data: RegisterData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3
       
        do {  // 4
            try data.validate()
            // 5
        } catch (let error){
            let redirect : String
            if let error = error as? ValidationError, let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                redirect = "/register?message=\(message)"
            } else {
                redirect = "/register?message=Unknown+error"
            }
            return req.future(req.redirect(to: redirect))
        }
        let data = RegisterPostData(password: data.password, firstname: data.firstname, lastname: data.lastname, email: data.email) // 6
        return try UserRequest.init(ending: "register").registerUser(req, data: data) // 7
    }
    
    
    
    /**
    # Handler to get the login.leaf to login
    - Parameters:
        - req: Request
    - Throws: Abort Redirect
    - Returns: Future : View
     
    1. Generate and set a token to the session.
    2. Variable for storing the value of login error.
    3. If there are no login error:
    4. Set the boolean value to be false and create a context.
    5. Otherwise set the boolean value to be true.
    6. Get the value from the cookies-accepted cookie.
    7. Create a context.
    8. Render the login.leaf and pass the context to the view.
    */
    func loginHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        var loginError : Bool // 2
        if req.query[Bool.self, at: "error"] != nil {  // 3
            
            loginError = true // 4
        } else { // 5
            loginError = false
        }
        let showCookieMessage = req.http.cookies["cookies-accepted"] == nil // 6
        let context = LoginContext(title: "Login", csrfToken: token, loginError: loginError, showCookieMessage: showCookieMessage) // 7
        
        return try req.view().render("login", context) // 8
    }
    
    
    /**
    # Handler to post credentials to authenticate user. Returns Future<Response>.
     - Parameters:
        - req: Request
        - data: LoginPostData
    - Throws: Abort Redirect
    - Returns: Future : Response
     
    1a.  Get the expected token from the request's session.
    1b. Set the token to nil in the session.
    1c. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    1d. Create a client to make an API request.
    2. Encode username.
    3. Encode password.
    4. Create a loginPostData object with encoded password and username.
    5. Sends an HTTP POST Request to a server with a configuration closure that will run before sending.
    6. Encode loginPostData
    7. Maps a Future to a Future of a different type.
    8. Decode a content of the response to a <Token> and map the result to Response.
    9. Set the token of the User to be the token we received. This helper class saves the token to a session. Save also the token's userID (which is converted to a string) into the session and usertype.
    10. Redirect to the index page.
    11. If the chained Future resolves to an Error, call the supplied closure with 'catchMap'.
    12. In the closure redirect to the login page to show an error.
    */
    
    func signInPostHandler(_ req: Request, data: LoginPostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1a
        _ = CSRFToken(req: req).destroyToken // 1b
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 1c
        
        let client = try req.make(Client.self) // 1d
        let encodedUsername = data.username.toBase64() // 2
        let encodedPassword = data.password.toBase64() // 3
        let loginPostData = LoginPostData(csrfToken: nil, username: encodedUsername, password: encodedPassword) // 4
        
        
        let config = EegjAPIConfiguration()
        // Get the configurations
        let eegjConfig = config.setup()
        
        return client.post("http://\(eegjConfig.hostname):\(eegjConfig.port)/users/login", beforeSend: { req in // 5
            
            try req.content.encode(loginPostData) // 6
            
        }).flatMap(to: Response.self) { res in // 7
            
           return try res.content.decode(TokenData.self).map(to: Response.self) { token in    // 8
        
                // 9
                Auth.init(req: req).token = token.token.token
                Auth.init(req: req).userID = token.token.userID.uuidString
                Auth.init(req: req).usertype = token.usertype
            
       
        
            
            
            
            return req.redirect(to: "self/index") // 10
     
            }.catchMap({ error in // 11
                return req.redirect(to: "/login?error") // 12
            })
        }
    }

    /**
    # Logout Handler
    - Parameters:
        - req: Request
    - Throws: Abort Redirect
    - Returns: Future : Response

    1. Auht helper.
    2. Get the token from the session: if it doesn't exist logout the user.
    3. Set the token to the Authorization: Bearer: ... header.
    4. Make a client.
    5. Make a get request with headers to delete the token and map the response to Future<Response>.
    6. Call logout which deletes the token in the session. Redirect user to the login page
    7. Calls the supplied closure if the chained Future resolves to an Error: Logout and redirect the user to the login page.
    */
    func logoutPostHandler(_ req: Request) throws -> Future<Response> {
        
        let auth = Auth(req: req) // 1
        guard let token = Auth(req: req).token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        
        
        let client = try req.make(Client.self) // 4
        let config = EegjAPIConfiguration()
        // Get the configurations
        let eegjConfig = config.setup()
        return
            client.delete("http://\(eegjConfig.hostname):\(eegjConfig.port)/users/logout", headers: auth.headers).map(to: Response.self) { _ in // 5
            // 6
            auth.logout()
            print("User has logged out")
            return req.redirect(to: "/login")
            
        // 7
        }.catchMap { error in
            auth.logout()
            print(error)
            throw Abort.redirect(to: "/login")
        }
    }
    
    // MARK: - EDIT USER DATA HANDLERS
    
    /**
    # Get the view to update the user
     - Parameters:
         - req: Request
     - Throws: Abort Redirect
     - Returns: Future : View
    1. Generate a csrfToken.
    2. Make a UserRequest to return the user data. Catch the errors.
    3. Look if there are an error message
    4. Make a context.
    5. Render a view with the context.
     */
    func editUserDataHandler(_ req: Request) throws -> Future<View> {
        
        let ctoken = CSRFToken(req: req).addToken() // 1
        // 2
        let user = try UserRequest.init(ending: "self").getUserData(req).catchFlatMap({ error in
            print(error)
            throw Abort.redirect(to: "/error")
        })
        
        // 3
        var message : String?
        if let messge = req.query[String.self, at: "message"] {
            message = messge
        } else {
            message = nil
        }
        let context = EditUserDataContext(csrfToken: ctoken, user: user, title: "Edit User", message: message, isAdmin: Auth.isAdmin(.init(req: req))()) // 4

        return try req.view().render("editUser", context) // 5
        
    }
    
    
    /**
    # Post data to update the user data
     - Parameters:
        - req: Request
        - data: PosUserData
     - Throws: Abort Redirect
     - Returns: Future : Response
     
    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    3a. Call validate() on the decded RegisterData, checking each validator. This can throw ValidationError and in this case, redirect the user back to the register.leaf.
    3b. When validation fails, the route handler extracts the message from the ValidationError, escapes it properly for inlcusion in a URL, and adds it to the redirect URL. Then, it redirects the user back to the registration page.
    4. Create a variable which contains user data.
    5. Make a UserRequest to update the user data.
    */
    func postEditUserDataHandler(_ req: Request, data: PostUserData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3
        
        do {  // 3a
            try data.validate()
            // 3b
        } catch (let error){
            let redirect : String
            if let error = error as? ValidationError, let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                redirect = "/self/edit/user?message=\(message)"
            } else {
                redirect = "/self/edit/user?message=Unknown+error"
            }
            return req.future(req.redirect(to: redirect))
        }
        let updateUser = UserData(firstname: data.firstname, lastname: data.lastname, email: data.email) // 4
        return try UserRequest.init(ending: "edit").editUserData(req, data: updateUser) // 5
    }
    
    // MARK: - CHANGE THE PASSWORD HANDLERS
    
    /**
    # Route handler to render the view to change the password
     - Parameters:
        - req: Request
    - Throws: Abort Redirect
    - Returns: Future : View
         
    1. Handler returns a view.
    2. Generate a csrfToken.
    3. Temporary optional string what stores the message.
    4. Look up if there are a message in the http request.
    5. If yes, message is the message.
    6. Otherwise message is nil.
    7. Create a context.
    8. Render a changePassword.leaf view with the context.
     */
    func changePasswordHandler(_ req: Request) throws -> Future<View> { // 1
        let ctoken = CSRFToken(req: req).addToken() // 2
        var message : String? // 3
        // 4
        if let messge = req.query[String.self, at: "message"] {
            message = messge // 5
        } else { message = nil }// 6
        
        let context = TitleTokenMessageContext(title: "Change Password", csrfToken: ctoken, message: message, userLoggedIn: true, isAdmin: Auth.isAdmin(.init(req: req))()) // 7
        return try req.view().render("changePassword", context) // 8
    }
    
    /**
    # Route handler to update the password of the user
     - Parameters:
        - req: Request
        - data: ChangePasswordData
     - Throws: Abort Redirect
     - Returns: Future : Response

     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
     3a. Call validate() on the decded RegisterData, checking each validator. This can throw ValidationError and in this case, redirect the user back to the register.leaf.
     3b. When validation fails, the route handler extracts the message from the ValidationError, escapes it properly for inlcusion in a URL, and adds it to the redirect URL. Then, it redirects the user back to the registration page.
     5. Make UserRequest to send the updated data.
     
     */
    func postChangePasswordHandler(_ req: Request, data: ChangePasswordData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3
        
        do {  // 3a
            try data.validate()
            // 3b
        } catch (let error){
            let redirect : String
            if let error = error as? ValidationError, let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                redirect = "/self/edit/password?message=\(message)"
            } else {
                redirect = "/self/edit/password?message=Unknown+error"
            }
            return req.future(req.redirect(to: redirect))
        }
        return try UserRequest.init(ending: "change/password").changePassword(req, data: data) // 4
    }
}

/// # EditUserData Context
/// - csrfToken : String
/// - User.Public : User object
/// - title : String
/// - message : String? = Validation error message

struct EditUserDataContext : Encodable {
    let csrfToken : String?
    let user : Future<User.Public>
    let title : String
    let message: String?
    let userLoggedIn : Bool = true
    let isAdmin : Bool
}

/// # Context contains title and csrfToken
/// - title : Sting = Title of the page
/// - csrfToken : String?
/// - message : String? = Validation error message
struct TitleTokenMessageContext : Encodable {
    
    let title : String
    let csrfToken : String?
    let message : String?
    let userLoggedIn : Bool
    let isAdmin : Bool
}


/// # PostUserData contains data from the editUser.leaf
/// - csrfToken? : String
/// - firstname : String
/// - lastname : String
/// - email : String
struct PostUserData : Content {
    let csrfToken : String?
    let firstname : String
    let lastname : String
    let email : String
    
}

/// # UserData contains data to update the user data
/// - firstname : String
/// - lastname : String
/// - email : String
struct UserData : Content {
    let firstname : String
    let lastname : String
    let email : String
}


/// # Data from the changePassword.leaf to change the password
/// - csrfToken : String
/// - oldPassword : String
/// - newPassword : String
/// - passwordConf : String
struct ChangePasswordData : Content {
    let csrfToken : String?
    let oldPassword : String
    let newPassword : String
    let passwordConf : String
}
/// # RegisterData contains data from register.leaf
/// - csrfcsrfToken : String?
/// - firstname : String
/// - lastname : String
/// - email : String
/// - password : String
/// - confirmPassword : String
/// - iAcceptTC : String?
struct RegisterData : Content {
    let csrfToken : String?
    let firstname : String
    let lastname : String
    let email : String
    let password : String
    let confirmPassword : String
    let iAcceptTC : String?
}
/// # CSRFTokenData
/// - csrfToken: String?
struct CSRFTokenData : Content {
    let csrfToken: String?
}

/// # TokenData
/// - token : Token
/// - usertype : String
struct TokenData : Content {
    let token : Token
    let usertype : String
}
