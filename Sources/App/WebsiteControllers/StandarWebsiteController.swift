//
//  StandarUserController.swift
//  App
//
//  Created by Sötnos on 02/09/2019.
//

import Foundation
import Vapor

/// This controller handles routes which requires that the user has standard OR admin access.
struct StandardWebsiteController : RouteCollection {
    
    func boot(router: Router) throws {
        
        /// A group of routes which handles authentication
        let standardUserGroup = router.grouped("")
        
        /// Routes which requires users to be authenticated. If user is not authenticated, it redirects user to the "login" page.
        let standardUserRoutes = standardUserGroup.grouped(RedirectMiddleware())
        
        /*
        1. Get Request - GET THE AD OF THE USER - /self/index
        2. Get Request - GET VIEW TO CRETE A NEW AD - /self/new
        3. Post Request - POST AD - /self/new
        4. Get Request - GET VIEW TO EDIT AD - /self/edit
        5. Post Request - POST EDITED AD - /self/edit
        6. Get Request - GET VIEW TO ADD IMAGES TO AD - /self/<Ad.id>/new/image
        7. Post Request - POST IMAGE - /self/<Ad.id>/new/image
        8. Post Request - EDIT/ADD IMAGES TO AD - <id>/image
        9. Post Request - SOFT DELETE AD  - /self/image
        10. Get Request - GET VIEW TO EDIT IMAGES - <id>/edit/image
        11. Post Request - DELETE IMAGE - <id>/edit/image
        12. Get Request - RENDER THE ERROR VIEW - /error
        13. Post Request - POST TO DELETE SELECTED AD - <id>/info
        14. Get Request - GET VIEW TO EDIT IMAGES (ADD, DELETE, SHOW) - <id>/edit/image
        15. Post Request - POST REQUEST TO DELETE IMAGE - <id>/edit/image
        16. Get Request - GET REQUEST TO RENDER THE ERROR PAGE
        13. Post Request - POST REQUEST TO SEND A CONTACT REQUEST - /ads/<id>/contact
        14. Post Request - POST REQUEST TO ACCEPT THE CONTACT REQUEST - /self/<userID>/request/accept (index page)
        15. Post Request - POST REQUEST TO DECLINE THE CONTACT REQUEST - /self/<userID>/request/decline (index page)
        16. Post Request - POST REQUEST TO ACCEPT THE CONTACT REQUEST - /<userID>/<adID>/request/accept (contact page)
        17. Post Request - POST REQUEST TO DECLINE THE CONTACT REQUEST - /<userID>/<adID>/request/decline (contact page)
        18. Get Request - GET REQUEST TO GET THE CONTACT DATA - <adID>/ads/contact
        19. Post Request - POST HEART - /ads/<adID>
        */
        
        standardUserRoutes.get("self", "index", use: getAdsFromUserHandler) // 1
        standardUserRoutes.get("self", "new", use: addAdHandler) // 2
        standardUserRoutes.post(CreateAdUserData.self, at: "self", "new", use: createAdHandler) // 3
        standardUserRoutes.get("self", "edit", use: editAdHandler) // 4
        standardUserRoutes.post(AdInfoPostData.self, at: "self", "edit", use: editAdPostHandler) // 5
        standardUserRoutes.get("self", UUID.parameter, "new", "image", use: addImageHandler) // 6
        standardUserRoutes.post(ImagePostData.self, at: UUID.parameter, "image", use: addImagePostHandler) // 7
        standardUserRoutes.post(ImagePostData.self, at: UUID.parameter, "edit", "image", "post", use: addImageEditPostHandler) // 8
        standardUserRoutes.post(CsrfToken.self, at: "self", "index", use: softDeleteAdHandler) // 9
        standardUserRoutes.get(UUID.parameter, "edit", "image", use: getImageEditHandler) // 10
        standardUserRoutes.post(DeleteImageData.self, at: UUID.parameter, "edit", "image", use: deleteImageHandler) // 11
        standardUserRoutes.get("error", use: renderErrorPageHandler) // 12
        standardUserRoutes.post(CSRFTokenData.self, at: "ads", UUID.parameter, "contact", use: sendContactRequestHandler) // 13
        standardUserRoutes.post(CSRFTokenData.self, at: "self", UUID.parameter, "request", "accept", use: acceptContactRequestHandler) // 14
        standardUserRoutes.post(CSRFTokenData.self, at: "self", UUID.parameter, "request", "decline", use: declineContactRequestHandler) // 15
        standardUserRoutes.post(CSRFTokenData.self, at: UUID.parameter, UUID.parameter, "request", "accept", use: acceptContactAdRequestHandler) // 16
        standardUserRoutes.post(CSRFTokenData.self, at: UUID.parameter, UUID.parameter, "request", "decline", use: declineContactAdRequestHandler) // 17
        standardUserRoutes.get(UUID.parameter, "ads", "contact", use: getContactHandler) // 18
        standardUserRoutes.post(CSRFTokenData.self, at: "ads", UUID.parameter, use: heartPostHandler) // 19
       
       
    }

        
    // MARK: - ROUTE HANDLERS
    /**
     # The route handler which renders the error page with the title
     - Parameters:
        - req: Request
     - Throws: Error
     - Returns: Future : View
     1. Create a context data for the error page.
     2. Return and render the "error.leaf" and pass the context in.
     */
    func renderErrorPageHandler(_ req: Request) throws -> Future<View> {
        
        let errorContext = ErrorContext(isAdmin: Auth.init(req: req).isAdmin(), userLoggedIn: Auth.init(req: req).isAuthenticated())
     
        return try req.view().render("error", errorContext)
    }
    
    
    // MARK: - GET AD OF THE USER
    
