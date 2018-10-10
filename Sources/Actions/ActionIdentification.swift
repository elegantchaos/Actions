// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

@objc public protocol ActionIdentification {
    @objc var actionID: String { get set }
}

private var actionIDKey: UInt8 = 0

extension ActionIdentification {
    
    public func retrieveID() -> String {
        let value = objc_getAssociatedObject(self, &actionIDKey)
        guard let result = value as? String else {
            return ""
        }
        return result
    }
    
    public func storeID(_ value: String) {
        objc_setAssociatedObject(self, &actionIDKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
    }
}
