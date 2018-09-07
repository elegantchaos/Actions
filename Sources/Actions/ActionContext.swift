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
    Any unused components of the identifier that triggered the action.
 */
    
    public var parameters: [String]
    
    /**
 Additional information set by the context providers.
 */
    
    public var info = [String:Any]()

    // Some standard info keys, provided for convenience.
    public static let selectionKey = "selection"
    public static let targetKey = "target"
    public static let senderKey = "sender"
    public static let actionKey = "action"
    public static let actionComponentsKey = "components"
    public static let modelKey = "model"
    
    /**
     Create a context for a given sender and parameters.
     */
    
    init(sender: Any, parameters: [String]) {
        self.sender = sender
        self.parameters = parameters
    }
    
    /**
     Treat the given context info key as a list, and append a value to it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     list containing the value.
     If the info already contains a list entry, we append the value to it.
     */
    
    public func append(key: String, value: Any) {
        if var items = info[key] as? [Any] {
            items.append(value)
        } else {
            info[key] = [value]
        }
    }
    
    /**
     Treat the given context info key as a list, and enumerate it performing an action.
     
     Does nothing if the key is missing or didn't contain a list.
     */
    
    public func forEach<T>(key: String, action: (T) throws -> Void) {
        if let items = info[key] as? [T] {
            try? items.forEach(action)
        }
    }
}
