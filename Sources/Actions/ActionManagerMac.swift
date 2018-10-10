
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
import AppKit

extension NSResponder: ActionResponder {
    func next() -> ActionResponder? {
        return nextResponder
    }
}

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

    override func firstResponder() -> ActionResponder? {
        return NSApplication.shared.keyWindow?.firstResponder
    }
    
    override func alternateResponder() -> ActionResponder? {
        let app = NSApplication.shared
        let keyWindow = app.keyWindow
        let mainWindow = app.mainWindow
        return (keyWindow != mainWindow) ? mainWindow?.firstResponder : nil
    }
    
    override func applicationProvider() -> ActionContextProvider? {
        return NSApplication.shared.delegate as? ActionContextProvider
    }
    
    override func identifier(from item: Any) -> String? {
        if let identifier = (item as? NSUserInterfaceItemIdentification)?.identifier?.rawValue {
            return identifier
        } else if let identifier = (item as? NSToolbarItem)?.itemIdentifier.rawValue {
            return identifier
        } else {
            return nil
        }
    }

    public func install() {
        responder.manager = self
        responder.nextResponder = NSApp.nextResponder
        NSApp.nextResponder = responder
    }
}

#endif
