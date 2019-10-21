import Vapor

/// # Register your application's routes here.
public func routes(_ router: Router) throws {

    /*
    Register Controllers
     1. Create a new controller object
     2. Register the new type with the router to ensure the controller's router get registered
     */
    
    let websiteController = WebsiteController() // 1
    try router.register(collection: websiteController) // 2
    
    let userWebsiteController = UserWebsiteController() // 1
    try router.register(collection: userWebsiteController) // 2
    
    let adminWebsiteController = AdminWebsiteController() // 1
    try router.register(collection: adminWebsiteController) // 2
    
    let standardWebsiteController = StandardWebsiteController() // 1
    try router.register(collection: standardWebsiteController) // 2
    
}
