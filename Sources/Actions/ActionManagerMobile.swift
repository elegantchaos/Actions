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

    
    func topResponder(for view: UIViewController) -> ActionResponder? {
        if let nav = view as? UINavigationController, let visible = nav.visibleViewController {
            if let sub = topResponder(for: visible) {
                return sub
            }
            
            return visible
        }
        
        for subview in view.children {
            if let top = topResponder(for: subview) {
                return top
            }
        }
        
        return nil
    }
    
    func topResponder() -> ActionResponder? {
        
        return nil
    }

    /**
     On iOS, we use the default responder chain.
     */

    override func responderChains(for item: Any) -> [ActionResponder] {
        var result = super.responderChains(for: item)
        
        // if there's a first responder set (eg text is being edited)
        // include its responder chain
        if let responder = UIResponder.currentFirstResponder {
            result.append(responder)
        }

        // if there's a navigation controller showing something,
        // include its chain
        if let keyWindow = UIApplication.shared.keyWindow, let root = keyWindow.rootViewController {
            if let top = topResponder(for: root) {
                result.append(top)
            }
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

extension UIResponder {
    
    private static weak var _currentFirstResponder: UIResponder?
    
    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        
        return _currentFirstResponder
    }
    
    @objc func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
#endif
