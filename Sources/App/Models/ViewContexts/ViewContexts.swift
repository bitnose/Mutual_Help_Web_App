//
//  ViewContexts.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor

// This file contains context data to the views.

// MARK: - Declaration of the New Data Types

/**
 # CsrfToken
- csrfToken : Optional token to protect agains csrf attacks
- adID : The id of the ad which will be deleted
 */
struct CsrfToken : Content {
    let csrfToken : String?
    let adID : UUID
}

/**
 # View context for the "landing.leaf"
 - countries : Future<[CountryWithDepartments]>
 - title : String
 - userLoggedIn : Bool
 - isAdmin : Bool
 - csrfToken : String?
 - showCookieMessage : Bool
 */

struct CountryContext : Encodable {
    let countries : Future<[CountryWithDepartments]>
    let title : String
    let userLoggedIn : Bool
    let isAdmin : Bool
    let csrfToken : String?
    let showCookieMessage : Bool
}
/**
 # Context contains data to "landing.leaf"
- country
- departments : Array of departments of the country
 */
struct CountryData : Encodable {
    let country : Country
    let departments : Future<[Department]>
    
    
}

/**
 # Context Contains data for "adList.leaf"
 - title : String
 - data : Ads of Perimeter Data
 - showOffer : Boolean value to tell which one to show: Offer or Demands
 - isAdmin : Bool
 - userLoggedIn : Bool
 */
struct AdContext : Encodable {
    let title : String
    let data : Future<AdsOfPerimeterData>
    let showOffer : Bool
    let isAdmin : Bool
    let userLoggedIn : Bool
}

/**
 # Data for the "adList.leaf"
- ads : Future <[AdObject]>
- selectedDepartment : <Department>
 */
struct AdsOfPerimeterData : Content {
    let ads : [AdObject]
    let selectedDepartment : Department
}

/**
# Contains data for "offer.leaf"
 - note : Note of the Ad
 - adID : UUID of the Ad
 - demands : Array of demands of the ad
 - offers : Array of the offers of the ad
 - city : City of the Ad
 - deparment : Deparmant of the city

 */
struct AdObject : Content {
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let city : City
    let department : Department
}



/**
# Contains data for "offer.leaf"
 - note : Note of the Ad
 - adID : UUID of the Ad
 - demands : Array of demands of the ad
 - offers : Array of the offers of the ad
 - deparment : Deparmant of the city
 - city : City of the Ad
 - hearts : Count of the likes of the ad
 - images :  Image names ?
 */

struct AdData : Content {
    let note : String
    let adID : UUID
    let demands : [Demand]
    let offers : [Offer]
    let department : Department
    let city : City
    let hearts : Int
    let images : [String]?
    let createdAt : String
    let generosity : String?
}

/**
# Contains data for "offer.leaf"
 - title : String
 - csrfToken : Optional String that we use against csrf attacks
 - ad : Future<AdData>
 - userLoggedIn : Bool
 - isAdmin : Bool
 */

struct AdInfoContext : Encodable {
    let title : String
    let csrfToken: String?
    let ad : Future<AdData>
    let userLoggedIn : Bool
    let isAdmin : Bool
}
/**
 # Datatype to edit ad
- csrfToken : Optional String that we use against csrf attacks
- note : <String>
- adID : <UUID>
- demands : <[String]?>
- offers: <[String]?>
- city : <String>
- cityID : <UUID>
- departmentID: <UUID>
*/
struct AdInfoPostData : Content {
    let csrfToken: String?
    let note : String
    let adID : UUID
    let demands : [String]
    let offers : [String]
    let city : String
    let cityID : UUID
    let departmentID : UUID?

}



/** # Login context for the login.leaf
 - title : String
 - csrfToken : String
 - loginError : Bool which tells if there was errors
 - showCookieMessage : Bool
 - isAdmin  = false
 - serLoggedIn  = false
 */
struct LoginContext : Encodable {
    let title : String
    let csrfToken : String?
    let loginError : Bool
    let showCookieMessage : Bool
    let isAdmin = false
    let userLoggedIn = false
}

/**
 # LoginPostData / User's credentials
 - csrfToken : String?
 - username : String
 - password : String
*/
struct LoginPostData : Content {
    let csrfToken : String?
    let username : String
    let password : String
}

/**
 # Data to Add a new Country
 - country : name of the country
 - csrfToken : String ?
 */
struct CountryPostData : Content {
    let country : String
    let csrfToken : String?
}

/**
 # CSRFToken Context for addCountry.leaf
 - title : Title of the page
 - csrfToken : token to protect against CSRF attacks
 - isAdmin : Bool
 - userLoggedIn : Bool
 */
struct CSRFTokenContext : Encodable {
    let title : String
    let csrfToken : String?
    let isAdmin : Bool
    let userLoggedIn : Bool
}


/**
 # Data to create a new Department
 - departmentName : name of the department
 - departmentNumber : Number of the department
 - countryID : Country of the Deparment
 - csrfToken : A token to protect against CSRF attacks
*/
struct DepartmentPostData : Content {
    let departmentName : String
    let departmentNumber : Int
    let countryID : UUID
    let csrfToken : String?
}

