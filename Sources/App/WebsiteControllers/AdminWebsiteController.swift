//
//  AdminUserController.swift
//  App
//
//  Created by Sötnos on 31/07/2019.
//

import Foundation
import Vapor
import Leaf

/// AdminViewController handles routes which requires the Admin Access
struct AdminWebsiteController : RouteCollection {

    // Routes
    func boot(router: Router) throws {
    
        /// A group of routes which handles authentication
        let userRoutes = router.grouped("")
        
        /// Routes which requires users to be authenticated. If user is not authenticated, it redirects user to the "login" page.
        let protectedRoutes = userRoutes.grouped(RedirectMiddleware())
        
        // This creates a new route group, extending from authSessionRoutes that includes RedirectMiddleware. The application runs a request through RedirectMiddleware before it reaches the route handler, but after AuthenticationSessionMiddleware. This allows RedirectMiddleware to chech for an authenticated user. RedirectMiddleware requires you to specify the path for redirecting unauthenticated users and the Authenticatabke type to check for. In this case, that's your User model.
        //
        //    2. Get Request - GET VIEW TO CREATE CITIES
        //    3. Post Request - POST CITY
        //    4. Get Request - GET VIEW TO CREATE CONTACTINFO
        //    5. Post Request - POST CONTACT
        //    6. Get Request - GET VIEW TO CREATE AD
        //    7. Post Request - POST AD
        //    8. Get Request - GET VIEW TO GET ALL COUNTRIES
        //    9. Get Request - GET VIEW TO CREATE COUNTRY
        //    10. Post Request - POST COUNTRY
        //    11. Get Request - GET VIEW TO CREATE DEPARTMENTS
        //    12. Post Request - POST DEPARTMENT
        //    13. Get Request - GET VIEW TO ADD IMAGES TO THE AD
        //    14. Post Request - POST IMAGES TO THE AD
        //    15. Get Request - GET AD WITH IT'S DATA
        //    16. Get Request - GET EDIT AD VIEW
        //    17. Post Request - POST THE EDITED AD
        //    18. Get Request - GET VIEW TO CREATE PERIMETER
        //    19. Post Request - POST THE PERIMETER DATA
        //    20. Post Request - POST TO DELETE SELECTED AD
        //    21. Get Request - GET VIEW TO EDIT IMAGES (ADD, DELETE, SHOW)


     
    
        protectedRoutes.get("add", "city", use: addCityHandler) // 2
        protectedRoutes.post(AddCityData.self, at: "add", "city", use: addCityPostHandler) // 3
        protectedRoutes.get("add", "city", UUID.parameter, "contact", use: addContactHandler) // 4
        protectedRoutes.post(AddContactData.self, at: "add", "city", UUID.parameter, "contact", use: addContactPostHandler) // 5
        protectedRoutes.get("add", "city", UUID.parameter, "contact", UUID.parameter, use: addAdHandler) // 6
        protectedRoutes.post(AdPostData.self, at: "add", "city", UUID.parameter, "contact", UUID.parameter, use: addAdPostHandler) // 7
        protectedRoutes.get("countries", "all", use: countriesHandler) // 8
        protectedRoutes.get("add", "country", use: addCountryHandler) // 9
        protectedRoutes.post(CountryPostData.self, at: "add", "country", use: addCountryPostHandler) // 10
        protectedRoutes.get("add", "department", use: addDepartmentHandler) // 11
        protectedRoutes.post(DepartmentPostData.self, at: "add", "department", use: addDepartmentPostHandler) // 12
        protectedRoutes.get(UUID.parameter, "image", use: addImageHandler) // 13
        protectedRoutes.post(ImagePostData.self, at: UUID.parameter, "image", use: addImagePostHandler) // 14
        protectedRoutes.get(UUID.parameter, "info" , use: getFullAdHandler) // 15
        protectedRoutes.get(UUID.parameter, "edit", use: editAdHandler) // 16
        protectedRoutes.post(AdInfoPostData.self, at: UUID.parameter, "edit", use: editAdPostHandler) // 17
        protectedRoutes.get("departments", "perimeter", use: createPerimeterHandler) // 18
        protectedRoutes.post(CreatePerimeterPostData.self, at: "departments", "perimeter", use: createPostPerimeterHandler) // 19
        protectedRoutes.post(CsrfToken.self, at: UUID.parameter, "info", use: softDeleteAdHandler) // 20
        protectedRoutes.get(UUID.parameter, "edit", "image", use: getImageEditHandler) // 21
        protectedRoutes.post(DeleteImageData.self, at: UUID.parameter, "edit", "image", use: deleteImageHandler)
 
    }
    /// CountryHandler for getting all the countries
    /// 1. Make a client.
    /// 2. Make a get request and map a response to Future<View>.
    /// 3. Decode the content of the response to an array of countries
    /// 4. Create a context.
    /// 5. Render the view with context.
//    func countriesHandler(_ req: Request) throws -> Future<View> {
//
//        let client = try req.make(Client.self) // 1
//        return client.get("http://localhost:9090/api/countries").flatMap(to: View.self) { res in // 2
//            let countries = try res.content.decode([Country].self) // 3
//            let context = CountriesContext(countries: countr÷ ies, title: "Countries") // 4
//            return try req.view().render("countries", context) // 5
//
//        }
//
//    }
//
    // MARK: - GET DATA HANDLERS
    
