//
//  WebsiteController.swift
//  App
//
//  Created by Sötnos on 06/07/2019.
//

import Foundation
import Vapor
import Leaf

/*
 Controller which handles API calls and rendering pages. This Controller conforms RouteCollection
 1. Implement boot(router:) as required by RouteCollection.
 */

struct WebsiteController : RouteCollection {
    
    // 1
    func boot(router: Router) throws {
        
        
        let websiteRoutes = router.grouped("")
        /*
         Public Routes
         1. Get Request - GET SINGLE AD
         2. Get Request - GET ALL THE COUNTRIES
         3. Get Request - GET ADS OF THE PERIMETER OF THE SELECTED DEPARTMENT
         4. Get Request - GET IMAGE LINKS OF THE AD
         */
        websiteRoutes.get("ads", UUID.parameter, use: getAdHandler) // 1
        websiteRoutes.get(use: countryHandler) // 2
        websiteRoutes.get("ads", use: adsOfPerimeterHandler) // 3
        websiteRoutes.get("ads", "images", UUID.parameter, use: getImagesHandler) // 4
      
     
    }

     // MARK: - landing.leaf
    
    /**
     # Function to make an API request to get all the countries with departments and render the landing view.
     - Parameters:
        - req: Request
     - Throws: Abort Redirect (error.leaf)
     - Returns: Future : View
     
     1. Function return Future<View>
     2. Make country request to fetch the data (Future<[CountryWithDepartment]>).
     3.  Look if the cookies are accepted by the user.
     4. Populate a  context which the fetched data (arrayOfCountries and the title) for the landing.leaf page. Pass the usertype and the boolean value which tells the view if the user is logged in.
     5. Return and render the view and pass the context in.
     */
    
    func countryHandler(_ req: Request) throws -> Future<View> { // 1
        
        let data = try CountryRequest.init(ending: "departments").getCountriesWithDepartments(req) // 2
    
        let showCookieMessage = req.http.cookies["cookies-accepted"] == nil // 3
        let context = CountryContext(countries: data, title: "Home", userLoggedIn: Auth.init(req: req).isAuthenticated(), isAdmin: Auth.init(req: req).isAdmin(), csrfToken: nil, showCookieMessage: showCookieMessage) // 4
        return try req.view().render("landing", context) // 5
    }
    
    
    // MARK: - adList.leaf
    
    /**
     # Function to make an API request to get all the ads of the selected department and ads of the sibling department. Returns the adList.leaf.
     - Parameters:
        - req: Request
     - Throws: Abort Redirect
     - Returns: Future<View>
     
     1. Decode request's query filters to DepartmentFilters.
     2. Create a variable which contains a name of the department and a constant which contains a boolean value which determines whether to show demands or offers (default value is true)
     3. If the departmentString is an empty string or a nil.
     4.. Then set the value of the departmentString to be the department from the session.
     5. If the value is still or an empty string throw abort and redirect the user to the landing page to select the department.
     6. If the query string is not nil, save the preference (department selection) to the session.
     7. Make an Ad Reques to fetch the data Future<AdsOfPerimeterData>.
     8. Variable which contains a title name of the page.
     9. If the show is true, title is "Offres".
     10. Otherwise the title is "Demandes".
     11. Populate the context.
     12. Return and render the view and pass the data in.
     */
  
    func adsOfPerimeterHandler(_ req: Request) throws -> Future<View> {
        
        
        let filters = try req.query.decode(DepartmentFilters.self) // 1
        // 2
        var departmentString = filters.department
        let show = filters.offers ?? true
        
        if departmentString == "" || departmentString == nil {// 3
            departmentString = UserPreference.init(req: req).departmentID // 4
            guard departmentString != nil || departmentString == "" else {throw Abort.redirect(to: "/")} // 5
        } else { // 6
            UserPreference.init(req: req).departmentID = departmentString
        }
    
        let data = try AdRequest.init(ending: "all/\(departmentString!)").getAll(req) // 7
        var title : String // 8
             
        // 9
        if show == true {
            title = "Offres"
        } else { // 10
            title = "Demandes"
        }
                
        let context = AdContext(title: title, data: data, showOffer: show, isAdmin: Auth.isAdmin(.init(req: req))(), userLoggedIn: Auth.isAuthenticated(.init(req: req))()) // 11
        return try req.view().render("adList", context) // 12
                    
        
    }
    
    // MARK: - offer.leaf
    
    /**
     # Function to make an API request to get a single ad. Returns the offer view.
     - Parameters:
        - req: Request
     - Throws: Abort Redirect
     - Returns: Future<View>
     
     1. Generate csrfToken and save it to the session.
     2.  Extract the ad id from the request's parameters.
     3. Make an Ad request to fetch the ad.
     4. Populate a context.
     5. Return and render the view and pass the context in.
     */
    
    func getAdHandler(_ req: Request) throws -> Future<View> {
        
        let ctoken = CSRFToken(req: req).addToken() // 1
        let id = try req.parameters.next(UUID.self) // 2
        let ad = try AdRequest.init(ending: "\(id)").getAd(req) // 2
      
        let context = AdInfoContext(title: "Ad", csrfToken: ctoken, ad: ad, userLoggedIn: Auth.isAuthenticated(.init(req: req))(), isAdmin: Auth.isAdmin(.init(req: req))()) // 4
        return try req.view().render("offer", context) // 5
                
         
    }

    // MARK: - images.leaf
    
    /**
     # Route handler to return the image view:
     - Parameters:
            - req: Request
     - Throws: Abort Redirect
     - Returns: Future<View>
     
     1. Handler takes a request and returns a Future<View>.
     2. Extract the id of the request's parameter.
     3. Make an image request to fetch the data.
     4. If the http code of the response is 200:  In the completion handler decode a content of the response to an array of ImageData.
     5. Create a context and pass in the context, adID and the array of ImageData. Token is nil.
     6. Return and render the images -leaf with the context.
     7.  If the resolving future resolves as an error, throw abort and redirect to the error.leaf page.
     8.  If the status code is something else than 200, throw abort and redirect to the error.leaf page.
    */
    func getImagesHandler(_ req: Request) throws -> Future<View> { // 1
        
        let adID = try req.parameters.next(UUID.self) // 2
    
        return try ImageRequest.init(ending: "\(adID)/images").getImages(req).flatMap(to: View.self) { res in // 3
            // 4
            if res.http.status.code == 200 {
                
                return try res.content.decode([ImageLink]?.self).flatMap(to: View.self) { links in
                    
                    let context = ImageLinksContext(title: "Images", imagesData: links, adID: adID, isAdmin: Auth.isAdmin(.init(req: req))(), userLoggedIn: Auth.isAuthenticated(.init(req: req))()) // 5
                    return try req.view().render("images", context) // 6
                    // 7
                }.catchMap({ error in
                    print(error)
                    throw Abort.redirect(to: "/error")
                })
            } else { // 8
                throw Abort.redirect(to: "/error")
            }
        }
    }
}

// MARK: - Data types for query filters

/**
 # DepartmentFilters
 - country <String?> : selected country
 - department <String?> : selected department (id)
 - offers <Bool?> : Boolean value which determines whether to show offers or demands
 */

struct DepartmentFilters: Content {
    var country: String?
    var department: String?
    var offers: Bool?
}
