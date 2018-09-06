// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

open class Action {
    let identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    open func perform(context: ActionContext) {
        ActionChannel.log("generic action fired - perfom needs to be overridden")
    }
    
}
