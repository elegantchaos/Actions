// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 08/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Logger

/**
 Log channel for ActionManager related messages.
 */

public let actionChannel = Channel("com.elegantchaos.actions")
public let providerChannel = Channel("com.elegantchaos.actions.providers")

public protocol ActionResponder {
    func next() -> ActionResponder?
}

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


open class ActionManager {
    
    var actions = [String:Action]()
    var notifications = [ActionNotification]()
    
    public init() {
        
    }
    
    /**
     Register a bunch of actions.
     
     Typically called early on, from somewhere like applicationWillFinishLaunching.
     */
    
    public func register(_ actionsToRegister: [Action]) {
        for action in actionsToRegister {
            let id = action.identifier
            if let existing = actions[id] {
                actionChannel.log("Multiple actions being registered with the id \(id): \(existing) \(action)")
            }
            actions[id] = action
        }
    }
    
    /**
     Register a global notification.
    */
    
    public func registerNotification(for action: String = "", key: String = ActionContext.notificationKey, notification: @escaping ActionNotificationCallback) {
        let notification = ActionNotification(action: action, callback: notification)
        notifications.append(notification)
    }

    /**
     Responder chains to gather context from.
    */
    
    open func responderChains(for item: Any) -> [ActionResponder] {
        providerChannel.log("Getting responder chains for \(item):")

        if let responder = item as? ActionResponder {
            providerChannel.log("Item is a responder itself")
            return [responder]
        }
        
        return []
    }
    
    /**
     Providers to gather context from.
     */
    
    open func providers(for item: Any) -> [ActionContextProvider] {
        providerChannel.log("\n\nGetting providers for \(item):")

        var result = [ActionContextProvider]()
        if let provider = item as? ActionContextProvider {
            providerChannel.log("Item is a provider itself")
            result.append(provider)
        }
        
        let chains = responderChains(for: item)
        providerChannel.log("\(chains.count) chains found.")
        for chain in chains {
            providerChannel.log("Searching responder chain \(chain)")
            var responder: ActionResponder? = chain
            while (responder != nil) {
                if let provider = responder as? ActionContextProvider {
                    if result.filter({ $0.identicalTo(other: provider) }).count == 0 {
                        providerChannel.log("Found provider \(provider)")
                        result.append(provider)
                    }
                }
                responder = responder?.next()
            }
        }

        providerChannel.log("\(result.count) providers found.\n\(result)\n\n")

        return result
    }
    
    /**
     Get an action identifier from an arbitrary object.
    */
    
    func identifier(for item: Any) -> String? {
        if let identifier = (item as? ActionIdentification)?.actionID {
            return identifier
        }
        
        return nil
    }

    /**
     Gather context.
     The exact places to gather context from are determined by the
     implementation of `providers()` and `responderChains()`, which
     can vary according to the platform.
     
     See `ActionManagerMac` and `ActionManagerMobile` for examples.
     
     All items along this chain have the opportunity to contribute to the context.
     */
    
    func gather(context: ActionContext, for item: Any) {
        for provider in providers(for: item) {
            provider.provide(context: context)
        }
    }

    /**
     Look up an action. If we find it, build a context and execute a block with the action and context.
 
     Returns true if the action was found and the block performed.
    */
    
    func resolving(identifier: String, info: ActionInfo = ActionInfo(), do block: (_ context: ActionContext) -> Void) -> Bool {
        var prefix = identifier
        var params: [String:Any] = [:]
        let items = identifier.split(separator: "(", maxSplits: 1, omittingEmptySubsequences: true)
        if items.count == 2 {
            prefix = String(items[0])
            let suffix = items[1].split(separator: ")")[0]
            let json = "{\(suffix)}"
            if let parsed = try? JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: []) {
                if let dict = parsed as? [String:Any] {
                    params = dict
                }
            }
        }
        
        var components = ArraySlice(prefix.split(separator: ".").map { String($0) })
        while let actionID = components.popFirst() {
            if let action = actions[actionID] {
                let context = ActionContext(manager: self, action: action, identifier: identifier, parameters: Array(components), info: info) // TODO: cache the context for the duration of any given user interface event, to avoid pointless recalculation
                for param in params {
                    context[param.key] = param.value
                }
                gather(context: context, for:context.sender)
                block(context)
                return true
            }
        }
        
        actionChannel.log("couldn't resolve \(identifier)")
        return false
    }
    
    /**
     Perform an action.
     
     We parse the identifier looking for a registered action, and pass
     any remaining components to it as parameters.
     */
    
    public func perform(identifier: String, info: ActionInfo = ActionInfo()) {
        let notifications = self.notifications
        let performed = resolving(identifier: identifier, info: info) { (context) in
            actionChannel.log("performing \(context.action)")
            context.notify(stage: .willPerform, global: notifications)
            context.action.perform(context: context, completed: {
                context.notify(stage: .didPerform, global: notifications)
            })
        }
        
        if !performed {
            actionChannel.log("no registered actions for: \(identifier)")
        }
    }
    
    /**
     Perform an action sent by a user interface item.
     We attempt to extract the identifier from the item, and use that as the action to perform.
     */
    
    public func perform(_ sender: Any) {
        if let identifier = identifier(for: sender) {
            perform(identifier: identifier, info: ActionInfo(sender: sender))
        } else {
            actionChannel.log("couldn't identify action for \(sender)")
        }
    }
    
    
    /**
     Validate an item representing an action to see if it should be enabled.
     We follow essentially the same path as when performing the action,
     building up a context first, but then call `validate` instead of `perform`.
     
     Typically an action just needs to check the context for the presence of
     keys in order to decide whether it's valid.
     
     */

    public func validate(_ item: Any) -> Action.Validation {
        if let identifier = identifier(for: item) {
            return validate(identifier: identifier, info: ActionInfo(sender: item))
        } else {
            actionChannel.log("couldn't identify action for \(item)")
        }
        
        return Action.Validation(identifier: "<unknown>")
    }
    
    /**
     Validate an action to see if it should be enabled.
     We follow essentially the same path as when performing the action,
     building up a context first, but then call `validate` instead of `perform`.
     
     Typically an action just needs to check the context for the presence of
     keys in order to decide whether it's valid.
     
     */
    
    public func validate(identifier: String, info: ActionInfo = ActionInfo()) -> Action.Validation {
        var validation = Action.Validation(identifier: identifier, state: .ineligable)
        
        let _ = resolving(identifier: identifier, info: info) { (context) in
            if context.flag(key: ActionContext.skipValidationKey) {
                actionChannel.log("skipping validation \(context.action)")
                validation = Action.Validation(identifier: identifier)
            } else {
                actionChannel.log("validating \(context.action)")
                validation = context.action.validate(context: context)
            }
        }
        
        return validation
    }
    
    /// Given a list of action identifiers, and some action info, perform validation on each one then
    /// call some sort of builder task for it. Returns a list of the results of all the builder calls.
    ///
    /// Typically this is used to build a user interface element, such as a UIMenuItem, for each action.
    ///
    /// - Parameter actions: the action identifiers to iterate over
    /// - Parameter withInfo: info containing the sender, and other parameters that the validation might need
    /// - Parameter builder: the builder closure to run
    public func buildItems<T>(forActions actions: [String], withInfo info: ActionInfo, builder: (String, Action.Validation) -> T) -> [T] {
        var items: [T] = []
        for id in actions {
            let state = validate(identifier: id, info: info)
            let item = builder(id, state)
            items.append(item)
        }
        return items
    }
}
