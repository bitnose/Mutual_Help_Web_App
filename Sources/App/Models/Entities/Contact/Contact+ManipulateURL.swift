//
//  Contact+ManipulateURL.swift
//  App
//
//  Created by Sötnos on 13/07/2019.
//

import Foundation

extension Contact {
    
    /*
     1. Function to manipulate the String to get the username.
     2. Checking If the string starts with ("https://www.facebook.com/") the right URL.
     3. If yes, Get the rest of the string. Return the last index where the specified value appears in the collection, look for nils.
        4. Get the string starting from the index.
        5. Convert to the String.
        6. Call function to create a new link to the Messenger.
     7. Else: the beginning is different.
     8. Print that the URL is not valid.
     9. Return the finalLink.
     
     */
    
    func manipulateFBProfileLink(fbProfileURL : String) -> String? { // 1.
        
        var finalLink : String?
        
        if fbProfileURL.hasPrefix("https://www.facebook.com/") == true { // 2.

            guard let index = fbProfileURL.lastIndex(of: "/") else {print("Index is nil."); return nil} // 3.
        
            let end = fbProfileURL[index...] // 4.
            let username = String(end) // 5.
            finalLink = createURLtoMessenger(username: username) // 6.
        
        } else { // 7.
            print("URL is not valid.") // 8.
        }
        return finalLink // 9.
    }
    
    /*
     1. Function to create a new string (URL) for the Messenger: Input is the FB username; Function returns a sring.
     2. Link to the Messenger.
     3. Combine two strings and create a new string (URL to the Messenger)
     4. Return the new string.
     
     
     */
    
    func createURLtoMessenger(username : String) -> String { // 1.
        let linkToMessenger = "https://www.facebook.com/messages/t" // 2.
        let linkToPersonsMessenger = linkToMessenger + username // 3.
        return linkToPersonsMessenger // 4.
    }
}
