// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class ActionInfo {
    private var values: [String:Any] = [:]
    
    public init() {
    }
    
    public func get(_ key: String) -> Any? {
        return values[key]
    }
    
    public func set(_ key: String, value: Any) {
        values[key] = value
    }
    
    /**
     Treat the given context info key as a list, and append a value to it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     list containing the value.
     If the info already contains a list entry, we append the value to it.
     */
    
    public func append(key: String, value: Any) {
        var list: [Any]
        if let items = values[key] as? [Any] {
            list = items
            list.append(value)
        } else {
            list = [value]
        }
        
        values[key] = list
    }
    
    
    /**
     Treat the given context info key as a list, and enumerate it performing an action.
     
     Does nothing if the key is missing or didn't contain a list.
     */
    
    public func forEach<T>(key: String, action: (T) throws -> Void) {
        if let items = values[key] as? [T] {
            try? items.forEach(action)
        }
    }
}

/**
 Observer support.
 */

public protocol ActionObserver {
}

extension ActionInfo {
    
    /**
     Treat the given context info key as a set of observers, and insert a value into it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     set containing the value. If the info already contains a set entry, we add the
     value to it.
     */
    
    public func addObserver<T>(_ value: T, key: String = ActionContext.observerKey) where T: Hashable, T: ActionObserver {
        var observers: Set<T>
        if let items = values[key] as? Set<T> {
            observers = items
            observers.insert(value)
        } else {
            observers = Set<T>([value])
        }
        
        values[key] = observers
    }
    
    /**
     Treat the given context info key as an observer set, and enumerate it performing an action.
     
     Does nothing if the key is missing or didn't contain a list.
     */
    
    public func forObservers<T>(key: String = ActionContext.observerKey, action: (T) throws -> Void) {
        if let items = values[key] as? Set<AnyHashable> {
            for item in items {
                try? action(item as! T)
            }
        }
    }
    
}

/**
 Notification support.
 */

public enum ActionNotificationStage {
    case willPerform
    case didPerform
}

public typealias ActionNotificationCallback = (_ stage: ActionNotificationStage, _ context: ActionContext) -> Void

struct ActionNotification {
    let action: String
    let callback: ActionNotificationCallback
}


extension ActionInfo {
    
    /**
     Treat the given context info key as a set of observers, and insert a value into it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     set containing the value. If the info already contains a set entry, we add the
     value to it.
     */
    
    public func registerNotification(for action: String = "", key: String = ActionContext.notificationKey, notification: @escaping ActionNotificationCallback) {
        let notification = ActionNotification(action: action, callback: notification)
        append(key: key, value: notification)
    }
    
}
