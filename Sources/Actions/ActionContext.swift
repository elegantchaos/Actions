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
    public typealias Info = [String:Any]
    
    /**
    The item that triggered the action.
 */
    
    public let sender: Any
    
    /**
    The action manager handling the action.
 */
    public let manager: ActionManager
    
    /**
    Any unused components of the identifier that triggered the action.
 */
    
    public var parameters: [String]
    
    /**
 Additional information set by the context providers.
 */
    
    public var info: Info

    // Some standard info keys, provided for convenience.
    public static let actionKey = "action"
    public static let actionComponentsKey = "components"
    public static let modelKey = "model"
    public static let observerKey = "observer"
    public static let selectionKey = "selection"
    public static let senderKey = "sender"
    public static let targetKey = "target"
    public static let viewModelKey = "viewModel"
    public static let windowKey = "window"
    
    /**
     Create a context for a given sender and parameters.
     */
    
    init(manager: ActionManager, sender: Any, parameters: [String] = [], info: Info = [:]) {
        self.manager = manager
        self.sender = sender
        self.parameters = parameters
        self.info = info
    }
    
    /**
     Treat the given context info key as a list, and append a value to it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     list containing the value.
     If the info already contains a list entry, we append the value to it.
     */
    
    public func append(key: String, value: Any) {
        var list: [Any]
        if let items = info[key] as? [Any] {
            list = items
            list.append(value)
        } else {
            list = [value]
        }
        
        info[key] = list
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

/**
 Observer support.
 */

public protocol ActionObserver {
}

extension ActionContext {
    
    /**
     Treat the given context info key as a set of observers, and insert a value into it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     set containing the value. If the info already contains a set entry, we add the
     value to it.
     */
    
    public func addObserver<T>(_ value: T, key: String = ActionContext.observerKey) where T: Hashable, T: ActionObserver {
        var observers: Set<T>
        if let items = info[key] as? Set<T> {
            observers = items
            observers.insert(value)
        } else {
            observers = Set<T>([value])
        }
        
        info[key] = observers
    }

    /**
     Treat the given context info key as an observer set, and enumerate it performing an action.
     
     Does nothing if the key is missing or didn't contain a list.
     */
    
    public func forObservers<T>(key: String = ActionContext.observerKey, action: (T) throws -> Void) {
        if let items = info[key] as? Set<AnyHashable> {
            for item in items {
                try? action(item as! T)
            }
        }
    }

}
