// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)

import UIKit

public class ActionManagerMobile: ActionManager {
    public class Responder: UIResponder {
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

    public let responder = Responder()
    
    override func responderChains() -> [ActionResponder] {
        guard let chain = UIApplication.shared.target(forAction: Responder.performActionSelector, withSender: self) as? ActionResponder else {
            return []
        }

        return [chain]
    }

    override func providers() -> [ActionContextProvider] {
        var result = super.providers()
        if let provider = UIApplication.shared.delegate as? ActionContextProvider {
            result.append(provider)
        }
        return result
    }
    
    public func installResponder() {
        responder.manager = self
    }
}



extension UIView: ActionIdentification {
    @objc var actionID: String {
        get { return retrieveID() }
        set(value) { storeID(value) }
    }
}

extension UIBarItem: ActionIdentification {
    @objc var actionID: String {
        get { return retrieveID() }
        set(value) { storeID(value) }
    }
}

#endif
