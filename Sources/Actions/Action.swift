
import Foundation

/**
 Represents an action to be performed.
 
 Instances are located using an identifier, so the same action class can
 be used to implement multiple actions, which each instance potentially
 configured differently and assigned a different identifier.
 */

open class Action {
    public struct Validation {
        public let enabled: Bool
        public let visible: Bool
        public let name: String?
        public let shortName: String?
        
        public init(enabled: Bool = true, visible: Bool = true, name: String? = nil, shortName: String? = nil) {
            self.enabled = enabled
            self.visible = visible
            self.name = name
            self.shortName = shortName ?? name
        }
    }
    
    public typealias Completion = () -> Void
    
    /**
     Identifier used to locate this action.
     */
    
    let identifier: String
    
    /**
     Create an action.
     If an explicit identifier isn't provided, we use the name of the action class, stripping off the trailing "Action" if it's present.
     So if the class is called "DoStuffAction", the default identifier will be "DoStuff".
     */
    
    public init(identifier: String? = nil) {
        if let identifier = identifier {
            self.identifier = identifier
        } else {
            var name = String(describing:type(of: self))
            if let range = name.range(of: "Action", options: .backwards) {
               name.removeSubrange(range)
            }
            self.identifier = name
        }
    }
    
    /**
     Is this action valid for the given context?
     */
    
    open func validate(context: ActionContext) -> Bool {
        return true
    }

    /**
     Validate this action.
     
     The validation process gives actions a
     chance to change their enabled state, their visibility,
     and their name according to the current context.
     
     */
    
    open func validate(context: ActionContext) -> Validation {
        // by default we call onto the legacy version of the validation,
        // which just returns a bool indicating enabled/disabled status
        return Validation(enabled: self.validate(context: context))
    }

    /**
     Perform the action in the given context.
     
     Synchronous actions should override this method.
     */
    
    open func perform(context: ActionContext) {
        actionChannel.log("generic action fired - perfom needs to be overridden")
    }

    /**
     Perform the action in the given context, then call the provided completion routine.
     
     Asynchronous actions should override this method, and ensure that they only call
     the completion routine when they are completely finished.
     
     Failure to call the completion will result in the .didPerform notification not
     getting sent.
     */
    
    open func perform(context: ActionContext, completed: @escaping Completion) {
        perform(context: context)
        completed()
    }

}
