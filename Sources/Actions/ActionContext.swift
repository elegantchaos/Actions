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
    
    @available(*, deprecated, message: "Use arguments added to the identifier, instead of parameters.")
    public var parameters: [String]
    
    /**
     Additional information set by the context providers.
     */
    
    public var info: ActionInfo
    
    // Some standard info keys, provided for convenience.
    public static let actionKey = "action"
    public static let actionComponentsKey = "components"
    public static let documentKey = "document"
    public static let infoKey = "info"
    public static let modelKey = "model"
    public static let notificationKey = "notification"
    public static let observerKey = "observer"
    public static let rootKey = "root"
    public static let selectionKey = "selection"
    public static let senderKey = "sender"
    public static let skipValidationKey = "skipValidation"
    public static let targetKey = "target"
    public static let viewModelKey = "viewModel"
    public static let windowKey = "window"
    
    /**
     Create a context for a given action, id, parameters and info.
     */
    
    init(manager: ActionManager, action: Action, identifier: String, parameters: [String] = [], info: ActionInfo = ActionInfo()) {
        self.manager = manager
        self.action = action
        self.identifier = identifier
        self.parameters = parameters
        self.info = info
    }
    
    /**
     Support subscripting directly into the info, by subscripting the context.
    */
    
    public subscript(key: String) -> Any? {
        get { return info[key] }
        set (value) { info[key] = value }
    }
    
    /**
     The sender can be stored in the info, but if it's not, then we
     treat the action manager itself as the sender.
    */
    
    public var sender: Any {
        get { return info[ActionContext.senderKey] ?? manager }        
    }
    
    /**
     Look up a key in the info and treat it as a boolean flag.
    */
    
    public func flag(key: String) -> Bool {
        return info.flag(key:key)
    }
    
}

/**
 Serialization support.
 */

extension ActionContext: ActionSerialization {
    /**
     Return a dictionary representation of the context.
     This is intended to contain enough information to allow the action
     invocation be recreated at a later date - thus it should contain
     the action id, and any arguments and parameters.
     */

    public var serializedDictionary: [String:Any] {
        return [
            ActionContext.actionKey: action.identifier,
            ActionContext.infoKey: info.serialized
        ]
    }
    
    public var serialized: Any {
        return serializedDictionary
    }
}

/**
 Notification support.
 */

extension ActionContext {
    /**
     Send a notification to all handlers that match the action.
    
     We fetch the handlers to run from the action info (under the `notificationKey` key
     by default, but a different key can be used).
     
     We also send the notification to additional handlers that are passed in.
     
     Does nothing if the fetched and global handler lists are missing or empty.
     */
    
    func notify(stage: ActionNotificationStage, global: [ActionNotification] = [], key: String = ActionContext.notificationKey) {
        let action = self.action
        let handler = { (notification: ActionNotification) in
            if (notification.action == "") || (notification.action == action.identifier) {
                notification.callback(stage, self)
            }
        }
        
        global.forEach(handler)
        info.forEach(key: key, action: handler)
    }
    
    
}

/**
 Debugging support.
 */

extension ActionContext: CustomStringConvertible {
    public var description: String {
        let params = parameters.count == 0 ? "" : " parameters:\(parameters)"
        return "«context \(action)\(params) keys: \(info)»"
    }
}
