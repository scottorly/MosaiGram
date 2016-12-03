import Kitura
import Foundation
import SwiftyJSON

class FeedController {
 
    let router: Router
    let feedRepository: FeedRepository
    let s3Service: S3Service

    init(_ router: Router, repository: FeedRepository, s3Service: S3Service) {
        self.router = router
        self.feedRepository = repository
        self.s3Service = s3Service
        registerRoutes()
    }
    
    func registerRoutes() {
        
        router.get("/feed") { [weak self]
            request, response, next in
            let username = request.session?["username"].string ?? ""
            guard let feed = self?.feedRepository.getFeed(username: username) else {
                try response.status(.internalServerError).end()
                return
            }
            try response.send(json: feed).end()
        }
        
        router.post("/image/:imageName") { [weak self]
            request, response, next in
            
            var imageData = Data()
            guard let _ = try? request.read(into: &imageData) else {
                try response.status(.internalServerError).end()
                return
            }
            guard let imageName = request.parameters["imageName"] else {
                try response.status(.internalServerError).end()
                return
            }
            var feedDict = JSONDictionary()
            feedDict["username"] = request.session?["username"].string ?? ""
            feedDict["url"] = imageName
            let json = JSON(feedDict)
            guard let _ = self?.feedRepository.addToFeed(item: json) else {
                try response.status(.internalServerError).end()
                return
            }
            self?.s3Service.uploadImageData(imageData, fileName: imageName)
            try response.status(.OK).end()
            
        }
        
        router.get("/feed/user/:username") { [weak self]
            request, response, next in
            let username = request.parameters["username"] ?? ""
            guard let feed = self?.feedRepository.getFeed(username: username) else {
                try response.status(.internalServerError).end()
                return
            }
            try response.send(json: feed).end()
        }
    }
}
