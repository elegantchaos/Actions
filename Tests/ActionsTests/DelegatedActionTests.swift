// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 25/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions

final class DelegatedActionTests: XCTestCase {
    enum Performed {
        case nothing
        case action1
        case action2
    }
    
    var performed: Performed = .nothing
    var manager: ActionManager!
    
    override func setUp() {
        let action1 = TestAction(identifier: "test1", perform: .action1, test:self)
        let action2 = TestAction(identifier: "test2", perform: .action2, test:self)
        manager = ActionManager()
        manager.register([action1, action2])
        actionChannel.enabled = true
        XCTAssertTrue(performed == .nothing)
    }
    
    class TestAction: Action {
        let test: DelegatedActionTests
        let perform: Performed
        
        init(identifier: String, perform: Performed, test: DelegatedActionTests) {
            self.test = test
            self.perform = perform
            super.init(identifier: identifier)
        }
        
        override func perform(context: ActionContext) {
            test.performed = perform
        }
    }

    func testAction1() {
        manager.perform(identifier: "test1", sender: self)
        XCTAssertTrue(performed == .action1)
    }

    func testAction2() {
        manager.perform(identifier: "test2", sender: self)
        XCTAssertTrue(performed == .action2)
    }

    func testDelegated() {
        let delegated = DelegatedAction(identifier: "delegated") { (context) in
            return "test1"
        }
        manager.register([delegated])
        manager.perform(identifier: "delegated", sender: self)
        XCTAssertTrue(performed == .action1)
    }
    
    static var allTests = [
        ("testAction1", testAction1),
        ("testAction2", testAction2),
        ]
}