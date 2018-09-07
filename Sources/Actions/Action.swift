// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

/**
 Represents an action to be performed.
 
 Instances are located using an identifier, so the same action class can
 be used to implement multiple actions, which each instance potentially
 configured differently and assigned a different identifier.
 */

open class Action {
    
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
     */
    
    open func perform(context: ActionContext) {
        actionChannel.log("generic action fired - perfom needs to be overridden")
    }
    
}
