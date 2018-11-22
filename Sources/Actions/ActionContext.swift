// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Something that can provide contextual information for use by actions.
 
 Before an action is validated or performed, the action manager will
 locate any providers in the current context (eg by searching the responder chain),
 and allow them to provide information.
 
 The action can then read this context to decide whether it is valid,
 and/or how it should perform.
 */

public protocol ActionContextProvider {
    func provide(context: ActionContext)
}

/**
 Records the context in which an action was invoked.
 */

public class ActionContext {
    
    /**
     The item that triggered the action.
     */
    
    public let sender: Any
    
    /**
     The action manager handling the action.
     */
    public let manager: ActionManager
    
    /**
    The action being invoked.
    */
    
    public let action: Action
    
    /**
     The full identifier that triggered the action.
     Note that this is a full unparsed identifier which may contain prefixes and parameters.
     It may be different from action.identifier.
     */
    
    public let identifier: String
    
    /**
     Any unused components of the identifier that triggered the action.
     */
    
    public var parameters: [String]
    
    /**
     Additional information set by the context providers.
     */
    
    public var info: ActionInfo
    
    // Some standard info keys, provided for convenience.
    public static let actionKey = "action"
    public static let actionComponentsKey = "components"
    public static let documentKey = "document"
    public static let modelKey = "model"
    public static let notificationKey = "notification"
    public static let observerKey = "observer"
    public static let rootKey = "root"
    public static let selectionKey = "selection"
    public static let senderKey = "sender"
    public static let targetKey = "target"
    public static let viewModelKey = "viewModel"
    public static let windowKey = "window"
    
    /**
     Create a context for a given sender and parameters.
     */
    
    init(manager: ActionManager, action: Action, sender: Any, identifier: String, parameters: [String] = [], info: ActionInfo = ActionInfo()) {
        self.manager = manager
        self.action = action
        self.sender = sender
        self.identifier = identifier
        self.parameters = parameters
        self.info = info
    }
    
    
}

/**
 Notification support.
 */

extension ActionContext {
    /**
     Treat the given context info key as an observer set, and enumerate it performing an action.
     
     Does nothing if the key is missing or didn't contain a list.
     */
    
    public func notify(stage: ActionNotificationStage, key: String = ActionContext.notificationKey) {
        info.forEach(key: key) { (notification: ActionNotification) in
            if (notification.action == "") || (notification.action == action.identifier) {
                notification.callback(stage, self)
            }
        }
    }
    
    
}
