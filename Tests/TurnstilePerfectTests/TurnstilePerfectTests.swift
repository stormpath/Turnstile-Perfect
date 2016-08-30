import XCTest
@testable import TurnstilePerfect

class TurnstilePerfectTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(TurnstilePerfect().text, "Hello, World!")
    }


    static var allTests : [(String, (TurnstilePerfectTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
