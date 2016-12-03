import MongoKitten
typealias MongoCollection = MongoKitten.Collection
class MongoService {
    
    let server: Server
    let database: Database
    
    init(_ mongoServer: Server, dbName: String) {
        server = mongoServer
        database = server[dbName]
    }
    
    func userCollection() -> MongoCollection {
        return database["users"]
    }
    
    func feedCollection() -> MongoCollection {
        return database["feed"]
    }
    
}
