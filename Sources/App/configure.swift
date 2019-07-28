import Vapor
import Leaf
import Authentication
/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) // Enables sessions for all request. This registers the sessions middleware as a global middleware for your application
    services.register(middlewares)
    

    // 1 Tells Vapor to use LeafRenderer when asked for a ViewRenderer type
    // 2 This tells your application to use MemoryKeyedCache when asked for the KeyedCache service. The KeyedCache service is a key-value cache that backs sessions.
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self) // 1
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self) // 2

   
}
