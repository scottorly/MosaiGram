import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
import UIKit

typealias Feed = [[String:String]]

class FeedRepository {
    
    static let sharedRepository = FeedRepository(SessionService())
    
    let sessionService: SessionService
    
    let disposeBag = DisposeBag()
    
    var feed = Variable<[JSON]>([])
    var images = Variable<[String: UIImage]>([:])
    
    init(_ sessionService: SessionService) {
        self.sessionService = sessionService
        fetchFeed()
    }
    
    func fetchFeed() {
        sessionService.feed().subscribe { [weak self]
            next in
            if let element = next.element {
                self?.feed.value = element.arrayValue
            }
        }.addDisposableTo(disposeBag)
    }
    
    func fetchImage(url: String) -> Observable<UIImage> {
        return sessionService.imageFetcher(url: url).map { [weak self]
            image in
            self?.images.value[url] = image
            return image
        }
    }
    
    func uploadImage(image: UIImage) -> Observable<JSON> {
        let guid = "\(NSUUID().uuidString).png"
        let json = JSON(["url": guid])
        self.feed.value.append(json)
        self.images.value[guid] = image
        return sessionService.imageUploader(image: image, imageUrl: guid).map {
            feedJSON in
            return feedJSON
        }
    }
}
