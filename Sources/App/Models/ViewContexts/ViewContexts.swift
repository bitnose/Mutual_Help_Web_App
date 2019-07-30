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


/// View context for the "landing.leaf"
/// - countries : Array of CountryData
/// - title : title of the page
struct CountryContext : Encodable {
    let countries : [CountryData]
    let title : String
}
/// Context contains data to "landing.leaf"
/// - county
//  - departments : Array of departments of the country
struct CountryData : Encodable {
    let country : Country
    let departments : Future<[Department]>
    
}

/// Context Contains data for "adList.leaf"
/// - data : Ads of Perimeter Data
/// - showOffer : Boolean value to tell which one to show: Offer or Demands
struct AdContext : Content {
    let data : AdsOfPerimeterData
    let showOffer : Bool
}

/// Data for the "adList.leaf"
/// - ads : Array of AdObjects
/// - selectedDepartment : Selected department
struct AdsOfPerimeterData : Content {
    let ads : [AdObject]
    let selectedDepartment : Department
}

/// A New Datatype : AdObject
/// - Note of the Ad
/// - Demands of the Ad
/// - Offers of the Ad
/// - City of the Ad
/// - Department of the City

struct AdObject : Content {
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let city : City
    let department : Department
}



/// Contains data for "offer.leaf"
/// - note : Note of the Ad
/// - adID : UUID of the Ad
/// - demands : Array of demands of the ad
/// - offers : Array of the offers of the ad
/// - deparment : Deparmant of the city
/// - city : City of the Ad
/// - hearts : Count of the likes of the ad

struct AdData : Content {
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let department : Department
    let city : City
    let hearts : Int   
}


/// Contains data for "contact.leaf"
/// - title of the page
/// - name : Name of the contact
/// - messenger : Link to the Facebook Messinger
struct ContactContext : Encodable {
    let title : String
    let name : String
    let messenger : String
}
/// Contains data for "index.leaf"
/// - title of the page
/// - ads : Array of Future ads
struct AllAdsContext : Encodable {
    let title : String
    let ads : EventLoopFuture<[Ad]>
}


/// Login context for the login.leaf
/// - title = "Log in"
/// - loginError : Bool which tells if there was errors
struct LoginContext : Encodable {
    let title = "Log in"
    let loginError : Bool
    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}

/// LoginPostData / User's credentials
/// - username
//  - password
struct LoginPostData : Content {
    let username : String
    let password : String
}



