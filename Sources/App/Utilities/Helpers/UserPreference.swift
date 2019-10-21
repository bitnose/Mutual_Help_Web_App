//
//  UserPreference.swift
//  App
//
//  Created by Sötnos on 15/10/2019.
//
import Foundation
import Crypto
import Vapor

/**
 # Helper Class to save User Preferences
    - defaultsKey is the Name of the Session (The selected department)
    - req : Request
    - departmentID : Optional String
    Getter
      - Try to get the token from the session
      - Catch the errors if there are: If yes, return nil
    Setter
    - Add a new token to the session
    - Catch errors if there are: If yes, stop execution and print a message
*/
final class UserPreference {
    
    let defaultsKey = "DEPARTMENT_KEY"
    let req: Request
    var departmentID : String? {
           
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
    /**
     # Initialization of the Request
     - Parameters:
        - req : Request
     */
    init(req: Request) {
        self.req = req
    }

    /**
     # Method to clear the session key
        1. Try to update the value to nil
        2. Catch errors if there are: If yes, stop execution and print a message
    */
    func clear() {
        do {
            try req.session()[defaultsKey] = nil // 1
        } catch {
            fatalError("Cache: Could not destroy session") // 2
        }
    }
}