    /**
     # Route handler to make an API request to get the ad of the user who is logged in (index page)
     - parameters:
        - req: Request
     - Throws: Abort  Redirect
     - Returns: Future : View
     1. Generate a csrf token and add it to the session
     2a) Make a user request to get the user data. If the resolving future resolves as an error, throw Abort and redirect the user to the error page.
     2b)  Make a contact request to get the contact requests. If the resolving future resolves as an error, throw Abort and redirect the user to the error page. If returns
     2c) Make a contact reques to get the contacts of the user. If the resolving future resolves as an error, throw Abort and redirect the user to the error page.
     3. Make an auht helper
     4. Get the Auth token; if error occurs redirect to the login page.
     5. Add token to the headers (bearer)
     6. Make a client.
     7. Make a get request with headers.
     8. Create an optional Future<AdOfUser>. This will contain the data for the ad object from the response.
     9. Look if the http response status code is equal to 401: If yes logout the user and redirect to the login page.
     10. If the http response status code is equal to 200  try to decode the content of the response. Set the data be the decoded data. Catch the errors if there are any and throw Abort and redirect the user to the error page.
     11. In other cases:
     12. Set the value of data be nil.
     13. Create a context with the data.
     14. Return and render the index.leaf with the context data.
     */
    func getAdsFromUserHandler(_ req: Request) throws -> Future<View> {

        let ctoken = CSRFToken(req: req).addToken() // 1
        
        // 2a
        let user = try UserRequest.init(ending: "self").getUserData(req).catchMap({ error in
            print(error, "user wasn't found")
            throw Abort.redirect(to: "/error")
        })
        // 2b
        let contactRequests = try ContactRequest.init(ending: "contacts/requests").getContactRequests(req)?.catchMap({ error in
            print(error)
            throw Abort.redirect(to: "/error")
        })
        
        // 2c
        let contacts = try ContactRequest.init(ending: "contacts").getContacts(req)?.catchMap({ error in
            print(error)
            throw Abort.redirect(to: "/error")
        })

        let auth = Auth(req: req) // 3
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 4
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 5
        let client = try req.make(Client.self) // 6
        
        let config = EegjAPIConfiguration()
        let eegjConfig = config.setup()
        
        // TODO : - Update
        return client.get("http://\(eegjConfig.hostname):\(eegjConfig.port)/ads/self", headers: auth.headers).flatMap(to: View.self) { res in // 7
            
            var data : Future<AdOfUser>? // 8
             // 9
            if res.http.status.code == 401 {
                auth.logout()
                throw Abort.redirect(to: "/login")
              // 10
            } else if res.http.status.code == 200 {
                // 11
                data = try res.content.decode(AdOfUser.self).catchMap{ error in
                    print(error, "Error with decoding data from the response")
                    throw Abort.redirect(to: "/error")
                }
                
                
            } else {
                 data = nil // 12
            }
            let context = AdWithUserDataContext(csrfToken: ctoken, title: "My Profile", data: data, user: user, contactRequests: contactRequests, contacts: contacts, isAdmin: auth.isAdmin()) // 13
            return try req.view().render("index", context) // 14
        }
    }
    
    
    // MARK: - CREATE NEW AD HANDLERS

