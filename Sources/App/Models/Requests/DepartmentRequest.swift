//
//  DepartmentRequest.swift
//  App
//
//  Created by Sötnos on 15/09/2019.
//

import Foundation
import Vapor
import Leaf


/// DepartmentRequest : Data type which handles making a department requests to the API
/// - resource : The base URL to make an ad request to the API
/// - ending : Ending of the URL / API
struct DepartmentRequest {
    
    let resource: URL
    
    init(ending: String) {
        /// Creates an url combining the resourceString and resource URL
        let resourceString = "http://localhost:9090/api/departments/\(ending)"
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        
        self.resource = resourceURL
    }
    
    /**
    # Post Department Data
    - Parameters:
            - req: Request
     - Throws: Abort Redirect
     - Returns: Response
     
    1. Auht helper
    2. Get the Auth token; if error occurs redirect to the login page.
    3.  Add token to the headers (bearer)
    4. Make a client.
    5. Make a post request with the headers to the API. Before sending execute the completion handler.
    6. Create a department object from the data.
    7. Encode the content.
    8. Map the response to Future<Response>.
    9. If the user is not authorized logout the user.
    10. If the response status code is 201, success. Redirect the user to the countries.leaf page.
    11. Otherwise redirect to the error.leaf page.
   */
    func postDepartment(_ req: Request, data: DepartmentPostData) throws -> Future<Response> {
       
       let auth = Auth(req: req) // 1
       guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
       auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
       let client = try req.make(Client.self) // 4
    
       return client.post(resource, headers: auth.headers, beforeSend: { req in // 5
           let data = Department(departmentNumber: data.departmentNumber, departmentName: data.departmentName, countryID: data.countryID) // 6
            try req.content.encode(data, as: .json) // 7
           
       }).map(to: Response.self) { res in // 8
        
           if !Auth.init(req: req).isAuthorized(response: res) { // 9
                throw Abort.redirect(to: "/login")
            } else if res.http.status.code == 201 { // 10
                 return req.redirect(to: "/admin/countries/all")
            } else { // 12
                throw Abort.redirect(to: "/error")
            }
        }
   }
       
    
    /**
     # Request to get all the departments
     - Parameters:
            - req: Request
     - Throws: Abort Redirect
     - Returns: Response
     
     1. Auht helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3.  Add token to the headers (bearer)
     4. Make a client.
     5. Make a get request to the API with the headers. Map the response to the Future<[Department]>.
     6. If the user is not authorized, he/she will be logged out.
     7. Throw abort and redirect to the login page.
     8. If the response status code is equal to 200, it means that the request was completed successfully.
     9. Return and redirect the user to the index page.
     10. If the resolving future resolves as an error, print the error message.
     11. Throw abort and redirect the user to the error page.
     10. Otherwise redirect the user to the error page.
    */
    func getDepartmentsData(_ req: Request) throws -> Future<[Department]> { // 1
        
        let client = try req.make(Client.self) // 1
        let auth = Auth(req: req) // 2
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 3
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 4
        
        return client.get(resource, headers: auth.headers).flatMap(to: [Department].self) { res in // 5
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login") // 7
            } else if res.http.status.code == 200 { // 8
                return try res.content.decode([Department].self).catchMap { error in // 9
                    print(error, "Error with creating city") // 10
                    throw Abort.redirect(to: "/error") // 11
                }
            } else { // 12
                throw Abort.redirect(to: "/error")
            }
        }
    }
    
    /**
    # Request to get the departments from the database.
    - Parameters:
        - req: Request
    - Throws: Abort Redirect
    - Returns: DepartmentWithPerimeter
    1. Auht helper
    2. Get the Auth token; if error occurs redirect to the login page.
    3.  Add token to the headers (bearer)
    4. Make a client.
    5. Make a get request to the API with the headers. Map the response to the Future<DepartmentWithPerimeter>.
    6. If the status code is equal to 401.  Logout the user. Throw abort and redirect to the login page.
    7. If the response status code is equal to 200, try to decode the content. If the resolving future resolves as an error, catch it and throw abort to redirect to the error.leaf page.
    8. If status code is something else throw abort and redirect the user to the error page.
    */
    func getPerimeterData(_ req: Request) throws -> Future<DepartmentWithPerimeter> {

        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        let client = try req.make(Client.self) // 4
        
        return client.get(resource, headers: auth.headers).flatMap(to: DepartmentWithPerimeter.self) { res in // 5
            
            if !Auth.init(req: req).isAuthorized(response: res) { // 6
                throw Abort.redirect(to: "/login")
            } else if res.http.status.code == 200 { // 7
                return try res.content.decode(DepartmentWithPerimeter.self).catchMap { error in
                    print(error)
                    throw Abort.redirect(to: "/error")
                }
            } else { // 8
                throw Abort.redirect(to: "/error")
            }
        }
    }
    
    
    /**
     # Delete Department Request
     - Parameters:
        - req: Request
     - Throws: Abort Redirect
     - Returns: Response
     
     1. Auht helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3.  Add token to the headers (bearer)
     4. Make a client.
     5. Make a delete request to the API with the headers. Map the response to the Future<Response>.
     6. If the status code is equal to 401.
     7. Logout the user.
     8. Throw abort and redirect to the login page.
     9. If the response status code is equal to 204, it means that the deletion was successfull.
     10. Return and redirect the user to the index page.
     11.  Otherwise redirect the user to the error page.
     12. If the resolving future resolves as an error, catch it and throw abort to redirect to the error.leaf page.
     */
    
    func deleteDepartment(_ req: Request) throws -> Future<Response> {
        
       let auth = Auth(req: req) // 1
       guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
       auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
       let client = try req.make(Client.self) // 4
       
       return client.delete(resource, headers: auth.headers).map(to: Response.self) { res in // 5
           if !Auth.init(req: req).isAuthorized(response: res) { // 6...
               throw Abort.redirect(to: "/login") // ...8
           } else if res.http.status.code == 204 { // 9
               return req.redirect(to: "/admin/countries/all") // 10
           } else { // 11
               return req.redirect(to: "/error")
           }
       }.catchMap { error in // 12
           print(error)
           throw Abort.redirect(to: "/error")
       }
    }
    
    /**
     # Remove Relationship (Department-Department) Request
     - Parameters:
        - req: Request
        - to: String (The endpoint where the user will be redirected when the request and response completed successfully)
     - Throws: Abort Redirect
     - Returns: Response
     
     1. Auht helper
     2. Get the Auth token; if error occurs redirect to the login page.
     3.  Add token to the headers (bearer)
     4. Make a client.
     5. Make a put request to the API with the headers. Map the response to the Future<Response>.
     6. If the status code is equal to 401.
     7. Logout the user.
     8. Throw abort and redirect to the login page.
     9. If the response status code is equal to 204, it means that the deletion was successfull. Redirect to the department.leaf page.
     10. Return and redirect the user to the error page.
     11.  If the resolving future resolves as an error, catch errors throw abort and redirect the user to the error page.
     */

    func removeDepartmentFromPerimeter(_ req: Request, to page: String) throws -> Future<Response> {
        
       let auth = Auth(req: req) // 1
       guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
       auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
       let client = try req.make(Client.self) // 4
       
       return client.put(resource, headers: auth.headers).map(to: Response.self) { res in // 5
           if !Auth.init(req: req).isAuthorized(response: res) { // 6...
               throw Abort.redirect(to: "/login") // ...8
           } else if res.http.status.code == 204 { // 9
                return req.redirect(to: "/admin/departments/\(page)")
           } else { // 10
               return req.redirect(to: "/error")
           }
        }.catchMap { error in // 11
            print(error)
            throw Abort.redirect(to: "/error")
        }
    }
    
    /**
       # Make a post request to create a perimeter (a sibling relationship between the selected models.
     - Parameters:
        - req: Request
        - data: CreatePerimeterPostData
     - Throws: Abort Redirect
     - Returns: Response
    
      1. Auht helper
      2. Get the Auth token; if error occurs redirect to the login page.
      3.  Add token to the headers (bearer)
      4. Make a client.
      5. Make a post request to the API with the headers. Complete beforeSend.
      6 In the do catch block try to encode the array department IDs. If errors print them out and throw Abort ro redirect.
      7. Map the response to the Future<Response>.
      8. If the status code is equal to 401, Logout the user and  Throw abort and redirect to the login page.
      9. If the response status code is equal to 201, it means that the creation was successfull. Redirect to the countries.leaf page.
      10. Otherwise return and redirect the user to the error page.
      */
      
    func postPerimeter(_ req: Request, data: CreatePerimeterPostData) throws -> Future<Response> {
          
        let auth = Auth(req: req) // 1
        guard let token = auth.token else { auth.logout(); throw Abort.redirect(to: "/login")} // 2
        auth.headers.bearerAuthorization = BearerAuthorization(token: token) // 3
        let client = try req.make(Client.self) // 4
        
        return client.post(resource, headers: auth.headers, beforeSend: { req in // 5
            // 6
            do {
                try req.content.encode(data.departmentIDs, as: .json)
            } catch let error {
                print(error)
                throw Abort.redirect(to: "/error")
            }
        }).map(to: Response.self) { res in // 7
            if !Auth.init(req: req).isAuthorized(response: res) { // 8
                throw Abort.redirect(to: "/login")
            } else if res.http.status.code == 201 { // 9
                return req.redirect(to: "/admin/countries/all")
            } else {
                 throw Abort.redirect(to: "/login") // 10
            }
        }
    }
}