    /// DepartmentsHandler for getting all the departments
    /// 1. Function return Future<View>
    /// 2. Creates a generic Client which Connects to remote HTTP servers and sends HTTP requests receiving HTTP responses.
    /// 3. Sends an HTTP GET Request to a server and returns a view
    /// 4. Return and Decode JSON response to the array of future countries. This is possible because Country conforms Encodable. FlatMap future to View.self.
    /// 5. Create an empty array of CountryData objects.
    /// 6. Loop countries.
    /// 7. Get departments of the country by calling getDepartments -method.
    /// 8. Create data object and pass the fetched data in.
    /// 9. Add the new object to the arrayOfCountries.
    /// 10. Create a response context which contains data (arrayOfCountries and the title) for the landing.leaf page.
    /// 11. Return and render the view and pass the context in.
    
    func countriesHandler(_ req: Request) throws -> Future<View> { // 1
        
        let client = try req.make(Client.self) // 2
        return client.get("http://localhost:9090/api/countries/").flatMap(to: View.self) { res in // 3
            return try res.content.decode([Country].self).flatMap(to: View.self) { countries in // 4
                
                var arrayOfCountries = [CountryData]() // 5
                for country in countries { // 6
                    
                    let departments = try country.getDepartments(country: country, on: req) // 7
                    let data = CountryData(country: country, departments: departments) // 8
                    arrayOfCountries.append(data) // 9
                }
                let context = CountryContext(countries: arrayOfCountries, title: "Countries and Departments") // 10
                return try req.view().render("countries", context) // 11
            }
        }
    }

    
    
    /// Route handler renders a view with the ad data of the selected ad.
    /// 1a) Add a csrfToken.
    /// 1. Extract the UUID from the request's parameter.
    /// 2. Make a client.
    /// 3. Make a get request.
    /// 4. In the completion handler decode the content of the response to AdInfoData and map the result to Future<View>.
    /// 5. Make a get reques to get contact data of the ad.
    /// 6. In the completion handler decode the content of the response to Contact and flatMap the result to Future<View>.
    /// 7. Create a context with the fetched data.
    /// 8. Return and render the view with context.
    func getFullAdHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1a
        let id = try req.parameters.next(UUID.self) // 1
        let client = try req.make(Client.self) // 2
        
