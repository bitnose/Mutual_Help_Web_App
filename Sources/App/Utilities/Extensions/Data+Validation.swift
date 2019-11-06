//
//  RegisterData+Validation.swift
//  App
//
//  Created by Sötnos on 23/09/2019.
//

import Foundation
import Vapor



/// # Extension for the Registerdata to make it conform to Validatable and Reflectable.
/// - Validatable allows you to validate types with Vapor
/// - Reflectable provides a way to discover the internal components of a type
/// - Because you use key paths, Vapor creates type-safe validations.

/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure RegisterData's firstname and lastname contains only alphanumeric characters and the count of the characters is 1-20.
/// 4. Add a validator to ensure RegisterData's email is a valid email address.
/// 5. Add a validator to ensure RegisterData's password's character's count is 8-20 and it's alphanumeric
/// # Custom Validator
/// 6. Use Validation's add(_:_:) to add a custom validator for RegisterData. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validaation fails.
/// 7. Verify that password and confirmPassword match.
/// 8. If they don't, throw BasicValidationError.
/// 9. Use Validation's add(_:_:) to add a custom validator for RegisterData. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validaation fails.
/// 10. Verify that iAcceptTC is not nil.
/// 11. If it's not, throw BasicValidationError.
/// 12. Ensure if the password is a a strong password.
/// 13. If not throw an error.
/// 14. Return the validations for Vapor to test.
extension RegisterData: Validatable, Reflectable {
    
    static func validations() throws -> Validations<RegisterData> { // 1
        
        var validations = Validations(RegisterData.self) // 2
        try validations.add(\.firstname, .alphanumeric && .count(1...35)) // 3
        try validations.add(\.lastname, .alphanumeric && .count(1...35)) // 3
        try validations.add(\.email, .ascii && .count(5...60)) // 4
        try validations.add(\.password, .count(8...30) && .alphanumeric) // 5

        validations.add("password match") { model in // 6

            guard model.password == model.confirmPassword else { // 7
                throw BasicValidationError("passwords don't match") // 8
            }
        }
        validations.add("accept the Terms and Conditions") { model in // 9
            guard let _ = model.iAcceptTC else { // 10
                throw BasicValidationError("the terms and conditions are not accepted") // 11
            }
        }
        validations.add("Strong password") { model in // 12
            guard model.password.isStrongPassword else { // 13
                throw BasicValidationError("Password must be 8 characters and contain uppercase letters, special character, numerals and lower case letters")
            }
        }
        
        return validations // 14
        
    }
}

/// # Extend PostUserData : Validate the data which will be used to edit the user
/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure data's firstname and lastname contains only alphanumeric characters and the count of the characters is 1-20.
/// 4. Add a validator to ensure data's email is a valid email address.
/// 5. Return the validations for Vapor to test.
extension PostUserData : Validatable, Reflectable {
    
    static func validations() throws -> Validations<PostUserData> { // 1
        
        var validations = Validations(PostUserData.self) // 2
        try validations.add(\.firstname, .alphanumeric && .count(1...35)) // 3
        try validations.add(\.lastname, .alphanumeric && .count(1...35)) // 4
        try validations.add(\.email, .email && .count(5...60)) // 5
        
        return validations // 13
    }
}

/// # Extend ChangePasswordData : Validate the data which will be used to change the password of the user account
/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure data's oldPassword's and newPassword's characters' count is 8-20.
/// Custom Validator
/// 4. Use Validation's add(_:_:) to add a custom validator for model. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validaation fails.
/// 5. Verify that newPassword and passwordConf match.
/// 6. If they don't, throw BasicValidationError.
/// 7. Ensure if the password is a a strong password.
/// 8. If not throw an error.
/// 9. Return the validations for Vapor to test.
extension ChangePasswordData : Validatable, Reflectable {
    static func validations() throws -> Validations<ChangePasswordData> { // 1
        
        var validations = Validations(ChangePasswordData.self) // 2
        try validations.add(\.oldPassword, .count(8...30) && .alphanumeric) // 3
        try validations.add(\.newPassword, .count(8...30) && .alphanumeric) // 3
       
        validations.add("password match") { model in // 4
            guard model.newPassword == model.passwordConf else { // 5
                throw BasicValidationError("passwords don't match") // 6
            }
        }
        
        validations.add("Strong password") { model in // 7
            guard model.newPassword.isStrongPassword else { // 8
                throw BasicValidationError("Password must be 8 characters and contain uppercase letters, special character, numerals and lower case letters")
            }
        }
        
        return validations // 9
    }
}




/// # Extend CreateAdUserData : Validate the data which will be used to create ad
/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure data's city contains only ascii characters and the count of the characters is 1-20.
/// 4. Add a validator to ensure data's note contains only ascii characters and the count of the characters is max 30.

/// Custom validation
/// 5. Use Validation's add(_:_:) to add a custom validator for model. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validaation fails.
/// 6. Verify that the departmentID is not nil.
/// 7. If it's, throw BasicValidationError.
/// 8. Return the validations for Vapor to test.
extension CreateAdUserData : Validatable, Reflectable {
    
    static func validations() throws -> Validations<CreateAdUserData> { // 1
        
        var validations = Validations(CreateAdUserData.self) // 2
        try validations.add(\.city, .alphanumeric && .count(1...35)) // 3
        try validations.add(\.note, .alphanumeric && .count(...100)) // 4
        
        validations.add("select a department") { model in // 5
            
            guard let _ = model.departmentID else { // 6
                throw BasicValidationError("select a department") // 7
            }
        }
        return validations // 8
    }
}



/// # Extend CreateAdUserData : Validate the data which will be used to create ad
/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure data's city contains only ascii characters and the count of the characters is 1-20.
/// 4. Add a validator to ensure data's note contains only ascii characters and the count of the characters is max 30.
/// Custom validation
/// 5. Use Validation's add(_:_:) to add a custom validator for model. This takes a readable description as the first parameter. The second parameter is a closure that should throw if validaation fails.
/// 6. Verify that the departmentID is not nil.
/// 7. If it's, throw BasicValidationError.
/// 8. Return the validations for Vapor to test.
extension AdInfoPostData : Validatable, Reflectable {
    
    static func validations() throws -> Validations<AdInfoPostData> { // 1
        
        var validations = Validations(AdInfoPostData.self) // 2
        try validations.add(\.city, .alphanumeric && .count(1...35)) // 3
        try validations.add(\.note, .alphanumeric && .count(...100)) // 4
        
        validations.add("select a department") { model in // 5
            
            guard let _ = model.departmentID else { // 6
                throw BasicValidationError("select a department") // 7
            }
        }
        return validations // 8
    }
}


/// # Extend ImagePostData : Validate the data which will be send is not nil
/// 1. Implement validations() as required by Validatable.
/// 2. Create a Validations instance to contain the various validators.
/// 3. Add a validator to ensure that image is not nil.
/// 4. If it's nil, throw BasicValidationError
/// 5. Add a custom validation to ensure that the image is not too big.
/// 6.
extension ImagePostData : Validatable, Reflectable {
    
    static func validations() throws -> Validations<ImagePostData> { // 1
        var validations = Validations(ImagePostData.self) // 2
      
        validations.add("image is not selected") { model in // 3
            if model.image.isEmpty {
                throw BasicValidationError("image is not selected") // 4
            }
        }
        validations.add("image is too big") { model in // 5
      
            if model.image.count > 10_000_000 { // 6
                print(model.image.count, model.image)
                throw BasicValidationError("image is too big") // 7
            }
        }
        
        return validations // 4
    }
}
