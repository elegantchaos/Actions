// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class ActionInfo {
    private var values: [ActionKey:Any] = [:]
    
    public init(sender: Any? = nil) {
        if sender != nil {
            values[.sender] = sender
        }
    }
    
    public subscript(key: ActionKey) -> Any? {
        get { return values[key] }
        set (value) { values[key] = value }
    }
    
    
    /**
     Look up a key and treat it as a boolean flag.
     */
    
    public func flag(key: ActionKey) -> Bool {
        if let value = values[key] {
            if let bool = value as? Bool {
                return bool
            }
            
            if let number = value as? NSNumber {
                return number.boolValue
            }
            
            if let string = value as? NSString {
                return string.boolValue
            }
        }
        
        return false
    }

    /**
     Treat the given context info key as a list, and append a value to it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     list containing the value.
     If the info already contains a list entry, we append the value to it.
     */
    
    public func append(key: ActionKey, value: Any) {
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
    
    public func forEach<T>(key: ActionKey, action: (T) throws -> Void) {
        if let items = values[key] as? [T] {
            try? items.forEach(action)
        }
    }


}

/**
 Serialization support.
 */

extension ActionInfo: ActionSerialization {
    /**
     Return a dictionary representation of the info.
     This is intended to contain enough information to allow the action
     invocation be recreated at a later date - thus it should contain
     the action id, and any arguments and parameters.
     */
    
    public var serialized: Any {
        return values.serialized
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
    
    public func addObserver<T>(_ value: T, key: ActionKey = .observer) where T: ActionObserver, T: Hashable {
        var observers: Set<AnyHashable>
        if let items = values[key] as? Set<AnyHashable> {
            observers = items
        } else {
            observers = Set<AnyHashable>()
        }
        observers.insert(AnyHashable(value))
        values[key] = observers
    }
    
    /**
     Treat the given context info key as an observer set, and enumerate it performing an action.
     
     Does nothing if the key is missing or didn't contain a list.
     */
    
    public func forObservers<T>(key: ActionKey = .observer, action: (T) throws -> Void) {
        if let items = values[key] as? Set<AnyHashable> {
            for item in items {
                if let observer = item as? T {
                    try? action(observer)
                }
            }
        }
    }
    
}

/**
 Notification support.
 */

extension ActionInfo {
    
    /**
     Treat the given context info key as a set of observers, and insert a value into it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     set containing the value. If the info already contains a set entry, we add the
     value to it.
     */
    
    public func registerNotification(for action: String = "", key: ActionKey = .notification, notification: @escaping ActionNotificationCallback) {
        let notification = ActionNotification(action: action, callback: notification)
        append(key: key, value: notification)
    }
    
}


/**
 Debugging support.
 */

extension ActionInfo: CustomStringConvertible {
    public var description: String {
        return values.keys.map({ $0.value }).joined(separator:",")
    }
}

/**
 URL support.
 */

extension ActionInfo {
    
    /**
     URLs can be represented in the context as strings or URL objects, so we
     support automatically coercing the strings.
    */
    
    func url(withKey key: ActionKey) -> URL? {
        let value = values[key]
        if let url = value as? URL {
            return url
        } else if let string = value as? String {
            return URL(fileURLWithPath: string)
        }
        return nil
    }
}
