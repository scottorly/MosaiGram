import Foundation
import XCTest

@testable import KituraSample

class S3ServiceTests: XCTest {
    
    let subject = S3Service()
    
    func testGetDate() {
        let result = subject.getDate()
        XCTAssertEqual(result, "20160909T0000000Z")
    }
}
