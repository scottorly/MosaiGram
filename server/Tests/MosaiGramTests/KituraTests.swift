
/*
 
 Testable annotation does not work in Xcode 8
 - still required to include src files in test bundle target membership
 - testable also still need for Swift Package Manager testing
 :(
 
 */

import XCTest
import Kitura
import Swinject

@testable import KituraSample

class KituraTestCase: XCTestCase {

    let controller = MainController(Router())

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExists() {
        XCTAssertNotNil(controller)
    }

}
