//
//  Department.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

// Model for Department

final class Department : Codable {
    
    var id : UUID?
    var departmentNumber : Int
    var departmentName : String

    init(departmentNumber : Int, departmentName : String) {
        self.departmentNumber = departmentNumber
        self.departmentName = departmentName
        
    }
}

