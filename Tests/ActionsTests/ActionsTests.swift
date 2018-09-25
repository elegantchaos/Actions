// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions

final class ActionsTests: XCTestCase {
    class TestAction: Action {
        var performed = false
        override func perform(context: ActionContext) {
            performed = true
        }
    }

    func testBasics() {
        actionChannel.enabled = true

        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "test", sender: self)
        XCTAssertTrue(action.performed)
    }

    static var allTests = [
        ("testBasics", testBasics),
    ]
}
