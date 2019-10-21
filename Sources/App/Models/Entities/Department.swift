//
//  Department.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

/** # Model for Department
 - id : UUID?
 - departmentNumber : Int
 - departmentName : String
 - coutnryID : UUID
 */
final class Department : Codable {
    
    var id : UUID?
    var departmentNumber : Int
    var departmentName : String
    var countryID : UUID
    /// # Init
    init(departmentNumber : Int, departmentName : String, countryID : UUID) {
        self.departmentNumber = departmentNumber
        self.departmentName = departmentName
        self.countryID = countryID
        
    }
}

// Conform Content
extension Department : Content {}
