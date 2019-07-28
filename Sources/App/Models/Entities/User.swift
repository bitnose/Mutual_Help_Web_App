//
//  User.swift
//  App
//
//  Created by Sötnos on 15/07/2019.
//

import Foundation
import Vapor
import Authentication


final class User : Codable {
    
    var id : UUID?
    var firstname : String
    var lastname : String
    var email : String
    var password : String
    
    // Init User
    init(firstname: String, lastname: String, email: String, password : String) {
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.password = password
    }
    
    // Public class of the User : Inner class to represent a public view of User (To protect password hashes you should never return them in responses)
    
    final class Public: Codable {
        var id: UUID?
        var firstname: String
        var lastname: String
        var email : String
        
        init(id: UUID?, firstname: String, lastname: String, email : String) {
            self.id = id
            self.firstname = firstname
            self.lastname = lastname
            self.email = email
        }
    }
}

// MARK: - Extensions

extension User : Content {} // Conform Content

extension User.Public: Content {} // Conforms User.Public to Content, allowing you ro return the public view in responses.

/*
 1. Defien a method on User that returns User.Publi
 2. Crete a public version of the current object
 */

extension User {
    func convertToPublic() -> User.Public { // 1
        return User.Public(id: id, firstname: firstname, lastname: lastname, email: email) // 1
    }
}

/*
 Extension allows you to call convertToPublic() on Future<User> which helps tidy up your code and reduce nesting. Allow you to vhange your route handlers to return public users.
 1. Define an extension for Future<User>.
 2. Define a new method that returns a Future<User.Public>
 3. Unwrap the user contained in self.
 4. Convert the User object to User.Public
 */

extension Future where T: User { //1
    func convertToPublic() -> Future<User.Public> { // 2
        return self.map(to: User.Public.self) { user in // 3
            return user.convertToPublic() // 4
        }
    }
}

