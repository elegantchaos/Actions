// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import Logger

/**
 Log channel for ActionManager related messages.
 */

let actionChannel = Logger("Actions")

/**
 Handles registering and triggering actions.
 
 Actions are distinguished by a text identifier, and are registered as instances.
 
 This allows for generic action classes that can be instantiated multiple times using different settings,
 and registered using different identifiers.
 
 Actions should be regarded as immutable once registered.
 
 Any state required for a specific invocation of an action is stored in the accompanying action context. Items
 in the responder chain are allowed to add information to this context, thus allowing actions to respond to
 the context in which they were invoked.
 */


#if os(macOS)
    public typealias OSResponder = NSResponder
    public typealias OSApplication = NSApplication
#else
    public typealias OSResponder = UIResponder
    public typealias OSApplication = UIApplication
#endif

#if os(macOS)

@objc public class ActionManager: OSResponder {

    var actions = [String:Action]()
    
    /**
     Register a bunch of actions.
     
     Typically called early on, from somewhere like applicationWillFinishLaunching.
     */
    
    public func register(_ actionsToRegister: [Action]) {
        actionsToRegister.forEach {
            actions[$0.identifier] = $0
        }
    }
    
    /**
     Gather context from the responder chain.
     We attempt to follow the same path that the system would:
     - the key window, from first responder to root
     - the main window (if different), from first responder to root
     - the app delegate
     
     All items along this chain have the opportunity to contribute to the context.
     */
    
    func gather(context: ActionContext) {
        let app = OSApplication.shared
        let keyWindow = app.keyWindow
        gather(context: context, from: keyWindow?.firstResponder)
        let mainWindow = app.mainWindow
        if keyWindow != mainWindow {
            gather(context: context, from: mainWindow?.firstResponder)
        }
        if let appProvider = app.delegate as? ActionContextProvider {
            appProvider.provide(context: context)
        }
    }
    
    /**
     Gather context, starting at a given responder and working down the chain.
     */
    
    func gather(context: ActionContext, from: OSResponder?) {
        var responder = from
        while (responder != nil) {
            if let provider = responder as? ActionContextProvider {
                provider.provide(context: context)
            }
            responder = responder?.nextResponder
        }
    }
    
    func identifier(from item: Any) -> String? {
        if let identifier = (item as? NSUserInterfaceItemIdentification)?.identifier?.rawValue {
            return identifier
        } else if let identifier = (item as? NSToolbarItem)?.itemIdentifier.rawValue {
            return identifier
        } else {
            return nil
        }
    }
    
    /**
     Perform an action.
     
     We parse the identifier looking for a registered action, and pass
     any remaining components to it as parameters.
     */
    
    public func perform(identifier: String, sender: Any) {
        var components = ArraySlice(identifier.split(separator: ".").map { String($0) })
        while let actionID = components.popFirst() {
            if let action = actions[actionID] {
                actionChannel.log("performing \(action)")
                let context = ActionContext(manager: self, sender: sender, parameters: Array(components))
                gather(context: context)
                action.perform(context: context)
                return
            }
        }
        
        actionChannel.log("no registered actions for: \(identifier)")
    }
    
    /**
     Perform an action sent by a user interface item.
     We attempt to extract the identifier from the item, and use that as the action to perform.
     */
    
    @IBAction func performAction(_ sender: Any) {
        if let identifier = identifier(from: sender) {
            perform(identifier: identifier, sender: sender)
        } else {
            actionChannel.log("couldn't identify action")
        }
    }
    
    /**
     Validate an action to see if it should be enabled.
     We follow essentially the same path as when performing the action,
     building up a context first, but then call `validate` instead of `perform`.
     
     Typically an action just needs to check the context for the presence of
     keys in order to decide whether it's valid.
     
     */
    
    public func validate(identifier: String, item: Any) -> Bool {
        var components = ArraySlice(identifier.split(separator: ".").map { String($0) })
        while let actionID = components.popFirst() {
            if let action = actions[actionID] {
                actionChannel.log("validating \(action)")
                let context = ActionContext(manager: self, sender: item, parameters: Array(components))
                gather(context: context) // TODO: cache the context for the duration of any given user interface event, to avoid pointless recalculation
                return action.validate(context: context)
            }
        }
        
        return true
    }
    
    /**
     Return the selector that items should set as their action in order to trigger actions.
     
     Useful for code in client modules that wants to set up UI items programmatically.
     */
    
    public static var performActionSelector: Selector { get { return #selector(performAction(_:)) } }
}

#if os(macOS)

extension ActionManager: NSUserInterfaceValidations {

    /**
     Validate an action to see if it should be enabled.
     We follow essentially the same path as when performing the action,
     building up a context first, but then call `validate` instead of `perform`.
     
     Typically an action just needs to check the context for the presence of
     keys in order to decide whether it's valid.
     
     */
    
    public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(performAction(_:)) {
            if let identifier = identifier(from: item) {
                return validate(identifier: identifier, item: item)
            }
        }
        
        return true
    }
    

}

#endif

#else

@objc public class ActionManager: OSResponder {
    
    public func validate(identifier: String, item: Any) -> Bool {
        return false
    }
    
    public func perform(identifier: String, sender: Any) {
    }

}

#endif
