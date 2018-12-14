// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 22/11/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public class ActionInfo {
    private var values: [String:Any] = [:]
    
    public init(sender: Any? = nil) {
        if sender != nil {
            values[ActionContext.senderKey] = sender
        }
    }
    
    public subscript(key: String) -> Any? {
        get { return values[key] }
        set (value) { values[key] = value }
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

class GenericHashable : Hashable {
    let item: AnyHashable
    
    init(_ item: AnyHashable) {
        self.item = item
    }

    static func == (lhs: GenericHashable, rhs: GenericHashable) -> Bool {
        guard type(of: lhs) == type(of: rhs) else {
            return false
        }
        
        return lhs.item == rhs.item
    }
    
    func hash(into hasher: inout Hasher) {
        item.hash(into: &hasher)
    }
}

//class GenericSet<T: AnyHashable> {
//    var set = Set<GenericHashable>()
////    func insert(_ item: T) {
//////        set.insert(GenericHashable(item))
////    }
//    func iterate() {
//        for item in set {
//            print(item.item)
//        }
//    }
//}
//
//extension GenericSet {
//    func insert<I>(_ item: I) where I: Hashable, I: T {
//        set.insert(GenericHashable(item))
//    }
//}

//protocol MyProtocol {
//    func doStuff()
//}
//
//protocol MyProtocolHashable: MyProtocol, Hashable {
//    
//}
//
//struct Test1: MyProtocolHashable {
//    let name: String
//    func doStuff() { print(name) }
//}
//
//struct Test2: MyProtocolHashable {
//    let age: Int
//    func doStuff() { print(age) }
//}
//
//func test() {
//    var set = GenericSet<MyProtocolHashable>()
//    set.insert(Test1(name: "Arthur"))
//    set.insert(Test2(age: 42))
//    
//    for item in set {
//        print(item.item)
//    }
//}

extension ActionInfo {
    
    /**
     Treat the given context info key as a set of observers, and insert a value into it.
     
     If the info didn't have a previous entry for the key, we create a single-item
     set containing the value. If the info already contains a set entry, we add the
     value to it.
     */
    
    public func addObserver<T>(_ value: T, key: String = ActionContext.observerKey) where T: ActionObserver, T: Hashable {
        var observers: Set<GenericHashable>
        if let items = values[key] as? Set<GenericHashable> {
            observers = items
        } else {
            observers = Set<GenericHashable>()
        }
        observers.insert(GenericHashable(value))
        values[key] = observers
    }
    
    /**
     Treat the given context info key as an observer set, and enumerate it performing an action.
     
     Does nothing if the key is missing or didn't contain a list.
     */
    
    public func forObservers<T>(key: String = ActionContext.observerKey, action: (T) throws -> Void) {
        if let items = values[key] as? Set<GenericHashable> {
            for item in items {
                if let observer = item.item as? T {
                    try? action(observer)
                }
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


/**
 Debugging support.
 */

extension ActionInfo: CustomStringConvertible {
    public var description: String {
        return values.keys.joined(separator:",")
    }
}
