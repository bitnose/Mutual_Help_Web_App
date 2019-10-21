//
//  UserType.swift
//  App
//
//  Created by Sötnos on 30/07/2019.
//

import Foundation
import Vapor


/// # A new enum string type to the user to define basic user access levels
/// - admin : Full Access (Registered Users with Admin Panel)
/// - standard : Basic Access (Registered Users)
/// - restricted : Limited Access (Unregistered Users)

enum UserType: String, Codable {
    case admin
    case standard
    case restricted
}

extension UserType : Content {}
