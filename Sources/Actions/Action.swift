
import Foundation

/**
 Represents an action to be performed.
 
 Instances are located using an identifier, so the same action class can
 be used to implement multiple actions, which each instance potentially
 configured differently and assigned a different identifier.
 */

open class Action {
    public typealias Completion = () -> Void
    
    /**
     Identifier used to locate this action.
     */
    
    let identifier: String
    
    /**
     Create an action.
     */
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    /**
     Is this action valid for the given context?
     */
    
    open func validate(context: ActionContext) -> Bool {
        return true
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