    /**
     # Render a createAd.leaf to create new ad
     - Parameters:
        - req: Request
     - Throws: Abort  Redirect
     - Returns: Future : View
     
     1. Helper function generates a random token and saves it to the session.
     2. Temporary optional string what stores the message.
     3. Look up if there are a message in the http request.
     4. If yes, message is the message.
     5. Otherwise message is nil.
     6. Make a get request to get departments. If the resolving future resolves as an error, throw Abort and redirect the user to the error page.
     7. Create a context which contains date for the createAd.leaf page.
     8. Render the page using the addCity.leaf template.
     */
    func addAdHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        var message : String? // 2
        
        if let messge = req.query[String.self, at: "message"] { // 3
            message = messge // 4
        } else { message = nil } // 5
        // 6
        let departments = try DepartmentRequest.init(ending: "").getDepartmentsData(req).catchMap({ error in
            print(error)
            throw Abort.redirect(to: "/error")
        })
        
        let context = DepartmentsContext(title: "Create New Ad", departments: departments, csrfToken: token, message: message, isAdmin: Auth.init(req: req).isAdmin()) // 7
        return try req.view().render("createAd", context) // 8
        
    }
    
    /**
    # Create new ad handler
    - Parameters:
        - req: Request
        - data: CreateAdUserData
    - Throws: Abort  Redirect
    - Returns: Future : Response

    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw abort and redirect the user to the error page.
    3a. Call validate() on the decded RegisterData, checking each validator. This can throw ValidationError and in this case, redirect the user back to the register.leaf.
    3b. When validation fails, the route handler extracts the message from the ValidationError, escapes it properly for inlcusion in a URL, and adds it to the redirect URL. Then, it redirects the user back to the registration page.
    4. Make a CityRequest to the api to create a new city model. Parameters are the request, the name of the city and the department id.
    5. Flatmap the <City> to the future<Response>.
    6. Unwrap the city id.
    7. Make a AdRequest to the api to create a new ad model. Parameters are the request, a note and the city id.
    8. Unwrap the ad id.
    9. Look if the data.offers is not nil.
    10. If not: Create an array which contains all the non-empty strings.
    11. Make an offerRequest to create a new offer.
    12. Look if the data.demands is not nil.
    13. If not: Create an array which contains all the non-empty strings.
    14. Make a demandRequest to create a new demand.
    15. Return response and redirect user to the page to add a image.
    */
    func createAdHandler(_ req: Request, data: CreateAdUserData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
        
        do {  // 3a
            try data.validate()
            // 3b
        } catch (let error){
            let redirect : String
            if let error = error as? ValidationError, let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                redirect = "/self/new?message=\(message)"
            } else {
                redirect = "/self/new?message=Unknown+error"
            }
            return req.future(req.redirect(to: redirect))
        }
    
        return try CityRequest.init(ending: "").createCity(req, city: data.city, departmentID: data.departmentID!).flatMap(to: Response.self) { city in  // 4
         
            guard let id = city.id else {throw Abort.redirect(to: "/error")} // 5
            return try AdRequest.init(ending: "create").createAD(req, note: data.note, cityID: id).map(to: Response.self) { ad in // 6
                    
                guard let adID = ad.id else {throw Abort.redirect(to: "/error")} // 7

                if data.offers != nil { // 8
                       
                    let offersToCreate = data.offers!.filter { $0.count > 0} // 9
                        
                    _ = try OfferRequest.init(ending: "create").createOffer(req, offers: offersToCreate, ad: adID) // 10
                }
                if data.demands != nil { // 11
                        
                    let demandsToCreate = data.demands!.filter { $0.count > 0} // 12
                    _ = try DemandRequest.init(ending: "create").createDemand(req, demands: demandsToCreate, ad: adID) // 13
                }
                return req.redirect(to: "/self/\(adID)/new/image") // 14
            }
        }
    }
    
    
    // MARK: - EDIT AD HANDLER
    
    /**
    # Render the editAd.leaf to edit ad
    - Parameters:
        - req: Request
    - Throws: Abort  Redirect
    - Returns: Future : View

    1. Helper function generates a random token and saves it to the session.
    2. Temporary optional string what stores the message.
    3. Look up if there are a message in the http request.
    4. If yes, message is the message.
    5. Otherwise message is nil.
    6. Make an Ad request to get ad data.
    7. Make a get request to get the deparments from the api.
    8. Create a context.
    9. Render the page using the editAd.leaf template.
    */
    func editAdHandler(_ req: Request) throws -> Future<View> {
        
        let tokenC = CSRFToken(req: req).addToken() // 2

        var message : String? // 3
        
        if let messge = req.query[String.self, at: "message"] { // 4
            message = messge
        } else { message = nil } // 5
        
        let data = try AdRequest.init(ending: "/self").getAdOfUser(req) // 6
       
        let departments = try DepartmentRequest.init(ending: "").getDepartmentsData(req) // 7
           
        let context = EditAdDataContext(csrfToken: tokenC, title: "Edit Ad", data: data, departments: departments, message: message, isAdmin: Auth.init(req: req).isAdmin()) // 8
        return try req.view().render("editAd", context) // 9
           
    }
    
    
    /**
     # Route handler post edited ad
     - Parameters:
        - req: Request
        - data: AdInfoPostData
     - Throws: Abort  Redirect
     - Returns: Future : Response
     
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw abort and redirect the user to the "error.leaf" page.
     3a. Call validate() on the decoded data, checking each validator. This can throw ValidationError and in this case, redirect the user back to the register.leaf.
     3b. When validation fails, the route handler extracts the message from the ValidationError, escapes it properly for inlcusion in a URL, and adds it to the redirect URL. Then, it redirects the user back to the same page.
     4. Make an  Ad request to send the edited to the API.
     */
        func editAdPostHandler(_ req: Request, data: AdInfoPostData) throws -> Future<Response> {
   
            let expectedToken = CSRFToken(req: req).getToken() // 1
            _ = CSRFToken(req: req).destroyToken // 2
            guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3

            do {  // 3a
                try data.validate()
                // 3b
            } catch (let error){
                let redirect : String
                if let error = error as? ValidationError, let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    redirect = "/self/edit?message=\(message)"
                } else {
                    redirect = "/self/edit?message=Unknown+error"
                }
                return req.future(req.redirect(to: redirect))
            }
            return try AdRequest.init(ending: "\(data.adID)/update").sendEditedAd(req, data: data) // 4
        }
    
    
  
    // MARK: - IMAGE HANDLERS : ADD IMAGES
    
    /**
     # Render the addImage.leaf view to add imaged to the ad
     - Parameters:
        - req: Request
     - Throws: Abort  Redirect
     - Returns: Future : View
     
     1. Helper function generates a random token and saves it to the session.
     2. Temporary optional string what stores the message.
     3. Look up if there are a message in the http request.
     4. If yes, message is the message.
     5. Otherwise message is nil.
     6.  Extract the adID from the request's parameters.
     7. Create a context.
     8. Render the page using the editAd.leaf template.
     */
    func addImageHandler(_ req: Request) throws -> Future<View> {
        let token = CSRFToken(req: req).addToken() // 1
        
        var message : String? // 2
        
        if let messge = req.query[String.self, at: "message"] { // 3
            message = messge // 4
        } else { message = nil } // 5
        
        let adID = try req.parameters.next(UUID.self) // 6
        
        let context = ImageContext(title: "Add Images", adID: adID, csrfToken: token, message: message, isAdmin: Auth.init(req: req).isAdmin()) // 7
        return try req.view().render("addImage", context) // 8
    }
 
    /**
    # Route handler to post image to the ad
     - Parameters:
        - req: Request
        - data: ImagePostData
     - Throws: Abort  Redirect
     - Returns: Future : Response
     
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw abort and redirect to the error.leaf.
     4. Get ad id by extracting the UUID from the request's parameter.
     4a. Call validate() on the decded RegisterData, checking each validator. This can throw ValidationError and in this case, redirect the user back to the register.leaf.
     4b. When validation fails, the route handler extracts the message from the ValidationError, escapes it properly for inlcusion in a URL, and adds it to the redirect URL. Then, it redirects the user back to the same page.
     5. Make a ImageRequest to post the image data and return the response.
     */
    func addImagePostHandler(_ req: Request, data: ImagePostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
        let id = try req.parameters.next(UUID.self) // 4
        
        do {  // 4a
            try data.validate()
            // 4b
        } catch (let error){
            let redirect : String
            if let error = error as? ValidationError, let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                redirect = "/self/\(id)/new/image?message=\(message)"
            } else {
                redirect = "/self/\(id)/new/image?message=Unknown+error"
            }
            return req.future(req.redirect(to: redirect))
        }
        return try ImageRequest.init(ending: "image").postImageData(req, to: id, data: data.image) // 5
       
    }
    
    // MARK: - IMAGE HANDLERS : EDIT IMAGES
      
     /**
     # Route Handler to render editImages.leaf to delete/ad images
     - Parameters:
        - req: Request
     - Throws: Abort  Redirect
     - Returns: Future : View
    
     1. Temporary optional string what stores the message.
     2. Look up if there are a message in the http request.
     3. If yes, message is the message.
     4. Otherwise message is nil.
     5. Extract the ad id from the request's parameter.
     6. Make a Image request and flatMap the response to future<View>
     7. If the status code is 500:
     8. Create a context where imagesData is nil.
     9. Return and render the view.
     10. If the status code is not 500.
     11. Decode a content of the response to [ImageLink] and flatMap the future to Future<View>.
     12. Create a context with the decoded data.
     13. Return and render the view.
     14. If the resolving future resolves as an error, throw abort and redirect the user to the error page.
     */
    func getImageEditHandler(_ req: Request) throws -> Future<View> {
          
        let token = CSRFToken(req: req).addToken() // 1
    
        var message : String? // 2
             
        if let messge = req.query[String.self, at: "message"] { // 3
            message = messge // 4
        }
        
        let adID = try req.parameters.next(UUID.self) // 5
        return try ImageRequest.init(ending: "\(adID)/images").getImages(req).flatMap(to: View.self) { res in // 6

              if res.http.status.code == 500 { // 7
                  let context = EditImagesContext(title: "Images", imagesData: nil, adID: adID, csrfToken: token, isAdmin: Auth.init(req: req).isAdmin(), message: message) // 8
                  return try req.view().render("editImages", context) // 9
              } else { // 10
                  return try res.content.decode([ImageLink].self).flatMap(to: View.self) { data in // 11
                      let context = EditImagesContext(title: "Images", imagesData: data, adID: adID, csrfToken: token, isAdmin: Auth.init(req: req).isAdmin(), message: message) //12
                      return try req.view().render("editImages", context) // 13
                  }
              }// 14
        }.catchFlatMap({ error in
            print(error)
            throw Abort.redirect(to: "/error")
        })
    }
    
    /**
    # Route handler to post edited ads
    - Parameters:
       - req: Request
       - data: ImagePostData
    - Throws: Abort  Redirect
    - Returns: Future : Response
   
    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw abort and redirect to the error page.
    4. Get ad id by extracting the UUID from the request's parameter.
    4a. Call validate() on the decded RegisterData, checking each validator. This can throw ValidationError and in this case, redirect the user back to the register.leaf.
    4b. When validation fails, the route handler extracts the message from the ValidationError, escapes it properly for inlcusion in a URL, and adds it to the redirect URL. Then, it redirects the user back to the same page.
    5. Make a ImageRequest to post the image data and return the response.
    */
    func addImageEditPostHandler(_ req: Request, data: ImagePostData) throws -> Future<Response> {
       
       let expectedToken = CSRFToken(req: req).getToken() // 1
       _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
       let id = try req.parameters.next(UUID.self) // 4
       
       do {  // 4a
           try data.validate()
           // 4b
       } catch (let error){
           let redirect : String
           if let error = error as? ValidationError, let message = error.reason.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
               redirect = "/\(id)/edit/image?message=\(message)"
           } else {
               redirect = "/\(id)/edit/image?message=Unknown+error"
           }
           return req.future(req.redirect(to: redirect))
       }
       return try ImageRequest.init(ending: "image").postImageData(req, to: id, data: data.image) // 5
   }
   
    
    // MARK: - DELETE HANDLERS
    
    /**
     # Route handler to soft delete the selected ad
     - Parameters:
        - req: Request
        - data: CsrfToken
     - Throws: Abort  Redirect
     - Returns: Future : Response
     
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
     4. Try to make an Ad request to delete the ad and return the response.
    */
    func softDeleteAdHandler(_ req: Request, data: CsrfToken) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3
        return try AdRequest.init(ending: "delete/\(data.adID)").softDelete(req) // 4
        
    }

    /**
    # Handler to make a delete request to delete image
    - Parameters:
        - req: Request
        - data: DeleteImageData
    - Throws: Abort  Redirect
    - Returns: Future : Response
        
    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    4. Extract the ad id from the request's parameters.
    5. Try to make an Image request to delete the ad and return the response.
    */
    func deleteImageHandler(_ req: Request, data: DeleteImageData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
        
        let adID = try req.parameters.next(UUID.self) // 4
        
        return try ImageRequest.init(ending: "\(adID)/images/delete/\(data.imageName)").deleteImageRequest(req, adID: adID) // 5
    }
    
    
    // MARK: - CONTACT HANDLERS
    
    /**
     # Handler to make a contact request
     - Parameters:
        - req : Request
        - data : CSRFTokenData
     - Returns: Future Response
     - Throws: AbortError
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
     4. Extract the ad id from the request's parameters.
     4. Return  a ContactRequest to send contact request.
     */
    func sendContactRequestHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
               
        let adID = try req.parameters.next(UUID.self) // 4
        return try ContactRequest.init(ending: "\(adID)/request/send").sendContactRequest(req, adID: adID) // 5
    }
    
    
    /**
     # Accept Contact Request (index.leaf)
      - Parameters:
        - req : Request
        - data : CSRFTokenData
     - Returns: Future Response
     - Throws: AbortError
     
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
     4. Extract the user id from the request's parameters.
     5. Extract the ad id from the request's parameters.
     6. Make a ContactRequest to accept the request.  Map to the Future Response.
     */
    func acceptContactRequestHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
           
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
        
        let userID = try req.parameters.next(UUID.self) // 4
    
        return try ContactRequest.init(ending: "\(userID)/contacts/requests/accept").acceptContactRequest(req, to: "/self/index") // 5
    }

    /**
    # Accept Contact Request (contact.leaf)
    - Parameters:
        - req : Request
        - data : CSRFTokenData
    - Returns: Future Response
    - Throws: AbortError

    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    4. Extract the user id from the request's parameters.
    5. Extract the ad id from the request's parameters.
    6. Make a ContactRequest to accept the request.  Map to the Future Response.
    */
    func acceptContactAdRequestHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
             
        let expectedToken = CSRFToken(req: req).getToken() // 1
          _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
          
        let userID = try req.parameters.next(UUID.self) // 4
        let adID = try req.parameters.next(UUID.self) // 5
      
        return try ContactRequest.init(ending: "\(userID)/contacts/requests/accept").acceptContactRequest(req, to: "/\(adID)/ads/contact") // 6
      }
    
    /**
    # Decline Contact Request (index)
    - Parameters:
        - req : Request
        - data : CSRFTokenData
    - Returns: Future Response
    - Throws: AbortError

    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    4. Extract the user id from the request's parameters.
    5. Extract the ad id from the request's parameters.
    6. Make a ContactRequest to decline  the request.
    */
   func declineContactRequestHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
       
       let expectedToken = CSRFToken(req: req).getToken() // 1
       _ = CSRFToken(req: req).destroyToken // 2
       guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
              
       let userID = try req.parameters.next(UUID.self) // 4
          
        return try ContactRequest.init(ending: "\(userID)/contacts/requests/decline").declineContactRequest(req, to: "/self/index") // 5
           
   }
   
    /**
    # Decline Contact Request (contact page)
    - Parameters:
        - req : Request
        - data : CSRFTokenData
    - Returns: Future Response
    - Throws: AbortError

    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    4. Extract the user id from the request's parameters.
    5. Extract the ad id from the request's parameters.
    6. Make a ContactRequest to decline the request.
    */
      
    func declineContactAdRequestHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
          
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
                 
        let userID = try req.parameters.next(UUID.self) // 4
        let adID = try req.parameters.next(UUID.self) // 5
             
        return try ContactRequest.init(ending: "\(userID)/contacts/requests/decline").declineContactRequest(req, to: "/\(adID)/ads/contact") // 6
    }
          
    
    /**
     # Get the contact of the ad
     - Parameters:
        - req: Request
     - Returns: Future View
     - Throws: AbortError
     
     1. Generate and add a token to the request's session.
     2. Get the ad id from the parameter's request.
     3. Make a contact request to fetch the contact data.
     4.  Create a context with the data.
     5. Return and render the contact view.
     */
    func getContactHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
       
        let adID = try req.parameters.next(UUID.self) // 2
    
        let data = try ContactRequest.init(ending: "\(adID)/contacts").getContactOfAd(req) // 3
            
        let context = ContactContext(title: "Contact", csrfToken: token, contactData: data, adID: adID, isAdmin: Auth.init(req: req).isAdmin()) // 4
            
        return try req.view().render("contact", context) // 5
        
    }
    
    // MARK: - HEART HANDLERS
    
    /**
    # Route handler to like / unlike ads
    - Parameters:
        - req: Request
        - data: CSRFTokenData
    - Returns: Future Response
    - Throws: AbortError
     
    1. Generate and add a token to the request's session.
    2. Get the ad id from the parameter's request.
    3. Make a contact request to fetch the contact data.
    4.  Extract the ad id from the request's parameter.
    5. Make ad request to like/unlike ad.
    */
        
    func heartPostHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3
        let adID = try req.parameters.next(UUID.self) // 4
            
        return try AdRequest.init(ending: "\(adID)/like").likeAd(req, to: "\(adID)") // 5
    }
}
