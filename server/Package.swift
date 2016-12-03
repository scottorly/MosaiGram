import PackageDescription

let package = Package(
    name: "MosaiGram",
    dependencies: [
	.Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 2),
 	.Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion:1, minor: 1),
 	.Package(url: "https://github.com/IBM-Swift/Kitura-Session.git", majorVersion: 1, minor: 2),
 	.Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 2, minor: 0),
	.Package(url: "https://github.com/AliSoftware/Dip", majorVersion: 5, minor: 0),
 	.Package(url: "https://github.com/IBM-Swift/Swift-cfenv", majorVersion: 1, minor: 8),
 	.Package(url: "https://github.com/ScottORLY/Swawsh.git", majorVersion: 0, minor: 1)
    ]
)
