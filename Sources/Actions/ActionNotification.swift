// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Stage we're at.
 Notifications get sent before and after the actions are performed.
 */

public enum ActionNotificationStage {
    case willPerform
    case didPerform
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
