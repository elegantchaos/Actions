// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(iOS)

import UIKit

public class ActionManagerMobile: ActionManager {
    public class Responder: UIResponder {
        weak var manager: ActionManager! = nil
        
        /**
         Perform an action sent by a user interface item.
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

    /**
     Embedded support for the responder chain.
    */
    
    public let responder = Responder()

    func firstResponder(for view: UIViewController) -> ActionResponder? {
        print(view)
        if view.isFirstResponder {
            return responder
        }

        for subview in view.children {
            if let nav = subview as? UINavigationController {
                return nav.visibleViewController
            }
            
            if let responder = firstResponder(for: subview) {
                return responder
            }
        }
        
        return nil
    }
    
    func firstResponder() -> ActionResponder? {
        if let keyWindow = UIApplication.shared.keyWindow {
            if let view = keyWindow.screen.focusedView {
                return view
            }
            
            if let responder = firstResponder(for: keyWindow.rootViewController!) {
                return responder
            }
            
            if let view = keyWindow.rootViewController?.navigationController {
                return view
            }
            
            if let view = keyWindow.rootViewController {
                return view
            }
//
//            for view in keyWindow.subviews {
//                if view.isFirstResponder {
//                    return view
//                }
//            }
        }
        
        return nil
    }
    /**
     On iOS, we use the default responder chain.
     */

    override func responderChains(for item: Any) -> [ActionResponder] {
        var result = super.responderChains(for: item)

//        if let toolbarItem = item as? UIBarItem {
//            result.append(item.)
//        }
        if let chain = firstResponder() {
            result.append(chain)
        }
        
        return result
    }

    /**
     The application delegate may also be a context provider,
     so we add it to the default list if so.
     */

    override func providers(for item: Any) -> [ActionContextProvider] {
        var result = super.providers(for: item)
        if let provider = UIApplication.shared.delegate as? ActionContextProvider {
            result.append(provider)
        }
        return result
    }
    
    /**
     Hook the action manager into the responder chain.
     */

    public func installResponder() {
        responder.manager = self
    }
}


/**
 We want UIResponder to conform to ActionResponder, so
 that our generic code knows how to walk the iOS
 responder chain.
 */

extension UIResponder: ActionResponder {
    func next() -> ActionResponder? {
        return next
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
