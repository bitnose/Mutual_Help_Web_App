//
//  EegjConfig.swift
//  App
//
//  Created by Sötnos on 23/10/2019.
//
import VaporExt

// MARK: - Class responsible for holding EegjAPI config
public struct EegjAPIConfig {
    
    let hostname : String
    let port : Int

}
    // MARK: - Class responsible for providing correct EegjAPI configuration
    // A class responsible for unwrapping the .env file
class EegjAPIConfiguration {
        
    // MARK: - Instance Methods
    func setup() -> EegjAPIConfig {
        
        Environment.dotenv(filename: Keys.filename)
        
        guard
        let hostname: String = Environment.get(Keys.hostname),
            let port: Int = Environment.get(Keys.port) else { fatalError("Missing values in .env file")}
        
            
        let config = EegjAPIConfig(hostname: hostname, port: port)
        return config
    
    }
}


// MARK: - Extension with keys used in .env file
private extension EegjAPIConfiguration {
    
    struct Keys {
        
        private init() { }
        
        static let filename = "eegj-API-config.env"
        static let hostname = "EEGJ_API_HOSTNAME"
        static let port = "EEGJ_API_PORT"
    }
}



