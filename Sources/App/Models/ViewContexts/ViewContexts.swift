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


/// Data Type contains data to make an api request to delete data
/// - adID : The id of the ad which will be deleted
/// - csrfToken : Optional token to protect agains csrf attacks
struct CsrfToken : Content {
    let csrfToken : String?
}

/// View context for the "landing.leaf"
/// - countries : Array of CountryData
/// - title : title of the page
struct CountryContext : Encodable {
    let countries : [CountryData]
    let title : String
}
/// Context contains data to "landing.leaf"
/// - country
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
    let images : [String]?
}

/// Contains data for "offer.leaf"
/// - note : Note of the Ad
/// - adID : UUID of the Ad
/// - demands : Array of demands of the ad
/// - offers : Array of the offers of the ad
/// - deparment : Deparmant of the city
/// - city : City of the Ad
/// - hearts : Count of the likes of the ad

struct AdInfoData : Content {
    let csrfToken: String?
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let department : Department
    let city : City
    let hearts : Int
    let images : [String]?
    let createdAt : Date
    let generosity : Int
}


struct AdInfoPostData : Content {
    let csrfToken: String?
    let note : String
    let adID : UUID
    let demands : [String]
    let offers : [String]
    let cityID : UUID
    let generosity : Int
    let contactID : UUID
    let contactName : String
    let facebookLink : String
    let adLink : String
}






struct FullAdContext : Encodable {
    let title : String
    let adInfo : AdInfoData
    let contact : Future<Contact>
    let csrfToken : String?
    let cities : Future<[City]>?
}


/// Edit Ad - Data type
/// - note : Note of the Ad
/// - adID : UUID of the Ad
/// - demands : Array of demands of the ad
/// - offers : Array of the offers of the ad
/// - deparment : Deparmant of the city
/// - city : City of the Ad
/// - hearts : Count of the likes of the ad
/// - images : Optional array of Strings
/// - generosity : Integer value to measure the generosity of the ad
/// - adLink : Link to the ad in the facebook
/// - facebookLink : Link to the contact's facebook messenger
/// - contactName : Name of the contact

struct  EditAdData : Content {
    let csrfToken: String?
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let department : Department
    let city : City
    let hearts : Int
    let images : [String]?
    let generosity : Int
    var adLink : String
    var facebookLink : String
    var contactName : String

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

/// Data to Add a new Country
///  - country : name of the country
struct CountryPostData : Content {
    let country : String
    let csrfToken : String?
}

/// CSRFToken Context
/// - title : Title of the page
/// - csrfToken : token to protect against CSRF attacks
struct CSRFTokenContext : Encodable {
    let title : String
    let csrfToken : String?
}


/// Data to Add a new Department
///  - departmentName : name of the department
///  - departmentNumber : Number of the department
///  - countryID : Country of the Deparment
///  - csrfToken : A token to protect against CSRF attacks
struct DepartmentPostData : Content {
    let departmentName : String
    let departmentNumber : Int
    let countryID : UUID
    let csrfToken : String?
}

/// Data type which contains data to create a perimeter
/// - department : Selected department
/// - departments : Array of the neighbour departments
/// - csrfToken : A token to protect against CSRF attacks
struct CreatePerimeterPostData : Content {
    let departmentID : UUID
    let departmentIDs : [UUID]
    let csrfToken : String?
}


/// Add Department Context
/// - array of Future Countries
/// - title : Title of the page
/// - csrfToken : token to protect against CSRF attacks
struct AddDepartmentContext : Encodable {
    let countries : EventLoopFuture<[Country]>
    let title : String
    let csrfToken : String?
}

/// Add a city context
///  - title
///  - departments : Array of Future Departments
///  - csrfToken : Optional string
struct DepartmentsContext : Encodable {
    let title : String
    let departments : EventLoopFuture<[Department]>
    let csrfToken : String?
}


/// Add a city context
///  - title
///  - departmentID : Department of the city (UUID)
/// csrfToken : Optional string
struct AddCityData : Content {
    let city : String
    let departmentID : UUID
    let csrfToken : String?
}


/// Add a city data
/// - csrfToken : Optional string
/// - contactName
/// - adLink
/// - facebookLink
struct AddContactData : Content {

    let csrfToken : String?
    let contactName : String
    let adLink : String
    let facebookLink : String
}


/// Add a city data
/// - csrfToken : Optional string
/// - contact
/// - department
/// - citu
struct AddAdContext : Encodable {
    let title : String
    let csrfToken : String?
    let contact : EventLoopFuture<Contact>
    let cityDepartment : EventLoopFuture<CityDepartment>
}

/// CityDepartment Data type
/// - department
/// - city
struct CityDepartment : Content {
    let city: City
    let department : Department
}

/// Data type contains data to create a contact
/// - csrfToken : Optional string
struct AdPostData : Content {
    let csrfToken : String?
    let generosity : Int
    let note : String
    let demands : [String]?
    let offers : [String]?
}


// MARK: - Image Contexst and Datas
/// ImageContect : Contains data for addImage -view.
/// - title : String
/// - csrfToken : Optional token
struct ImageContext : Encodable {
    let title : String
    let adID : UUID
    let csrfToken : String?
}

/// ImagePostData from the view.
/// - image : Data
/// - csrfToken : Optional token to protect against csrf -attacks.
struct ImagePostData : Content {
    let image : Data
    let csrfToken : String?
}

/// ImageData is a new data type which contains data to post image data.
/// - image : Data
/// - adID : Optional UUID
struct ImageData : Content {
    let image : Data
    let adID : UUID?
}


/// Data type contains data for image.leaf -view.
/// - title <String> : Title of the page
/// - imagesLinks Array<String> : Array of the Strings
/// - adID <UUID> : id of the selected ad.
struct ImageLinksContext : Encodable {
    let title : String
    let imagesData : [ImageLink]?
    let adID : UUID
    let csrfToken : String?

}

/// Image link
/// - imageLink : A Link to display an image
/// - imageName : A name of the image
struct ImageLink : Content {
    let imageLink : String
    let imageName : String
    
}

