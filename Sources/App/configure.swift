import Vapor
import Leaf
import Redis

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
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    
    var redisConfig = RedisClientConfig() // To configure the redis database
    // Set the hostname to the REDIS_HOSTNAME environment variable, if it exists. This allows you to inject the hostname in for hosting solutions.
    if let redisHostname = Environment.get("REDIS_HOSTNAME") {
        redisConfig.hostname = redisHostname
    }
    // Create a RedisDatabase using the configuration you set up
    let redis = try RedisDatabase(config: redisConfig)
 
    // Register the configured Redis database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: redis, as: .redis)
    services.register(databases)
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self) // Enables sessions for all request. This registers the sessions middleware as a global middleware for your application
    services.register(middlewares)
    

    // 1 Tells Vapor to use LeafRenderer when asked for a ViewRenderer type
    // 2 This tells your application to use Redis when asked for the KeyedCache service. The KeyedCache service is a key-value cache that backs sessions.
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self) // 1
    config.prefer(RedisCache.self, for: KeyedCache.self) // 2
   

   
}
