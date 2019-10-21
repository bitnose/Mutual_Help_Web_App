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
        let adminUserRoutes = router.grouped("admin")
        
        /// Routes which requires users to be authenticated. If user is not authenticated, it redirects user to the "login" page.
        /// This creates a new route group, extending from authSessionRoutes that includes RedirectMiddleware. The application runs a request through RedirectMiddleware before it reaches the route handler, but after AuthenticationSessionMiddleware. This allows RedirectMiddleware to check for an authenticated user. RedirectMiddleware requires you to specify the path for redirecting unauthenticated users and the Authenticatabke type to check for. In this case, that's your User model.
        let protectedRoutes = adminUserRoutes.grouped(RedirectMiddleware())
        let adminRoutes = protectedRoutes.grouped(AdminAccessMiddleware())
        
        

        /*
         1. Get Request - GET VIEW TO GET ALL COUNTRIES - admin/coutries/all
         2. Get Request - GET VIEW TO ADD COUNTRY - admin/add/country
         3. Post Request - POST COUNTRY - admin/add/country
         4. Get Request - GET VIEW TO CREATE DEPARTMENTS - admin/add/department
         5. Post Request - POST DEPARTMENT - admin/add/department
         6. Get Request - GET VIEW TO CREATE PERIMETER - departments/perimeter
         7. Post Request - POST THE PERIMETER DATA TO CREATE PERIMETER - departments/perimeter
         8. Get Request - GET ALL THE ADS - admin/index
         9. Post Request - POST REQUEST TO DELTE USER - admin/delete/<User.ID>
         10. Get Request - GET DEPARTMENT DATA - admin/departments/<Department.ID>
         11. Post Request - DELETE DEPARTMENT WITH ID - admin/departments/delete/<Department.ID>
         12. Post Request - REMOVE DEPARTMENT FROM PERIMETER - admin/departments/delete/<Department.ID>/<Department.ID>
         13. Post Request - DELETE COUNTRY - countries/delete/<Country.ID>
         */
        
        adminRoutes.get("countries", "all", use: countriesHandler) // 1
        adminRoutes.get("add", "country", use: addCountryHandler) // 2
        adminRoutes.post(CountryPostData.self, at: "add", "country", use: addCountryPostHandler) // 3
        adminRoutes.get("add", "department", use: addDepartmentHandler) // 4
        adminRoutes.post(DepartmentPostData.self, at: "add", "department", use: addDepartmentPostHandler) // 5
        adminRoutes.get("departments", "perimeter", use: createPerimeterHandler) // 6
        adminRoutes.post(CreatePerimeterPostData.self, at: "departments", "perimeter", use: createPostPerimeterHandler) // 7
        adminRoutes.get("index", use: indexHandler) // 8
        adminRoutes.post(CSRFTokenData.self, at: "delete", UUID.parameter, use: deleteUserHandler) // 9
        adminRoutes.get("departments", UUID.parameter, use: getPerimeterOfDepartment) // 10
        adminRoutes.post(CSRFTokenData.self, at: "departments", "delete", UUID.parameter, use: deleteDepartmentHandler) // 11
        adminRoutes.post(CSRFTokenData.self, at: "departments", "delete", UUID.parameter, UUID.parameter, use: removeDepartmentFromPerimeterHandler) // 12
        adminRoutes.post(CSRFTokenData.self, at: "countries", "delete", UUID.parameter, use: deleteCountryHandler) // 13
        
        
    }
    
    // MARK: - DELETE HANDLERS
    
    /**
       # Delete country
        - Parameters:
           - req : Request
           - CSRFTokenData : Data which contains a token
        - Throws: Abort Redirect
        - Returns: Response
       1. Get the expected token from the request's session.
       2. Set the token to nil in the session.
       3. Look if the csrfToken and the existingToken matches. If not throw abort to redirect to the error page.
       4. Extract the country ID from the request.
       5. Make a department request to delete the selected country. Cathc the error.
        */
       func deleteCountryHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
           
           let expectedToken = CSRFToken(req: req).getToken() // 1
           _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
           let countryID = try req.parameters.next(UUID.self) // 4

           return try CountryRequest.init(ending: "delete/\(countryID)").deleteCountry(req) // 5
       }
       
    
    /**
    # Delete department
     - Parameters:
        - req : Request
        - CSRFTokenData : Data which contains a token
     - Throws: Abort Redirect
     - Returns: Response
    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches.  If not throw abort to redirect to the error page.
    4. Extract the department ID from the request.
    5. Make a department request to delete the selected department.
     */
    func deleteDepartmentHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
        let departmentID = try req.parameters.next(UUID.self)

        return try DepartmentRequest.init(ending: "delete/\(departmentID)").deleteDepartment(req)
    }
    
    /**
    # Remove department from the perimeter
     - Parameters:
        - req : Request
        - CSRFTokenData : Data which contains a token
     - Throws: Abort Redirect
     - Returns: Response
    1. Get the expected token from the request's session.
    2. Set the token to nil in the session.
    3. Look if the csrfToken and the existingToken matches. If not throw abort to redirect to the error page.
    4. Extract the department IDs from the request.
    5. Make a department request to remove the selected department from the perimeter.
     */
    func removeDepartmentFromPerimeterHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
        // 4
        let departmentID = try req.parameters.next(UUID.self)
        let departmentToRemove = try req.parameters.next(UUID.self)

        return try DepartmentRequest.init(ending: "delete/\(departmentID)/\(departmentToRemove)").removeDepartmentFromPerimeter(req, to: "\(departmentID)") // 5
    }

    // MARK: - GET DATA HANDLERS
    
    /**
     # Handler to render a view to view all the departments and countries
     - Parameters:
        - req : Request
     - Throws: Abort Redirect
     - Returns: View
     
     1. Generate a csrfToken and save it to the session.
     2. Fetch the data by making a country request.
     3. Look up if the cookies are accepted.
     4. Create a response context which contains data for the landing.leaf page.
     5. Return and render the view and pass the context in.
    */
    func countriesHandler(_ req: Request) throws -> Future<View> {
        let token = CSRFToken(req: req).addToken() // 1
        
        let countriesWithDepartments = try CountryRequest.init(ending: "departments").getCountriesWithDepartments(req) // 2
    
        let showCookieMessage = req.http.cookies["cookies-accepted"] == nil // 3

        let context = CountryContext(countries: countriesWithDepartments, title: "Countries and Departments", userLoggedIn: true, isAdmin: true, csrfToken: token, showCookieMessage: showCookieMessage) // 4
        
        return try req.view().render("countries", context) // 5
            
        
    }
    
 
    
    // MARK: - CREATE NEW COUNTRY HANDLERS
    
    /**
     # Add Country handler returns a Future<View> to add a country
     - Parameters:
            - req : Request
     - Throws: Abort Redirect
     - Returns: View
     1. Helper function generates a random token and saves it to the session and returns the token.
     2. Create a context and pass the token and title in.
     3. Render "addCountry.leaf" and pass the context in.
    */
    func addCountryHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        let context = CSRFTokenContext(title: "Add Country", csrfToken: token, isAdmin: true, userLoggedIn: true) // 2
        return try req.view().render("addCountry", context) // 4
        
    }
    
    /**
    # PostCountryDataHandler returns Future<Response>
     - Parameters:
        - req : Request
        - data : CountryPostData
    - Throws: Abort Redirect
    - Returns: Response
     
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches.  If not throw abort to redirect to the error page.
     4. Make a country request to create a new country.
    */
    func addCountryPostHandler(_ req: Request, data: CountryPostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
        
        return try CountryRequest.init(ending: "").createCountry(req, name: data.country) // 4
        
    }
    
    
    // MARK: - CREATE NEW DEPARTMENT HANDLERS
    
    /**
     # Add Department handler returns a Future<View> to add a country
     - Parameters:
        - req : Request
     - Throws: Abort Redirect
     - Returns: View
     
     1. Helper function generates a random token and saves it to the session and returns the token.
     2. Make a country request to fetch all the countries.
     3. Create a context and populate it with the token, a title and the countries.
     4. Render "addDepartment.leaf" and pass the context in.
    */
    func addDepartmentHandler(_ req: Request) throws -> Future<View> {
        
        let token = CSRFToken(req: req).addToken() // 1
        
        let countries = try CountryRequest.init(ending: "").getCountries(req) // 2
        
        let context = AddDepartmentContext(countries: countries, title: "Add Department", csrfToken: token) // 3
        return try req.view().render("addDepartment", context) // 4
        
    }
    
    /**
    # Post Department Data Handler returns Future<Response>
     - Parameters:
        - req : Request
        - data: DepartmentPostData
    - Throws: Abort Redirect
    - Returns: Response
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw abort and redirect to the error.leaf page.
     4. Make a department request and return the response.
    */
    func addDepartmentPostHandler(_ req: Request, data: DepartmentPostData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else { throw Abort.redirect(to: "/error")} // 3
    
        return try DepartmentRequest.init(ending: "").postDepartment(req, data: data) // 4
    }
    
  
    
    // MARK: - CREATE A PERIMETER HANDLERS
    
    /**
    # A route handler to get a view to create a perimeter.
    - Parameters:
        - req : Request
    - Throws: Abort Redirect
    - Returns: View
 
    1. Helper function generates a random token and saves it to the session and returns the token.
    2. Make a department request to get a future array of the departments.
    3. Create a context.
    4. Render the view.
   */
    func createPerimeterHandler(_ req: Request) throws -> Future<View> {

        let token = CSRFToken(req: req).addToken() // 1
        let departments = try DepartmentRequest.init(ending: "").getDepartmentsData(req) // 2
                    
        let context = DepartmentsContext(title: "Create Perimeter", departments: departments, csrfToken: token, message: nil, isAdmin: true) // 3
        return try req.view().render("perimeter", context) // 4
        
    }
    
    /**
     # A route handler to make a post request to create a perimeter (a sibling relationship between the selected models.
     - Parameters:
         - req : Request
         - data: CreatePerimeterPostData
     - Throws: Abort Redirect
     - Returns: Response
     1. Get the expected token from the request's session.
     2. Set the token to nil in the session.
     3. Look if the csrfToken and the existingToken matches. If not throw a abort and redirect to the error page.
     4. Make a department reques to post perimeter.
    */
    func createPostPerimeterHandler(_ req: Request, data: CreatePerimeterPostData) throws -> Future<Response> {

        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3
        
        return try DepartmentRequest.init(ending: "perimeter/\(data.departmentID)").postPerimeter(req, data: data) // 4
        
    }
    
    
    /**
     # Handler to Render adminIndex.leaf view
     - Parameters:
        - req : Request
     - Throws: Abort Redirect
     - Returns: View
     
     1. Helper function generates a random token and saves it to the session and returns the token.
     2. Make an user request to get a future array of the users.
     3. Make an ad request to fetch the ads with user.
     4. Create a context.
     5. Render the view with the context.
     */
    func indexHandler(_ req: Request) throws -> Future<View> {
        
        let csrfToken = CSRFToken(req: req).addToken() // 1
        let users = try UserRequest.init(ending: "all").getUsers(req) // 2
        let ads = try AdRequest.init(ending: "all").getAdsWithUser(req) // 3
        
        let context = AdminAdInfoContext(title: "All ads", adInfo: ads, csrfToken: csrfToken, users: users) // 4
        
        return try req.view().render("adminIndex", context) // 5
    }
    
    
    /**
     # Delete user handler
     - parameters:
        - req: Request
        - data: CSRFTokenData
     - throws: Abort
     - returns: Response
     
      1. Get the expected token from the request's session.
      2. Set the token to nil in the session.
      3. Look if the csrfToken and the existingToken matches. If not redirect to the error page.
      4. Extract the user id from the parameter.
      5. Make an user request to delete the user.

     */
    func deleteUserHandler(_ req: Request, data: CSRFTokenData) throws -> Future<Response> {
        
        let expectedToken = CSRFToken(req: req).getToken() // 1
        _ = CSRFToken(req: req).destroyToken // 2
        guard let csrfToken = data.csrfToken,expectedToken == csrfToken else {throw Abort.redirect(to: "/error")} // 3
        
        let userID = try req.parameters.next(UUID.self) // 4
        
        return try UserRequest.init(ending: "delete/user/\(userID)").deleteUser(req) // 5

    }
    
    
    /**
    # Render the department.leaf view
    - parameters:
        - req: Request
        - throws: Abort
    - returns: View

    1. Helper function generates a random token and saves it to the session and returns the token.
    2. Extract the department id from the parameter.
    3. Make department request to fetch the data. Throws if errors.
    4. Populate context with the data.
    5. Render the department.leaf page.
    */
    func getPerimeterOfDepartment(_ req: Request) throws -> Future<View> {
        let csrfToken = CSRFToken(req: req).addToken() // 1
        let departmentID = try req.parameters.next(UUID.self) // 2
        
        let departments = try DepartmentRequest.init(ending: "\(departmentID)/perimeter").getPerimeterData(req) // 3
        let context = PerimeterOfDepartmentContext(title: "Perimeter of Department", csrfToken: csrfToken, departmentData: departments) // 4
        return try req.view().render("department", context) // 5
    }
}



