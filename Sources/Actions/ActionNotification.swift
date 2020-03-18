// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Stage we're at.
 Notifications get sent before and after the actions are performed.
 */

public enum ActionNotificationStage: Equatable {
    public static func == (lhs: ActionNotificationStage, rhs: ActionNotificationStage) -> Bool {
        switch (lhs, rhs) {
            case (.willPerform, .willPerform):
                return true
            case (.didPerform, .didPerform):
                return true
            case (.didFail(let error1), .didFail(let error2)):
                return error1.localizedDescription == error2.localizedDescription
            default:
                return false
        }
    }
    
    case willPerform
    case didPerform
    case didFail(Error)
}

/**
 Notification callback. The context and stage are passed in.
 */

public typealias ActionNotificationCallback = (_ stage: ActionNotificationStage, _ context: ActionContext) -> Void

/**
 Notifications are checked against identifier of the action currently being performed.
 The callback is invoked for any that match.
 */

struct ActionNotification {
    let action: String
    let callback: ActionNotificationCallback
}
