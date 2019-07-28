//
//  Auth.swift
//  App
//
//  Created by Sötnos on 27/07/2019.
//
import Foundation
import Vapor

///
/// Helper Class to Help with Authentication
///
///     - DefaultsKey is the Name of the Session
///     - Request
///     - Token Getter
///         - Try to get the token from the session
///         - Catch the errors if there are: If yes, return nil
///     - Token Setter
///         - Add a new token to the session
///         - Catch errors if there are: If yes, stop execution and print a message
///
final class Auth {
    let defaultsKey = "MH-API-KEY"
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
///
///     - Initialization of the Request
///
    init(req: Request) {
        self.req = req
    }
///
///     - Method which returns a boolean value
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
///     - Method to logout the user
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
}
