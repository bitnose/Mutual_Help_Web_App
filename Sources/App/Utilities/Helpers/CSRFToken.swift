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
/// # Helper Class to Help with Authentication
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
    /// # Initialization of the Request
    ///
    init(req: Request) {
        self.req = req
    }

    ///
    ///  #  Method to set the CSRFsession to nil
    /// 1. Set the token to nil
    /// 2. Catch errors if there are: If yes, stop execution and print a message
    ///
    func destroyToken() {
        do {
            try req.session()[defaultsKey] = nil // 1
        } catch let error { // 2
            print(error)
            fatalError("Cache: Could not destroy session")
        }
    }
    /// # Method to generate a token and save it to the session
    /// - returns: String?
    /// 1. Generate a random token using CryptoRandom
    /// 2. Save the token to the session
    /// 3. Return the token
    /// 4. Catch errors if there are anyt.
    func addToken() -> String? {
        do {
            let token = try CryptoRandom().generateData(count: 16).base64EncodedString() // 1
            try req.session()[defaultsKey] = token // 2
            return token // 3
        } catch let error { // 4
            print(error)
            fatalError("Cache: Saving not successful")
        }
    }
    
    /// # Method to get a token and from the session
    /// - returns: String?
    /// 1. Try to return the token form the session.
    /// 2. Catch errors if there are anyt.
    func getToken() -> String? {
        do {
             return try req.session()[defaultsKey] // 1
        } catch let error { // 2
            print(error)
            fatalError("Cache: Saving not successful")
        }
    }
}
