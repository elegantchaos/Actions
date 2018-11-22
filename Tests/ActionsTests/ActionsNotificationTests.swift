// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions


final class ActionsNotificationTests: XCTestCase {
    class TestAction: Action {
    }
    
    func testRegistrationForSpecificAction() {
        var notified: ActionNotificationStage? = nil
        
        let manager = ActionManager()
        let info = ActionInfo()
        info.registerNotification(for: "TestAction") { (stage, context) in
            notified = stage
        }

        let context = ActionContext(manager: manager, sender: manager, identifier: "Test", info: info)

        // should get notified
        context.notify(for: "TestAction", stage: .willPerform)
        XCTAssertEqual(notified, .willPerform)

        // stage should have changed
        context.notify(for: "TestAction", stage: .didPerform)
        XCTAssertEqual(notified, .didPerform)
        
        // notifying about another action should have no effect
        notified = nil
        context.notify(for: "AnotherAction", stage: .willPerform)
        XCTAssertEqual(notified, nil)
    }
    
    
    func testRegistrationForAnyAction() {
        var notified: ActionNotificationStage? = nil
        
        let manager = ActionManager()
        let info = ActionInfo()
        info.registerNotification() { (stage, context) in
            notified = stage
        }
        
        let context = ActionContext(manager: manager, sender: manager, identifier: "Test", info: info)

        // should get notified
        context.notify(for: "TestAction", stage: .willPerform)
        XCTAssertEqual(notified, .willPerform)
        
        // should get notified for any action
        context.notify(for: "AnotherAction", stage: .didPerform)
        XCTAssertEqual(notified, .didPerform)
    }
    
    func testRegistrationSending() {
        var notified: ActionNotificationStage? = nil
        
        let manager = ActionManager()
        manager.register([Action(identifier: "TestAction")])

        let info = ActionInfo()
        info.registerNotification(for: "TestAction") { (stage, context) in
            notified = stage
        }
        
        // should get notified
        manager.perform(identifier: "TestAction", sender: self, info: info)
        XCTAssertEqual(notified, .didPerform)
    }
}