        return client.get("http://localhost:9090/api/ads/\(id)/").flatMap(to: View.self) { res in // 3
            return try res.content.decode(AdInfoData.self).flatMap(to: View.self) { data in // 4
                
                return client.get("http://localhost:9090/api/ads/\(id)/contact").flatMap(to: View.self) { resp in // 5
                    let contact = try resp.content.decode(Contact.self) // 6
                    let context = FullAdContext(title: "Ad info", adInfo: data, contact: contact, csrfToken: token, cities: nil) // 7
                    return try req.view().render("adInfo", context) // 8
                }
            }
        }
    }
    
    
    // MARK: - CREATE NEW CITY HANDLERS
    
    
     /// Create City Handler
     /// GET Handler to Get the page to create New Cities
     /// 1. Helper function generates a random token and saves it to the session and returns the token.
     /// 2. Make a client.
     /// 3. Make a get request to get departments. Map the result to Future<View>.
     /// 4. Decode the content.
     /// 5. Create a context.
     /// 6. Render the page using the addCity.leaf template.
    
    func addCityHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        let client = try req.make(Client.self) // 2
        
        return client.get("http://localhost:9090/api/departments").flatMap(to: View.self) { res in // 3
            
            let departments = try res.content.decode([Department].self) // 4
            let context = DepartmentsContext(title: "Add City", departments: departments, csrfToken: token) // 5
            return try req.view().render("addCity", context) // 6
        }
    }
    
    
    /// Add City Post -Handler posts data to create a new city
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Create an Authentication helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer)
    /// 7. Make a client.
    /// 8. Make a post request with the headers to the API. Before sending execute the completion handler.
    /// 9. Create a City object from the data.
    /// 10. Encode the content.
    /// 11. FlatMap the response to Future<Response>.
    // TODO: - Create a function / enum which checks the status code / case.
    /// 12. If the responses's status code equals to 401.
    /// 13. Destroy the session.
    /// 14. Redirect user to the "login" page.
    /// 15. If status code is not 401, decode a content of the response to City and map the result of the completion handler to Future<Response>.
    /// 16. Unwrap the id of the city.
    /// 17. Redirect the user to the next page which is \(city.id)/contact.
    
    func addCityPostHandler(_ req: Request, data: AddCityData) throws -> Future<Response> {

        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort(.badRequest)} // 3
    
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        
        let client = try req.make(Client.self) // 7
        
        return client.post("http://localhost:9090/api/cities", headers: auth.headers, beforeSend: { req in // 8
            let data = City(city: data.city, departmentID: data.departmentID) // 9
            try req.content.encode(data, as: .json) // 10
            
        }).flatMap(to: Response.self) { res in // 11
            
            if res.http.status.code == 401 { // 12
                auth.logout() // 13
                throw Abort.redirect(to: "/login") // 14
            }
            
            return try res.content.decode(City.self).map(to: Response.self) { city in // 15
                guard let id = city.id else {throw Abort.redirect(to: "/index")} // 16
                return req.redirect(to: "/add/city/\(id)/contact") // 17
            }
        }
    }

     // MARK: - CREATE NEW CONTACT HANDLERS
    
    /// Add Contact handler returns a Future<View> to add a contact
    /// 1. Helper function generates a random token and saves it to the session and returns the token.
    /// 2. Create a context and pass the token and title in.
    /// 3. Render "addContact.leaf" and pass the context in.
    func addContactHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        let context = CSRFTokenContext(title: "Add Contact", csrfToken: token) // 5
        return try req.view().render("addContact", context) // 6
        
    }
    
    /// Add Contact Post -Handler posts data to create a contact
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Create an Authentication helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer)
    /// 7. Make a client.
    /// 8. Make a post request with the headers to the API. Before sending execute the completion handler.
    /// 9. Create a contact object from the data.
    /// 10. Encode the content.
    /// 11. FlatMap the response to Future<Response>.
    // TODO: - Create a function / enum which checks the status code / case.
    /// 12. If the responses's status code equals to 401.
    /// 13. Destroy the session.
    /// 14. Redirect user to the "login" page.
    /// 15. If status code is not 401, decode a content of the response to contact and map the result of the completion handler to Future<Response>.
    /// 16. Unwrap the id of the contact.
    /// 17. Redirect the user to the next page which is \(contact.id)/.
    
    func addContactPostHandler(_ req: Request, data: AddContactData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort(.badRequest)} // 3
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        
        let client = try req.make(Client.self) // 7
    
        return client.post("http://localhost:9090/api/contacts", headers: auth.headers, beforeSend: { req in // 8
            let data = Contact(adLink: data.adLink, facebookLink: data.facebookLink, contactName: data.contactName) // 9
            try req.content.encode(data, as: .json) // 10
            
        }).flatMap(to: Response.self) { res in // 11
            
            if res.http.status.code == 401 { // 12
                auth.logout() // 13
                throw Abort.redirect(to: "/login") // 14
            }
            
            return try res.content.decode(Contact.self).map(to: Response.self) { contact in // 15
                guard let id = contact.id else {throw Abort.redirect(to: "/index")} // 16
                return req.redirect(to: "contact/\(id)") // 17
            }
        }
    }

    
    // MARK: - CREATE NEW AD HANDLERS
    
    /// Add Ad handler returns a Future<View> to add a ad.
    /// 1. Helper function generates a random token and saves it to the session and returns the token.
    /// 2. Get the cityID from the request's parameter.
    /// 3. Get the contactID from the request's parameter.
    /// 4. Make a client.
    /// 5. Make a get request and flatMap a response to Future<View>.
    /// 6. Encode a content of the response to Future<CityDepartment> Object.
    /// 7. Make another get request to get a contact and flatMap a response to Future<View>.
    /// 8. Encode a content of the response to Future<Contact> Object.
    /// 9. Create a context and pass the fetched data in.
    /// 10. Render "addAd.leaf" and pass the context in.
    
    func addAdHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        let cityID = try req.parameters.next(UUID.self) // 2
        let contactID = try req.parameters.next(UUID.self) // 3
        let client = try req.make(Client.self) // 4
        
        return client.get("http://localhost:9090/api/cities/id/\(cityID)").flatMap(to: View.self) { res in // 5
            
            let cityData = try res.content.decode(CityDepartment.self) // 6
            return client.get("http://localhost:9090/api/contacts/\(contactID)").flatMap(to: View.self) { res in // 7
                
                let contact = try res.content.decode(Contact.self) // 8
                let context = AddAdContext(title: "Create ad", csrfToken: token, contact: contact, cityDepartment: cityData) // 9
                return try req.view().render("addAd", context) // 10
            }
        }
    }
    

    /// Handler to make a post request to save data.
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Create an Authentication helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer)
    /// 7. Extract a cityID from the request's parameters.
    /// 8. Extract a contactID from the request's parameters.
    /// 9. Make a client.
    /// 10. Make a post request with the headers, before sending, execute the closure.
    /// 11. Create an ad using the data.
    /// 12. Encode the data.
    /// 13. FlatMap to the response, execute the closure.
    /// 14. Look if the response's http status code is 401 (unauthorized).
    /// 15. If yes, logout the user and redirect to the login page.
    /// 16. If not, try to decode the content of the response to the Ad. Map the ad to Future<Response>
    /// 17. Look if the data.offers is not nil.
    /// 18. Loop the data.offers through
    /// 19. Make an offerRequest to create a new offer.
    /// 20. Look if the data.demands is not nil.
    /// 21. Loop the data.demands through.
    /// 22. Make a demandRequest to create a new demand.
    /// 23. Return response and redirect user to the index page.
    
    func addAdPostHandler(_ req: Request, data: AdPostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort(.badRequest)} // 3
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        
        let cityID = try req.parameters.next(UUID.self) // 7
        let contactID = try req.parameters.next(UUID.self) // 8
        let client = try req.make(Client.self) // 9
        
        return client.post("http://localhost:9090/api/ads", headers: auth.headers, beforeSend: { req in // 10
            let data = Ad(note: data.note, generosity: data.generosity, images: nil, contactID: contactID, cityID: cityID) // 11
            try req.content.encode(data, as: .json) // 12
            print(data.note)
        }).flatMap(to: Response.self) { res in // 13
            
            if res.http.status.code == 401 { // 14
                auth.logout() // 15
                throw Abort.redirect(to: "/login")
            }
            
             return try res.content.decode(Ad.self).map(to: Response.self) { ad in // 16

                if data.offers != nil { // 17
                    for offer in data.offers! { // 18
                        _ = try OfferRequest.init(ending: "").createOffer(req, ad: ad, offer: offer) // 19
                    }
                }
                
                if data.demands != nil { // 20
                    for demand in data.demands! { // 21
                        _ = try DemandRequest.init(ending: "").createDemand(req, ad: ad, demand: demand) // 22
                    }
                }
                guard let id = ad.id else {throw Abort.redirect(to: "/index")}
                return req.redirect(to: "/\(id)/image") // 23
            }
        }
    }
    
    
    // MARK: - CREATE NEW COUNTRY HANDLERS
    
    /// Add Country handler returns a Future<View> to add a country
    /// 1. Helper function generates a random token and saves it to the session and returns the token.
    /// 2. Create a context and pass the token and title in.
    /// 3. Render "addCountry.leaf" and pass the context in. 
    
    func addCountryHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken()
        let context = CSRFTokenContext(title: "Add Country", csrfToken: token) // 2
        return try req.view().render("addCountry", context) // 4
        
    }
    
    /// PostCountryDataHandler returns Future<Response>
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Create an Authentication helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer)
    /// 7. Make a client.
    /// 8. Make a post request with the headers to the API. Before sending execute the completion handler.
    /// 9. Create a Country object from the data.
    /// 10. Encode the content.
    /// 11. Map the response to Future<Response>.
