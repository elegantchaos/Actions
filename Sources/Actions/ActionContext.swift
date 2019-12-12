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

public protocol ActionContextProvider: AnyObject {
    func provide(context: ActionContext)
    func identicalTo(other: ActionContextProvider) -> Bool  // TODO: it would be better if we could require conformance to Equatable/Hashable here
}

public extension ActionContextProvider {
    func identicalTo(other: ActionContextProvider) -> Bool {
        return self === other
    }
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
     Additional information set by the context providers.
     */
    
    public var info: ActionInfo

    /**
     Create a context for a given action, id, parameters and info.
     */
    
    init(manager: ActionManager, action: Action, identifier: String, parameters: [String] = [], info: ActionInfo = ActionInfo()) {
        self.manager = manager
        self.action = action
        self.identifier = identifier
        self.info = info
    }
    
    /**
     Support subscripting directly into the info, by subscripting the context.
    */
    
    public subscript(key: ActionKey) -> Any? {
        get { return info[key] }
        set (value) { info[key] = value }
    }
    
    /**
     The sender can be stored in the info, but if it's not, then we
     treat the action manager itself as the sender.
    */
    
    public var sender: Any {
        get { return info[.sender] ?? manager }
    }
    
    /**
     Look up a key in the info and treat it as a boolean flag.
    */
    
    public func flag(key: ActionKey) -> Bool {
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
            ActionKey.action.value: action.identifier,
            ActionKey.info.value: info.serialized
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
    
    func notify(stage: ActionNotificationStage, global: [ActionNotification] = [], key: ActionKey = .notification) {
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
        return "«context \(action) keys: \(info)»"
    }
}

/**
 URL support.
 */

public extension ActionContext {
    
    /**
     URLs can be represented in the context as strings or URL objects, so we
     support automatically coercing the strings.
     */
    
    func url(withKey key: ActionKey) -> URL? {
        return info.url(withKey: key)
    }
}
