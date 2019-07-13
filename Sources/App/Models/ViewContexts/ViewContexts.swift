//
//  ViewContexts.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

// This file contains context data to the views.

/// MARK: - Declaration of the New Data Types

/*
 View context for the "landing.leaf"
 - countries : Array of all future countries
 */

struct CountryContext : Encodable {
    let countries : [CountryData]
    let title : String
}

struct CountryData : Encodable {
    let country : Country
    let departments : Future<[Department]>
    
}



/// View Context for the "adList.leaf"
/*
 AdsOfPerimeterData
 - Array of AdObjects
 - Department what was used to make a query
 */
struct AdsOfPerimeterData : Content {
    let ads : [AdObject]
    let selectedDepartment : Department
}
/*
 A New Datatype : AdObject
 - Note of the Ad
 - Demands of the Ad
 - Offers of the Ad
 - City of the Ad
 - Department of the City
 */
struct AdObject : Content {
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let city : City
    let department : Department
}

/*
 Contains data for "offer.leaf"
 */


struct AdData : Content {
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let department : Department
    let city : City
    let hearts : Int
    
    
    
}

/*
 Contains data for "contact.leaf"
 */

struct ContactContext : Encodable {
    let title : String
    let name : String
    let messenger : String
}
