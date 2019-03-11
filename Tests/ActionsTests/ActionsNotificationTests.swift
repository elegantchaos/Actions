// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions


final class ActionsNotificationTests: XCTestCase {
    let manager = ActionManager()
    let action = Action(identifier: "TestAction")
    
    func testRegistrationForSpecificAction() {
        var notified: ActionNotificationStage? = nil
        
        let info = ActionInfo()
        info.registerNotification(for: "TestAction") { (stage, context) in
            notified = stage
        }

        let context = ActionContext(manager: manager, action: action, identifier: "Test", info: info)

        // should get notified
        context.notify(stage: .willPerform)
        XCTAssertEqual(notified, .willPerform)

        // stage should have changed
        context.notify(stage: .didPerform)
        XCTAssertEqual(notified, .didPerform)
        
        // notifying about another action should have no effect
        let otherContext = ActionContext(manager: manager, action: Action(identifier: "OtherAction"), identifier: "Test", info: info)
        notified = nil
        otherContext.notify(stage: .willPerform)
        XCTAssertEqual(notified, nil)
    }
    
    
    func testRegistrationForAnyAction() {
        var notified: ActionNotificationStage? = nil
        
        let info = ActionInfo()
        info.registerNotification() { (stage, context) in
            notified = stage
        }
        
        let context = ActionContext(manager: manager, action: action, identifier: "Test", info: info)

        // should get notified
        context.notify(stage: .willPerform)
        XCTAssertEqual(notified, .willPerform)
        
        // should get notified for any action
        context.notify(stage: .didPerform)
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
        manager.perform(identifier: "TestAction", info: info)
        XCTAssertEqual(notified, .didPerform)
    }
    
    func testGlobalNotifications() {
        var count = 0
        
        manager.registerNotification(for: "TestAction") { (stage, context) in
            count += 1
        }
        
        manager.register([Action(identifier: "TestAction")])
        manager.perform(identifier: "TestAction")
        XCTAssertEqual(count, 2)
    }
}