/**
 # Data type which contains data to create a perimeter
 - department : Selected department
 -  departments : Array of the neighbour departments
 - csrfToken : A token to protect against CSRF attacks
*/
struct CreatePerimeterPostData : Content {
    let departmentID : UUID
    let departmentIDs : [UUID]
    let csrfToken : String?
}

/**
 # AddDepartmentContext for addDepartment.leaf
 - countries : Future<[Country]>
 - title : Title of the page
 - csrfToken : token to protect against CSRF attacks
 - isAdmin = true
 - userLoggedIn = true
 */
struct AddDepartmentContext : Encodable {
    let countries : EventLoopFuture<[Country]>
    let title : String
    let csrfToken : String?
    let isAdmin = true
    let userLoggedIn = true
}

/**
 # DepartmentContext for perimeter.leaf and createAd.leaf
 - title
 - departments : Array of Future Departments
 - csrfToken : Optional string
 - message : Optional Sting
 - userLoggedIn : Bool = true
 - isAdmin : Bool
 */
struct DepartmentsContext : Encodable {
    let title : String
    let departments : EventLoopFuture<[Department]>
    let csrfToken : String?
    let message : String?
    let userLoggedIn = true
    let isAdmin : Bool
}

/**
 # ImageContect : Contains data for addImage -view.
 - title : String
 - adID <UUID> : id of the selected ad.
 - csrfToken : Optional token
 - message : String? (input error  message)
 - isAdmin : Bool
 - userLoggedIn = true
*/
struct ImageContext : Encodable {
    let title : String
    let adID : UUID
    let csrfToken : String?
    let message : String?
    let isAdmin : Bool
    let userLoggedIn = true
}

/**
 # ImagePostData from the view.
 - image : Data
 - csrfToken : Optional token to protect against csrf -attacks.
 */
struct ImagePostData : Content {
    let image : Data
    let csrfToken : String?
}

/**
 # ImageData is a new data type which contains image data.
 - image : Data
 - adID : Optional UUID
 */
struct ImageData : Content {
    let image : Data
    let adID : UUID?
}

/**
 # Data type contains data for editImages.leaf -view.
 - title <String> : Title of the page
 - imagesData :  <[ImageLink]?>
 - adID <UUID> : id of the selected ad.
 - csrfToken : Optional token
 - isAdmin : Bool
 - userLoggedIn = true
 - message : String? (input error  message)
 */
struct EditImagesContext : Encodable {
    let title : String
    let imagesData : [ImageLink]?
    let adID : UUID
    let csrfToken : String?
    let isAdmin : Bool
    let userLoggedIn = true
    let message : String?
}

/**
# Data type contains data for image.leaf -view.
 - title <String> : Title of the page
 - imagesLinks Array<String> : Array of the Strings
 - adID <UUID> : id of the selected ad.
 - isAdmin: Bool
 - userLoggedIn : Bool
 */
struct ImageLinksContext : Encodable {
    let title : String
    let imagesData : [ImageLink]?
    let adID : UUID
    let isAdmin: Bool
    let userLoggedIn : Bool

}

/**
 # Image link
 - imageLink : A Link to display an image
 - imageName : A name of the image
 */
struct ImageLink : Content {
    let imageLink : String
    let imageName : String
    
}


/**
 # This data type contains data for one ad
 - adID : ID of the ad (UUID)
 - note : Note of the ad (String)
 - images : Array of imame file names of the ad ([String])
 - demands : Arrya of demand objects of the ad
 - offers : Array of offer objects of the ad
 - city : City (parent) of the ad
 - hearts : Amount of the heart children of the ad
 - createdAt : Optional date when the ad was created
 */
struct AdOfUser : Content {
    let adID : UUID
    let note : String
    let images : [String]?
    let demands : [Demand]
    let offers : [Offer]
    let city : City
    let hearts : Int
    let createdAt : String
}



/** # This data type contains data for index.leaf view (User's ads)
 - title : a title of the page : String
 - data : The Ad of user
 - user : Public user data
 - contactRequests : Future Array of contact request data
 */
struct AdWithUserDataContext : Encodable {
    let csrfToken : String?
    let title : String
    let data : Future<AdOfUser>?
    let user : Future<User.Public>
    let contactRequests : Future<[ContactRequestFromData]>?
    let contacts : Future<[ContactInfoData]>?
    let isAdmin : Bool
    let userLoggedIn = true
   

}



/**
 # This data type contains data for index.leaf view (User's ads)
 - csrfToken : Optional String that we use against csrf attacks
 - title : a title of the page : String
 - data : Future <AdDataContent>
 - departments : Future <Department>
 - message : String?
 - isAdmin : Bool
 - userLoggedIn = true
 */
struct EditAdDataContext : Encodable {
    let csrfToken : String?
    let title : String
    let data : Future<AdDataContent>
    let departments : Future<[Department]>
    let message : String?
    let isAdmin : Bool
    let userLoggedIn = true
}

/**
 # AdDataContent
 - adID : UUID
 - note : String
 -  images : [String]?
 - demands : <[Demand]>
 - offers : <[Offer]>
 - city : <City>
 */
