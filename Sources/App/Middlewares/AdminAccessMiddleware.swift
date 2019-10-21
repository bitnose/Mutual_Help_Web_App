//
//  StandardAccessMiddleware.swift
//  App
//
//  Created by Sötnos on 03/09/2019.
//

import Foundation
import Vapor
import Leaf


/// # Custom AdminMiddleware looks the usertype of the user.
/// 1. Called with each Request that passes through this middleware. Returns a response.
/// 2. Create an Authentication helper.
/// 3. Get the Auth token; if error occurs redirect to the login page.
/// 4. Add token to the headers (bearer)
/// 5. Make a client.
/// 6. Make a get request with the headers.
/// 7. Decode the content of the response to Future<Response> and after completion handler return Future<Response>.
/// 8. Look if usertype is admin.
/// 9. If it's admin chain the request to the next middleware normally.
/// 10. If usertype is not admin, throw and abort and redirect to the error page.
/// 11. If the resolving future resolves as an error catch it and throw abort to redirect to the error.leaf page.

final class AdminAccessMiddleware : Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> { // 1
        
        let auth = Auth(req: request) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
    
        let client = try request.make(Client.self) // 5
        
        return client.get("http://localhost:9090/api/users/access", headers: auth.headers).flatMap(to: Response.self) { res in // 6
            return try res.content.decode(User.Public.self).flatMap(to: Response.self) { user in // 7
                if user.userType == .admin { // 8
                    return try next.respond(to: request) // 9
                } else {
                    throw Abort.redirect(to: "/error") // 10
                }
            }.catchMap({ error in // 11
                print(error)
                throw Abort.redirect(to: "/error")
            })
        }
    }
}



