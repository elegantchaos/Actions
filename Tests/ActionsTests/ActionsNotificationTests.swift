// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions


final class ActionsNotificationTests: XCTestCase {
    class TestAction: Action {
    }
    
    func testBasics() {
        var notified: ActionNotificationStage? = nil
        
        let manager = ActionManager()
        manager.register([TestAction(identifier: "Test")])
        let info = ActionInfo()
        info.register(for: "TestEvent") { (stage, context) in
            notified = stage
            print("notified \(stage)")
        }

        let context = ActionContext(manager: manager, sender: manager, identifier: "Test", info: info)

        context.notify(for: "TestEvent", stage: .willPerform)
        XCTAssertEqual(notified, .willPerform)

        context.notify(for: "TestEvent", stage: .didPerform)
        XCTAssertEqual(notified, .didPerform)
    }
    
    func testNoDuplication() {
    }
}
