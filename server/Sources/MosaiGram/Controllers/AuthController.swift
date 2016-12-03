import Kitura
import SwiftyJSON

class AuthController {

    let router: Router
    let repository: UserRepository
    
    init(_ router: Router, repository: UserRepository) {
        self.router = router
        self.repository = repository
        registerRoutes()
    }

    func registerRoutes() {
        
        router.post("/user/signup") {
            [weak self]
            request, response, next in
            
            guard let body = request.body, case .json(let json) = body else {
                try response.status(.badRequest).end()
                return
            }
            
            let username = json["username"].stringValue
            let password = json["password"].stringValue
            
            if let _ = self?.repository.findByUserName(username, password: password) {
                try response.status(.unauthorized).end()
                return
            }
            
            guard let _ = self?.repository.insertUser(username: username, password: password) else {
                try response.status(.internalServerError).end()
                return
            }
            
            request.session?["username"] = json["username"]
            response.status(.OK)
            next()
            return
        }
        
        router.post("/user/login") {
            [weak self]
            request, response, next in
            
            guard let body = request.body, case .json(let json) = body else {
                try response.status(.badRequest).end()
                return
            }
            
            let username = json["username"].stringValue
            let password = json["password"].stringValue
            
            guard let _ = self?.repository.findByUserName(username, password: password) else {
                try response.status(.unauthorized).end()
                return
            }
        
            request.session?["username"] = json["username"]
            response.status(.OK)
            next()
        }
    }
}
