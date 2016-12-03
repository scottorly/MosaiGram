import MongoKitten

class UserRepository {
    
    let mongo: MongoService
    let userCollection: MongoCollection
    
    init(_ mongoService: MongoService) {
        mongo = mongoService
        userCollection = mongoService.userCollection()
    }
    
    func findByUserName(_ username: String, password: String) -> Document? {
        do {
            let result = try userCollection.findOne(matching: "username" == username)
            return result
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func insertUser(username: String, password: String) -> Value? {
        do {
            let result = try userCollection.insert([
                "username": ~username,
                "password": ~password
                ])
            return result
        } catch let error {
            print(error)
            return nil
        }
    }

}
