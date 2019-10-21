//
//  User.swift
//  App
//
//  Created by Sötnos on 15/07/2019.
//

import Foundation
import Vapor

/// # User Model
/// - id : UUID?
/// - firstname : firstname of the user
/// - lastname : lastneme of the user
/// - email : email address of the user (this is username)
/// - password : secret password
/// - usertype : usertype (Enum: admin/standard/restricted)

final class User : Codable {
    
    var id : UUID?
    var firstname : String
    var lastname : String
    var email : String
    var password : String
    var userType : UserType

    
    
    /// # Init User
    init(firstname: String, lastname: String, email: String, password : String, userType: UserType) {
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.password = password
        self.userType = userType
    }
    
    /// # Public class of the User
    /// - Inner class to represent a public view of User (To protect password hashes you should never return them in responses)
    
    final class Public: Codable {
        var id: UUID?
        var firstname: String
        var lastname: String
        var email : String
        var userType : UserType
        /// # Init
        init(id: UUID?, firstname: String, lastname: String, email : String, userType: UserType) {
            self.id = id
            self.firstname = firstname
            self.lastname = lastname
            self.email = email
            self.userType = userType
        }
    }
}

// MARK: - Extensions

extension User : Content {} // Conform Content

extension User.Public: Content {} // Conforms User.Public to Content, allowing you ro return the public view in responses.

/**
 1. Defien a method on User that returns User.Publi
 2. Crete a public version of the current object
 */

extension User {
    func convertToPublic() -> User.Public { // 1
        return User.Public(id: id, firstname: firstname, lastname: lastname, email: email, userType: userType) // 1
    }
}

/**
 # Extension allows you to call convertToPublic() on Future<User> which helps tidy up your code and reduce nesting. Allow you to vhange your route handlers to return public users.
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

