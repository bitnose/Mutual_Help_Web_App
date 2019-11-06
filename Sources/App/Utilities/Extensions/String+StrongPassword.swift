//
//  String+StrongPassword.swift
//  App
//
//  Created by Sötnos on 06/11/2019.
//

import Foundation
/**
 # Extension for String to check whether the password is strong or not
 1. Boolean value which returns true if password is strong and false if not
 2. If the string contains one capital, one number and one small letter and the total count is up to 8, then password is strong.
 */
extension String {
     var isStrongPassword: Bool { // 1
        // 2
        return range(of: "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$", options: .regularExpression) == range(of: self)
    }
}

