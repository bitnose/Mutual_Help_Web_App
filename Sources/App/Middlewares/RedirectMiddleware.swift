//
//  RedirectMiddleware.swift
//  App
//
//  Created by Sötnos on 28/07/2019.
//

import Foundation
import Vapor

/// Custom RedirectMiddleware looks if a user is authenticated: If not it redirects the user to the login page.
/// 1. Called with each Request that passes through this middleware.
/// 2. Look if the user is authenticated: If the value is equal to false.
/// 3. Throw an abort and redirect to the "login" page.
/// 4. If the user is auhtenticated ie. the value is equal to true.
/// 5. Chain to the next middleware normally.

final class RedirectMiddleware : Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> { // 1
        if Auth.init(req: request).isAuthenticated() == false { // 2
            throw Abort.redirect(to: "login") // 3
        } else { // 4
            return try next.respond(to: request) // 5
        }
    }
}

