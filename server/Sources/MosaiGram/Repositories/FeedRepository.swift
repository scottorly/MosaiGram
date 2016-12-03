import MongoKitten
import SwiftyJSON

class FeedRepository {
    
    let service: MongoService
    let feedCollection: MongoCollection
    
    init(_ mongoService: MongoService) {
        service = mongoService
        feedCollection = mongoService.feedCollection()
    }
    
    func getFeed(username: String) -> JSON? {
        let feedProjection = Projection(["_id": .int32(0)])
        do {
            let result = try feedCollection.find(
                matching: "username" == username,
                sortedBy: nil,
                projecting: feedProjection,
                skipping: nil,
                limitedTo: nil,
                withBatchSize: 100
            )
            let results = Array(result)
            let json: [JSONDictionary] = results.flatMap {
                FeedItem(
                    username: $0["username"].string,
                    url: $0["url"].string
                    ).toDictionary()
            }
            let jsonResult = JSON(json)
            return jsonResult
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func addToFeed(item: JSON) -> Value? {
        do {
            let result = try feedCollection.insert([
                "username": ~item["username"].stringValue,
                "url": ~item["url"].stringValue
                ])
            return result
        } catch let error {
            print(error)
            return nil
        }
    }
}

typealias JSONDictionary = Dictionary<String, String>

public struct FeedItem {
    let username: String
    let url: String
}

protocol DictionaryConvertible {
    func toDictionary() -> JSONDictionary
}

extension FeedItem: DictionaryConvertible {
    func toDictionary() -> JSONDictionary {
        var result = JSONDictionary()
        result["username"] = username
        result["url"] = url
        return result
    }
}
