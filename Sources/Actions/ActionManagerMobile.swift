// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)

import UIKit

@objc protocol ActionID {
    @objc var actionID: String { get set }
}

public class ActionManagerMobile: ActionManager {
    public typealias OSResponder = UIResponder

    public class ActionManagerAdapter: UIResponder {
        weak var manager: ActionManager! = nil
        
//        /**
//         Validate an action to see if it should be enabled.
//         We follow essentially the same path as when performing the action,
//         building up a context first, but then call `validate` instead of `perform`.
//
//         Typically an action just needs to check the context for the presence of
//         keys in order to decide whether it's valid.
//
//         */
//
//        public func validateUserInterfaceItem(_ item: UIControl) -> Bool {
//
//            if item.action == #selector(performAction(_:)) {
//                return manager.validateUI(item)
//            }
//
//            return true
//        }
        
        /**
         Perform an action sent by a user interface item.
         We attempt to extract the identifier from the item, and use that as the action to perform.
         */
        
        @IBAction func performAction(_ sender: Any) {
            manager.perform(sender)
        }
        
        /**
         Return the selector that items should set as their action in order to trigger actions.
         
         Useful for code in client modules that wants to set up UI items programmatically.
         */
        
        public static var performActionSelector: Selector { get { return #selector(performAction(_:)) } }
        
    }

    public let adapter = ActionManagerAdapter()
    
    func firstResponder() -> OSResponder? {
        return UIApplication.shared.target(forAction: ActionManagerAdapter.performActionSelector, withSender: self) as? OSResponder
    }
    
    func alternateResponder() -> OSResponder? {
        return nil
    }
    
    func next(for responder: OSResponder?) -> OSResponder? {
        return responder?.next
    }

    override func applicationProvider() -> ActionContextProvider? {
        return UIApplication.shared.delegate as? ActionContextProvider
    }

    override func identifier(from item: Any) -> String? {
        if let identifier = (item as? ActionID)?.actionID {
            return identifier
        } else {
            return nil
        }
    }
    
    public func install() {
        adapter.manager = self
    }
}

private var actionIDKey: UInt8 = 0

extension ActionID {
    
    
    func retrieveID() -> String {
        let value = objc_getAssociatedObject(self, &actionIDKey)
        guard let result = value as? String else {
            return ""
        }
        return result
    }
    
    func storeID(_ value: String) {
        objc_setAssociatedObject(self, &actionIDKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
    }
}
extension UIView: ActionID {
    @objc var actionID: String {
        get { return retrieveID() }
        set(value) { storeID(value) }
    }
}

extension UIBarItem: ActionID {
    @objc var actionID: String {
        get { return retrieveID() }
        set(value) { storeID(value) }
    }
}

#endif
