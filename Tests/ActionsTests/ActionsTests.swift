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
        ActionChannel.enabled = true

        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register(action)
        manager.perform(identifier: "test", sender: self)
        XCTAssertTrue(action.performed)
    }

    static var allTests = [
        ("testBasics", testBasics),
    ]
}
