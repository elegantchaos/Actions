// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Objects conforming to this protocol can be converted a key/value format suitable
 for serialization as JSON/XML/whatever.
 
 We can use this ability to record actions, by serializing ActionContext instances.
 */

public protocol ActionSerialization {
    var serialized: Any { get }
}

extension Int: ActionSerialization {
    public var serialized: Any { return self }
}

extension Double: ActionSerialization {
    public var serialized: Any { return self }
}

extension String: ActionSerialization {
    public var serialized: Any { return self }
}

extension NSString: ActionSerialization {
    public var serialized: Any { return self as String }
}

extension Dictionary: ActionSerialization {
    public var serialized: Any {
        var valid: [Key:Any] = [:]
        for (key,value) in self {
            if let object = value as? ActionSerialization {
                valid[key] = object.serialized
            }
        }
        return valid
    }
}

extension Array: ActionSerialization {
    public var serialized: Any {
        var valid: [Any] = []
        for value in self {
            if let object = value as? ActionSerialization {
                valid.append(object.serialized)
            }
        }
        return valid
    }
}

extension Optional: ActionSerialization where Wrapped: ActionSerialization {
    public var serialized: Any {
        switch self {
        case .some(let value):
            return value.serialized
        default:
            return ""
        }
    }
}
