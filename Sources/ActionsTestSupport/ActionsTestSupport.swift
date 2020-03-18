// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/12/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
import Actions

open class ActionsTestCase: XCTestCase {
    public var manager = ActionManager()
    public var expectation: XCTestExpectation!
    fileprivate var notificationTarget = 0
    public var notifications: [ActionNotificationStage] = []
    
    open override func setUp() {
        actionChannel.enabled = true
        expectation = expectation(description: "completed")
        manager.registerNotification() { stage, context in self.notified(stage: stage) }
    }
    
    open func notified(stage: ActionNotificationStage) {
        notifications.append(stage)
        switch stage {
            case .didPerform, .didFail:
                if notifications.count == notificationTarget {
                    expectation.fulfill()
                }
            default:
            break
        }
    }
    
    open func performAndWaitFor(action identifier: String, notifications: Int = 1) {
        notificationTarget = notifications * 2 // there will always be two notifications per action: a willPerform and a didPerform/didFail
        manager.perform(identifier: identifier)
        wait(for: [expectation], timeout: 1.0)
    }
}
