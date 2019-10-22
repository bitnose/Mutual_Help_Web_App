//
//  Ad+Date.swift
//  App
//
//  Created by Sötnos on 21/10/2019.
//

import Foundation


/// # Extension to convert the Ad's date property to a date.

extension Date {
    
    static func convertToDate(date: Date) -> String {
        
        if #available(OSX 10.12, *) {
            let formatter = ISO8601DateFormatter()
            formatter.timeZone = TimeZone.init(abbreviation: "CET")
           
            
            let d = formatter.string(from: date)
             print("\(d)")
            return d
    
        } else {
            print("Not available")
            return "No"
        }

    }
    
    
}

