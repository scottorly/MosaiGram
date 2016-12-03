import Kitura
import Cryptor
import Foundation
import Swawsh
import KituraNet
import Cryptor

class S3Service {
    
    let swawsh = SwawshCredential.sharedInstance
    
    let accessKey = ProcessInfo.processInfo.environment["S3_ACCESS_KEY"] ?? ""
    let secret = ProcessInfo.processInfo.environment["S3_SECRET"] ?? ""
    let bucketName = ProcessInfo.processInfo.environment["S3_BUCKET"] ?? ""
    let hostname = ProcessInfo.processInfo.environment["S3_HOSTNAME"] ?? ""
    let region =  ProcessInfo.processInfo.environment["S3_REGION"] ?? ""

    func uploadImageData(_ data: Data, fileName: String) {
    
        let sha256 = Digest(using: .sha256)
        let digest = sha256.update(data: data)?.final()
        let digestHexString = CryptoUtils.hexString(from: digest!)
        let authorization = swawsh.generateCredential(
            method: .PUT,
            path: "/\(bucketName)/\(fileName)",
            endPoint: hostname,
            queryParameters: "",
            payloadDigest: digestHexString,
            region: region,
            service: "s3",
            accessKeyId: accessKey,
            secretKey: secret
        )
        
        let headers: ClientRequest.Options = .headers(
            [
                "host": hostname,
                "Authorization": authorization!,
                "x-amz-date": swawsh.getDate(),
                "x-amz-content-sha256": digestHexString,
                "Content-Type": "multipart/form-data;",
                "Content-Length": "\(data.count)",
                "Transfer-Encoding": ""
             ]
        )
        let options: [ClientRequest.Options] = [
            .method("PUT"),
            .hostname(hostname),
            .path("\(bucketName)/\(fileName)"),
            headers
        ]
        let clientRequest = HTTP.request(options) { response in
            print("response: \(response?.statusCode)")
            let responseString = try! response?.readString()
            print(responseString ?? "empty response")
        }
    
        clientRequest.write(from: data)
        clientRequest.end(close: true)
    }
}