// TODO: - Create a function / enum which checks the status code / case.
    /// 12. If the responses's status code equals to 401.
    /// 13. Destroy the session.
    /// 14. Redirect user to the "login" page.
    /// 15. If status code is not 401, redirect user to the "countries.leaf" page.
    
    func addCountryPostHandler(_ req: Request, data: CountryPostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
         guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort(.badRequest)} // 3
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        
        let client = try req.make(Client.self) // 7
        
        return client.post("http://localhost:9090/api/countries", headers: auth.headers, beforeSend: { req in // 8
            let data = Country(country: data.country) // 9
            try req.content.encode(data, as: .json) // 10
            
        }).map(to: Response.self) { res in // 11
            
            if res.http.status.code == 401 { // 12
                auth.logout() // 13
                throw Abort.redirect(to: "/login") // 14
            }
            return req.redirect(to: "/countries/all") // 15
        
        }
    }
    
    
    // MARK: - CREATE NEW DEPARTMENT HANDLERS
    
    /// Add Department handler returns a Future<View> to add a country
    /// 1. Helper function generates a random token and saves it to the session and returns the token.
    /// 2. Make a client service.
    /// 3. Make a get request and map the response to Future<View> after completed Completion handler.
    /// 4. Decode the content to an array of countries.
    /// 5. Create a context and pass the token and a title and the countries in.
    /// 3. Render "addDepartment.leaf" and pass the context in.
    
    func addDepartmentHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        let client = try req.make(Client.self) // 2
        
        return client.get("http://localhost:9090/api/countries").flatMap(to: View.self) { res in // 3
            
            let countries = try res.content.decode([Country].self) // 4
            let context = AddDepartmentContext(countries: countries, title: "Add Department", csrfToken: token) // 5
            return try req.view().render("addDepartment", context) // 6
        }
    }
    
    /// Post Department Data Handler returns Future<Response>
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Auht helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer).
    /// 7. Make a client.
    /// 8. Make a post request with the headers to the API. Before sending execute the completion handler.
    /// 9. Create a department object from the data.
    /// 10. Encode the content.
    /// 11. Map the response to Future<Response>.
    /// 12. If the responses's status code equals to 401.
    /// 13. Destroy the session.
    /// 14. Redirect user to the "login" page.
    /// 15. If status code is not 401, redirect user to the "departments.leaf" page.
    
    func addDepartmentPostHandler(_ req: Request, data: DepartmentPostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort(.badRequest)} // 3
    
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        
        let client = try req.make(Client.self) // 7
        
        return client.post("http://localhost:9090/api/departments", headers: auth.headers, beforeSend: { req in // 8
            let data = Department(departmentNumber: data.departmentNumber, departmentName: data.departmentName, countryID: data.countryID) // 9
            try req.content.encode(data, as: .json) // 10
            
        }).map(to: Response.self) { res in // 11
            
            if res.http.status.code == 401 { // 12
                auth.logout() // 13
                throw Abort.redirect(to: "/login") // 14
            }
            return req.redirect(to: "/countries/all") // 15
        }
    }
    
    // MARK: - IMAGE HANDLERS
    
    /// Handler gets the view to add images to the ad.
    /// 1. Helper function generates a random token and saves it to the session and returns the token.
    /// 2. Make a context.
    /// 3. Render an addImage -leaf and pass the context in.
    func addImageHandler(_ req: Request) throws -> Future<View> {
        let token = CSRFToken(req: req).addToken() // 1
        let adID = try req.parameters.next(UUID.self)
        let context = ImageContext(title: "Add Images", adID: adID, csrfToken: token) // 2
        return try req.view().render("addImage", context) // 3
       
    }
    
    /// Handler to Make a post request to the API to post image data to the ad.
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Auht helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer).
    /// 7. Create an ad id by extracting the UUID from the request's parameter.
    /// 8. Make a client.
    /// 9. Make a post request with the headers to the API. Before sending execute the completion handler.
    /// 10. Create imageData from the data.
    /// 11. Encode the content.
    /// 12. Map the response to Future<Response>.
    /// 13. If the responses's status code equals to 401.
    /// 14. Destroy the session.
    /// 15. Throw an Abort and Redirect user to the "login" page.
    /// 16. If status code is not 401, redirect user to the "departments.leaf" page.
    
    func addImagePostHandler(_ req: Request, data: ImagePostData) throws -> Future<Response> {
    
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort(.badRequest)} // 3
   
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        
        let adID = try req.parameters.next(UUID.self) // 7
        let client = try req.make(Client.self) // 8
        
        return client.post("http://localhost:9090/aws/image", headers: auth.headers, beforeSend: { req in // 9
            
            let imageData = ImageData(image: data.image, adID: adID) // 10
            try req.content.encode(imageData, as: .json) // 11
            
        }).map(to: Response.self) { res in // 12
            if res.http.status.code == 401 { // 13
                auth.logout() // 14
                throw Abort.redirect(to: "/login") // 15
            }
            return req.redirect(to: "/index") // 16
        }
    }
    
   

    // MARK: - EDIT HANDLERS
    
    /// Route handler renders a view with the ad data of the selected ad to edit ad.
    /// 1. Extract the UUID from the request's parameter.
    /// 2. Make a client.
    /// 3. Generate a token.
    /// 4. Make a get request.
    /// 5. In the completion handler decode the content of the response to AdInfoData and map the result to Future<View>.
    /// 6. Make a get reques to get contact data of the ad.
    /// 7. In the completion handler decode the content of the response to Contact and flatMap the result to Future<View>.
    /// 8. Make a get request to fetch all the cities.
    /// 9. Decode the content of the request. 
    /// 10. Create a context with the fetched data.
    /// 11. Return and render the view with context.
    
    func editAdHandler(_ req: Request) throws -> Future<View> {
       
        let id = try req.parameters.next(UUID.self) // 1
        let client = try req.make(Client.self) // 2
        let token = CSRFToken(req: req).addToken() // 3
        
        return client.get("http://localhost:9090/api/ads/\(id)/").flatMap(to: View.self) { res in // 4
            return try res.content.decode(AdInfoData.self).flatMap(to: View.self) { data in // 5
                
                return client.get("http://localhost:9090/api/ads/\(id)/contact").flatMap(to: View.self) { resp in // 6
                    
                    let contact = try resp.content.decode(Contact.self) // 7
                    
                    return client.get("http://localhost:9090/api/cities").flatMap(to: View.self) { respo in // 8
                        
                        let cities = try respo.content.decode([City].self) // 9
                        
                        let context = FullAdContext(title: "Edit Ad", adInfo: data, contact: contact, csrfToken: token, cities: cities) // 10
                        return try req.view().render("editAd", context) // 11
                        
                    }
                }
            }
        }
    }
    
    /// Route handler posts new data to the API
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Auht helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer).
    /// 7. Make a client.
    /// 8. Make a put request with the headers to the API. Before sending the request execute the closure.
    /// 9. Encode data.
    /// 10. Map the response to Future<Response>.
    /// 11. Make a put rquest with the headers to the API. Before sending the request execute the closure.
    /// 12. Create a contact to send the data.
    /// 13. Encode the contact data.
    /// 14. Map the future to <Future>Response.
    /// 15. If the responses's status code equals to 401.
    /// 16. Log out the user.
    /// 17. Throw an Abort and Redirect user to the "login" page.
    /// 18. If status code is not 401, redirect user to the "index.leaf" page.
    func editAdPostHandler(_ req: Request, data: AdInfoPostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        let client = try req.make(Client.self) // 7
        
        return client.put("http://localhost:9090/api/ads/\(data.adID)/update", headers: auth.headers, beforeSend: { req in // 8
            
            try req.content.encode(data, as: .json) // 9
            
        }).flatMap(to: Response.self) { res in // 10
            
            return client.put("http://localhost:9090/api/contacts/\(data.contactID)/update", headers: auth.headers, beforeSend: { req in // 11
                
                let contact = Contact(adLink: data.adLink, facebookLink: data.facebookLink, contactName: data.contactName) // 12
                try req.content.encode(contact, as: .json) // 13
            
            }).map(to: Response.self) { res in // 14
                if res.http.status.code == 401 { // 15
                    auth.logout() // 16
                    throw Abort.redirect(to: "/login") // 17
                }
                return req.redirect(to: "/index") // 18
            }
        }
    }
    
    // MARK: - CREATE A PERIMETER HANDLERS
    
    /// A route handler to get a view to create a perimeter. Handler returns a future<View>.
    /// 1. Helper function generates a random token and saves it to the session and returns the token.
    /// 2. Crete a client and make a get request to get an array of the departments.
    /// 3. Encode the response data.
    /// 4. Create a context.
    /// 5. Render the view.
   
    func createPerimeterHandler(_ req: Request) throws -> Future<View> {
        
        let client = try req.make(Client.self) // 1
        // 2
        let token = CSRFToken(req: req).addToken()
        return client.get("http://localhost:9090/api/departments").flatMap(to: View.self) { res in
            
            let departments = try res.content.decode([Department].self) // 3
            
            let context = DepartmentsContext(title: "Create Perimeter", departments: departments, csrfToken: token) // 4
            return try req.view().render("perimeter", context) // 5
        }
    }
    
    /// A route handler to make a post request to create a perimeter (a sibling relationship between the selected models. Return HTTPResponse.
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Auht helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer).
    /// 7. Make a client.
    /// 8. Ensure that the id of the selected department is not a nil.
    /// 9. Make a post request with the headers and execute the closure before sending the request.
    /// 10. In the closure create and decode the data.
    /// 11. Map the future to <Future>Response.
    /// 12. If the responses's status code equals to 401.
    /// 13. Log out the user.
    /// 14. Throw an Abort and Redirect user to the "login" page.
    /// 15. If status code is not 401, redirect user to the "index.leaf" page.
    
    func createPostPerimeterHandler(_ req: Request, data: CreatePerimeterPostData) throws -> Future<Response> {

        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        let client = try req.make(Client.self) // 7
        
        
        print("departmentIDs are:", data.departmentIDs, "selected department is:", data.departmentID)
        
        return client.post("http://localhost:9090/api/departments/perimeter/\(data.departmentID)", headers: auth.headers, beforeSend: { req in // 9
            
            // 10
        //    let data = PerimeterPostData(departmentID: data.departmentID, departmentIDs: data.departmentIDs)
            try req.content.encode(data.departmentIDs, as: .json)
        }).map(to: Response.self) { res in // 11
            if res.http.status.code == 401 { // 12
                auth.logout() // 13
                throw Abort.redirect(to: "/login") // 14
            }
            return req.redirect(to: "/index") // 15
        }
    }

    // MARK: - SOFT DELETE AD MODEL
    /// A route handler to soft delete the selected ad
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Auht helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer).
    /// 7. Make a client.
    /// 8. Extract the ad id from the request's paremeters.
    /// 9. Make a delete request with the headers and map the future to <Future>Response.
    /// 10. If the responses's status code equals to 401.
    /// 11. Log out the user.
    /// 12. Throw an Abort and Redirect user to the "login" page.
    /// 13. If status code is not 401, redirect user to the "index.leaf" page.
    
    
    func softDeleteAdHandler(_ req: Request, data: CsrfToken) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        let client = try req.make(Client.self) // 7
        
        let adID = try req.parameters.next(UUID.self) // 8
            
        return client.delete("http://localhost:9090/api/ads/\(adID)/delete", headers: auth.headers).map(to: Response.self) { res in // 9
            if res.http.status.code == 401 { // 10
                auth.logout() // 11
                throw Abort.redirect(to: "/login") // 12
            }
            return req.redirect(to: "/index") // 13
        }
        }
    
    // MARK: - EDIT IMAGES
    
    /// Route Handler to return a view to delete/ad images
    /// 1. Helper function generates a random token and saves it to the session and returns the token.
    /// 2. Extract the ad id from the request's parameter.
    /// 3. Crete a client and make a get request to get an array of the departments.
    /// 4. Make a get request to the API and flatMap the response to future<View>
    /// 5. If the status code is 500:
    /// 6. Create a context where imagesData is nil.
    /// 7. Return and render the view.
    /// 8. If the status code is not 500.
    /// 9. Decode a content of the response to [ImageLink] and flatMap the future to Future<View>.
    /// 10. Create a context with the decoded data.
    /// 11. Return and render the view.
    func getImageEditHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        let adID = try req.parameters.next(UUID.self) // 2
        let client = try req.make(Client.self) // 3
        
        return client.get("http://localhost:9090/aws/\(adID)/images").flatMap(to: View.self) { res in // 4
            
            if res.http.status.code == 500 { // 5
                let context = EditImagesContext(title: "Images", imagesData: nil, adID: adID, csrfToken: token) // 6
                return try req.view().render("editImages", context) // 7
            } else { // 8
                return try res.content.decode([ImageLink].self).flatMap(to: View.self) { data in // 9
                    let context = EditImagesContext(title: "Images", imagesData: data, adID: adID, csrfToken: token) // 10
                    return try req.view().render("editImages", context) // 11
                }
            }
        }
    }
    
    /// Handler to make a post request to delete an image
    /// 1. Get the expected token from the request's session.
    /// 2. Set the token to nil in the session.
    /// 3. Look if the csrfToken and the existingToken matches. If not throw a bad request.
    /// 4. Auht helper.
    /// 5. Get the Auth token; if error occurs redirect to the login page.
    /// 6. Add token to the headers (bearer).
    /// 7. Make a client.
    /// 8. Extract the ad id from the request's paremeters.
    /// 9. Extract a name of the image from the request's parameters.
    /// 10. Make a delete request with the headers and map the future to <Future>Response.
    /// 11. If the responses's status code equals to 401.
    /// 12. Log out the user.
    /// 13. Throw an Abort and Redirect user to the "login" page.
    /// 14. If status code is not 401, redirect user to the "editImages" page.
    
    func deleteImageHandler(_ req: Request, data: DeleteImageData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort(.badRequest)} // 3
        
        let auth = Auth(req: req) // 4
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 5
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 6
        let client = try req.make(Client.self) // 7
        
        let adID = try req.parameters.next(UUID.self) // 8
        let imageName = data.imageName // 9
        
        return client.get("http://localhost:9090/aws/\(adID)/images/delete/\(imageName)", headers: auth.headers).map(to: Response.self) { res in // 10
            
            if res.http.status.code == 401 { // 11
                auth.logout() // 12
                throw Abort.redirect(to: "/login") // 13
            }
            return req.redirect(to: "/\(adID)/edit/image") // 14
            
        }
    }
    
}


struct DeleteImageData : Content {
    let csrfToken : String?
    let imageName : String
}