struct AdDataContent : Content {
    let adID : UUID
    let note : String
    let images : [String]?
    let demands : [Demand]
    let offers : [Offer]
    let city : City
    let createdAt : String
}

/**
 # Contains a content for deleting an image
 - csrfToken : Optional String that we use against csrf attacks
 - imageName : String
 */
struct DeleteImageData : Content {
    let csrfToken : String?
    let imageName : String
}

/**
# CreateAdUserData : Data type to create new data
 - csrfToken : Optional String that we use against csrf attacks
 - note : String
 - demands : <[String]?>
 - offers: <[String]?>
 - city : <String>
 - departmentID: <UUID>
*/
struct CreateAdUserData : Content {
    let csrfToken : String?
    let note : String
    let demands : [String]?
    let offers : [String]?
    let city : String
    let departmentID : UUID?
    
}


/**
 # ContactContext for contact.leaf
 - title : String
 - csrfToken : Optional String that we use against csrf attacks
 - contactData: Future<ContactData>
 - adID : UUID
 - isAdmin : Bool (the client)
 - userLoggedIn : True
 */
struct ContactContext : Encodable {
    let title : String
    let csrfToken : String?
    let contactData : Future<ContactData>
    let adID : UUID
    let isAdmin : Bool
    let userLoggedIn = true

}

/**
 # ContactData : Data type which contains contact data
 - contactID : UUID
 - firstname : String?
 - lastname : String?
 - email : String?
 - youAccepted : Optional boolen value which  defines if the user has accepted/sent a request
 - otherAccepted: Optional boolean value which defines if other has accepted/sent a request
 */
struct ContactData : Content {
    let contactID : UUID
    let firstname : String?
    let lastname : String?
    let email : String?
    let youAccepted : Bool
    let otherAccepted : Bool
}

/**
 # ErrorContext contains data for error.leaf page
 - title = "Error"
 - isAdmin : Bool
 - userLoggedIn : Bool
 */
struct ErrorContext : Content {
    let title = "Error"
    let isAdmin : Bool
    let userLoggedIn : Bool
}

/**
 # AdminAdInfoContext : Context for adminUser.leaf page
    - title : String
    - adInfo : Future<[AdWithUser]>
    - isAdmin = true
    - userLoggedIn = true
    - csrfToken : String?
    - users : Future<[User.Public]>
 */

struct AdminAdInfoContext : Encodable {

    let title : String
    let adInfo : Future<[AdWithUser]>
    let isAdmin = true
    let userLoggedIn = true
    let csrfToken : String?
    let users : Future<[User.Public]>

}

/**
# AdWithUser : Data type
   - ad : <Ad>
   - user : <[User.Public]> :
   - demands : <[Demand]>
   - offer : <[Offer]>
   - city : <City>
   - department : <Department>
   - hearts : Int ( The count of the hearts )
*/
struct AdWithUser : Content {
    let ad : Ad
    let user : User.Public
    let demands : [Demand]
    let offers : [Offer]
    let city : City
    let department : Department
    let hearts : Int
    let createdAt: String

}

/**
# PerimeterOfDepartmentContext : Context for department.leaf page
   - title : String
   - csrfToken : String?
   - isAdmin = true
   - userLoggedIn = true
   - departmentData : Future<DepartmentWithPerimeter>
*/
struct PerimeterOfDepartmentContext : Encodable {
    let title : String
    let csrfToken : String?
    let isAdmin = true
    let userLoggedIn = true
    let departmentData : Future<DepartmentWithPerimeter>
}

/**
 # Data type which contains data to create a new ad.
- note : String
- cityID : UUID
 */
struct DataForAd : Content {
    let note : String
    let cityID : UUID
}


/** # Datatype which contains data for contact request.
    - userID : id of the user
    - name : firstname of the user
 */
struct ContactRequestFromData : Content {
    let userID : UUID
    let firstname : String
}

/** # ContacInfoData which contains data for contact request.
   - contact :  <User.Public>
   - ads : <[Ad]>
*/
struct ContactInfoData : Content {
    let contact : User.Public
    let ads : [Ad]
}

/**
 # CountryWithDepartments
 - country : <Country>
 - departments : <[Department]>
 */
struct CountryWithDepartments : Content {
    let country : Country
    let departments : [Department]
}

/**
 # DepartmentWithPerimeter
 - department : Department
 - perimeter : [Department]
 */
struct DepartmentWithPerimeter : Content {
    let department : Department
    let perimeter : [Department]
}

/** # Datatype which contains data to create demands or offers.
 - strings : Array of demand/offer names/sentences
 - adID : The id of the ad (parent of the demands/offers)
 */
struct DemandOfferData : Content {
    let strings : [String]
    let adID : UUID
}


/**
 # Contains data to update the password of the user.
- oldPassword : String
- newPassword : String
 */
    struct PasswordData : Content {
        let oldPassword : String
        let newPassword : String
}
/**
# Contains data to register user
- password : String
- firstname : String
- lastname : String
- email : Sting
 */
struct RegisterPostData : Content {
    let password : String
    let firstname : String
    let lastname : String
    let email : String
}
