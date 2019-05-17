
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
import AppKit
import Actions
import Logger

let validationChannel = Logger("com.elegantchaos.actions.Validation")

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
                let validation = manager.validate(item)
                
                if let menu = item as? NSMenuItem {
                    menu.isHidden = !validation.visible
                    if let name = validation.name {
                        menu.title = name
                    }
                }
                
                return validation.enabled
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
    
    public override func responderChains(for item: Any) -> [ActionResponder] {
        let app = NSApplication.shared
        let keyWindow = app.keyWindow
        let mainWindow = app.mainWindow
        var responders = super.responderChains(for: item)
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
    
    public override func providers(for item: Any) -> [ActionContextProvider] {
        var result = super.providers(for: item)
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
    
    /**
     Update all validatable user interface items inside the view.
    */
    
    public func validateControls(of view: NSView) {
        var items = [NSControl]()
        view.appendValidatableControls(to: &items)
        for item in items {
            if let button = item as? NSButton, let identifier = item.identifier?.rawValue {
                let validation = validate(identifier: identifier, info: ActionInfo(sender: button))
                button.isEnabled = validation.enabled
                button.isHidden = !validation.visible
                if let name = (validation.shortName ?? validation.name) {
                    button.title = name
                }
            }
        }
    }
    
    /**
     Queue up the view for validation.
     Validation can take a while if there are a lot of items, so deferring it can make sense.
     */
    
    
    public func scheduleForValidation(view: NSView) {
        // TODO: a more sophisticated approach would be to manage a set of items to be validated, then process that set
        //       this would avoid the situation where a view and one of its sub-views are both scheduled for validation,
        //       causing the contents of the subview to be validated twice
        OperationQueue.main.addOperation {
            self.validateControls(of: view)
        }
    }

}

/**
 We want NSResponder to conform to ActionResponder, so
 that our generic code knows how to walk the Mac
 responder chain.
 */

extension NSResponder: ActionResponder {
    public func next() -> ActionResponder? {
        return nextResponder
    }
}

/**
 Views and controls use their identifier for the actionID.
 */

extension NSView: ActionIdentification {
    @objc public var actionID: String {
        get { return identifier?.rawValue ?? "" }
        set(value) { identifier = NSUserInterfaceItemIdentifier(rawValue: value) }
    }

    /**
     Iterate over the controls in the view (and any subviews), and append any
     that can be validated to the list we were passed.
    */
    
    public func appendValidatableControls(to items: inout [NSControl]) {
        let selector = ActionManagerMac.Responder.performActionSelector
        if !isHidden {
            if let viewItem = self as? NSControl, let identifier = viewItem.identifier?.rawValue {
                validationChannel.log("\(identifier)")
                if viewItem.action == selector {
                    items.append(viewItem)
                }
            }
            for subview in subviews {
                subview.appendValidatableControls(to: &items)
            }
        }
    }
    
}

/**
 Toolbar items use their itemIdentifier for the actionID.
 */

extension NSToolbarItem: ActionIdentification {
    @objc public var actionID: String {
        get { return itemIdentifier.rawValue }
        set(value) { fatalError("can't change toolbar item action id") }
    }
}

extension NSMenuItem: ActionIdentification {
    @objc public var actionID: String {
        get { return identifier?.rawValue ?? "" }
        set(value) { identifier = NSUserInterfaceItemIdentifier(rawValue: value) }
    }
}

#endif
