import Kitura
import KituraSession
import HeliumLogger
import CloudFoundryEnv
import MongoKitten
import Foundation

HeliumLogger.use()

let mLabService = ProcessInfo.processInfo.environment["MLAB_SERVICE"] ?? "mongo"
let mongoUri = try? CloudFoundryEnv
    .getAppEnv()
    .getService(spec: mLabService)?
    .credentials?["uri"].stringValue ?? "mongodb://localhost:27017/mosaigram"

let server = try! Server(mongoURL: mongoUri!)

let router = Router()

let session = Session(secret: "kitura_session")

router.all(middleware: BodyParser())
router.all(middleware:session)

router.all("/feed") {
    request, response, next in
    guard let _ = request.session?["username"].string else {
        try response.status(.unauthorized).end()
        return
    }
    next()
}

let dbName = mongoUri?.components(separatedBy: "/").last ?? ""
let mongoService = MongoService(server, dbName: dbName)
let userRepo = UserRepository(mongoService)
let feedRepo = FeedRepository(mongoService)
let s3Service = S3Service()

let authController = AuthController(router, repository: userRepo)
let feedController = FeedController(router, repository: feedRepo, s3Service:s3Service)

do {
    let appEnv = try CloudFoundryEnv.getAppEnv()
    let port: Int = appEnv.port
    Kitura.addHTTPServer(onPort: port, with:router)
    Kitura.run()
} catch CloudFoundryEnvError.InvalidValue {
    
}
