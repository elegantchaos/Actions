
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
import AppKit

public class ActionManagerMac: ActionManager {
    
    /**
     Proxy object which stands in for the action manager in the responder chain.
    */
    
    public class Responder: NSResponder, NSUserInterfaceValidations {
        weak var manager: ActionManager! = nil
        
        /**
         Validate an action to see if it should be enabled.
         We follow essentially the same path as when performing the action,
         building up a context first, but then call `validate` instead of `perform`.
         
         Typically an action just needs to check the context for the presence of
         keys in order to decide whether it's valid.
         
         */
        
        public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
            if item.action == #selector(performAction(_:)) {
                return manager.validate(item)
            }
            
            return true
        }
        
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

    /**
     On the Mac, we want to look for providers in the key window's responder chain,
     and also the main window (if it's different).
     */
    
    override func responderChains() -> [ActionResponder] {
        let app = NSApplication.shared
        let keyWindow = app.keyWindow
        let mainWindow = app.mainWindow
        var responders = [ActionResponder]()
        if let responder = keyWindow?.firstResponder {
            responders.append(responder)
        }
        if keyWindow != mainWindow, let responder = mainWindow?.firstResponder {
            responders.append(responder)
        }
        
        return responders
    }
    
    /**
     The application delegate may also be a context provider,
     so we add it to the default list if so.

     We attempt to follow the same path that the system would:
     - the key window, from first responder to root
     - the main window (if different), from first responder to root
     - the app delegate
    */
    
    override func providers() -> [ActionContextProvider] {
        var result = super.providers()
        if let provider = NSApplication.shared.delegate as? ActionContextProvider {
            result.append(provider)
        }
        
        return result
    }
    
    /**
     Hook the action manager into the responder chain.
     */
    
    public func installResponder() {
        responder.manager = self
        responder.nextResponder = NSApp.nextResponder
        NSApp.nextResponder = responder
    }
}

/**
 We want NSResponder to conform to ActionResponder, so
 that our generic code knows how to walk the Mac
 responder chain.
 */

extension NSResponder: ActionResponder {
    func next() -> ActionResponder? {
        return nextResponder
    }
}

/**
 Views and controls use their identifier for the actionID.
 */

extension NSView: ActionIdentification {
    @objc var actionID: String {
        get { return identifier?.rawValue ?? "" }
        set(value) { identifier = NSUserInterfaceItemIdentifier(rawValue: value) }
    }
}

/**
 Toolbar items use their itemIdentifier for the actionID.
 */

extension NSToolbarItem: ActionIdentification {
    @objc var actionID: String {
        get { return itemIdentifier.rawValue }
        set(value) { fatalError("can't change toolbar item action id") }
    }
}

#endif
