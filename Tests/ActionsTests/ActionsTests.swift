// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions

final class ActionsTests: XCTestCase {
    class TestAction: Action {
        var performed = false
        var performedContext: ActionContext?
        
        override func perform(context: ActionContext) {
            performed = true
            performedContext = context
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

    func testArguments() {
        actionChannel.enabled = true
        
        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "test.param1.param2", sender: self)
        XCTAssertEqual(action.performedContext!.parameters.count, 2)
        XCTAssertEqual(action.performedContext!.parameters[0], "param1")
        XCTAssertEqual(action.performedContext!.parameters[1], "param2")
    }

    func testPrefix() {
        actionChannel.enabled = true
        
        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "prefix.test", sender: self)
        XCTAssertTrue(action.performed)
    }
    
    static var allTests = [
        ("testBasics", testBasics),
        ("testArguments", testArguments),
        ("testPrefix", testPrefix),
    ]
}
