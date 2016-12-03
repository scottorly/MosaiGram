import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa
import UIKit

public class SessionService {
    let host = ProcessInfo.processInfo.environment["HOST"]!
    let s3 = ProcessInfo.processInfo.environment["S3"]!
    let session = URLSession.shared
    let defaultHeaders = [
        "Content-Type":"application/json",
        "Accept":"application/json"
    ]
    
    func urlRequest(path: String, method: String, body: Data?, headers: [String:String]) -> URLRequest {
        let urlString = "\(host)/\(path)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
    
    func feed() -> Observable<JSON> {
        let request = urlRequest(path: "feed", method: "GET", body: nil, headers: defaultHeaders)
        return session.rx.response(request: request).flatMap {
            response, data -> Observable<JSON> in
            let json = JSON(data: data)
            return Observable.create { observer in
                observer.on(.next(json))
                observer.on(.completed)
                return Disposables.create()
            }
        }.observeOn(MainScheduler.instance)
    }
    
    func imageFetcher(url: String) -> Observable<UIImage> {
        let fullUrl = "\(s3)/\(url)"
        var urlRequest = URLRequest(url: URL(string: fullUrl)!)
        urlRequest.httpMethod = "GET"
        return session.rx.data(request: urlRequest).flatMap {
            data -> Observable<UIImage> in
            guard let image = UIImage(data: data) else {
                return Observable.error(SessionError.serverError)
            }
            return Observable.create { observer in
                observer.on(.next(image))
                observer.on(.completed)
                return Disposables.create()
            }
        }.observeOn(MainScheduler.instance)
    }
    
    func imageUploader(image: UIImage, imageUrl: String) -> Observable<JSON> {
        let data = UIImageJPEGRepresentation(image, 0.2)
        let path = "image/\(imageUrl)"
        let headers = ["Content-Type": "application/octet-stream"]
        let request = urlRequest(path: path, method: "POST", body: data, headers: headers)
        return session.rx.response(request: request).flatMap {
            response, data -> Observable<JSON> in
            if response.statusCode != 200 {
                return Observable.error(SessionError.serverError)
            }
            return Observable.create { observer in
                observer.on(.next(JSON(["url": imageUrl])))
                observer.on(.completed)
                return Disposables.create()
            }
        }.observeOn(MainScheduler.instance)
    }
}

enum SessionError: Error {
    case serverError
    case malformedUrl
}
