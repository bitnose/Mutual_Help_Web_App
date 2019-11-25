//
//  Ad+Date.swift
//  App
//
//  Created by Sötnos on 21/10/2019.
//

import Foundation


/** # Extension to convert the Ad's date property to a date.
 - parameters: Date
 - returns: String
 
 1. This function formats Ad's date property to a date.
 2. Checking the operating system.
 3. Formatter object
 4. Add time zone (Central Europian TImezone)
 5. Using the date formatter, convert the date to a string.
 6. Return the date.
 7. If the formatter is not available, return "No".
 */
extension Date {
    
    static func convertToDate(date: Date) -> String { // 1
        
        if #available(OSX 10.12, *) { // 2
            let formatter = ISO8601DateFormatter() // 3
            formatter.timeZone = TimeZone.init(abbreviation: "CET") // 4
           
            let d = formatter.string(from: date) // 5
            return d // 6
    
        } else { // 7
            print("Not available")
            return "No"
        }

    }
    
    
}

