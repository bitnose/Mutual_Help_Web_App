//
//  CSRFToken.swift
//  App
//
//  Created by Sötnos on 31/07/2019.
//

import Foundation
import Crypto
import Vapor

///
/// Helper Class to Help with Authentication
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
///     - Headers : HTTPHeaders = ("application/json")
final class CSRFToken {
    
    let defaultsKey = "CSRF_TOKEN"
    let req: Request
    var CSRFToken: String?
    ///
    ///     - Initialization of the Request
    ///
    init(req: Request) {
        self.req = req
    }

    ///
    ///        Method to destroy the CSRFsession
    ///         - Destroys the current session, if one exists
    ///         - Catch errors if there are: If yes, stop execution and print a message
    ///
    func destroyToken() {
        do {
            try req.session()[defaultsKey] = nil
        } catch {
            fatalError("Cache: Could not destroy session")
        }
    }
    
    func addToken() -> String? {
        do {
            let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
            try req.session()[defaultsKey] = token
            return token
        } catch {
            fatalError("Cache: Saving not successful")
        }
    }
    
    func getToken() -> String? {
        do {
             return try req.session()[defaultsKey]
        } catch {
            fatalError("Cache: Saving not successful")
        }
    }
}
