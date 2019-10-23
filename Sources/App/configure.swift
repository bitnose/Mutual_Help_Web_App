import Vapor
import Leaf
import Redis
import VaporExt


/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(LeafProvider())
    try services.register(RedisProvider()) // This allows your app to use Redis
   
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // There is a default limit of 1 million bytes for incoming requests, which you can override by registering a custom NIOServerConfig instance like this:
    services.register(NIOServerConfig.default(maxBodySize: 20_000_000))
    /// Configure EegjAPIConfigurations
   
     
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    
//    let corsConfiguration = CORSMiddleware.Configuration(
//          allowedOrigin: .all,
//          allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
//          allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
//      )
//
//    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
//    middlewares.use(corsMiddleware)
    
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) // Enables sessions for all request. This registers the sessions middleware as a global middleware for your application
    services.register(middlewares)
      
    // Get the environment variables from the redis-config.env file
    Environment.dotenv(filename: "redis-config.env")

    // Set up redis config variables
    let hostname = Environment.get("REDIS_HOSTNAME", "")
    let database = Environment.get("REDIS_PASSWORD", "")
    let password = Environment.get("REDIS_DATABASE", "")
    let port = Environment.get("REDIS_PORT", Int())
    // Create a redis string to make an URL
    let redisUrlString = "redis://\(password)@\(hostname):\(port)/\(database)"
    guard let redisUrl = URL(string: redisUrlString) else { throw Abort(.internalServerError) } // Convert a string to an url
      // Create a RedisDatabase using the configuration you set up
    let redis = try RedisDatabase(config: RedisClientConfig(url: redisUrl))

    // Register the configured Redis database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: redis, as: .redis)
    services.register(databases)
    

    // 1 Tells Vapor to use LeafRenderer when asked for a ViewRenderer type
    // 2 This tells your application to use Redis when asked for the KeyedCache service. The KeyedCache service is a key-value cache that backs sessions.
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self) // 1
    config.prefer(RedisCache.self, for: KeyedCache.self) // 2
   

   
}
