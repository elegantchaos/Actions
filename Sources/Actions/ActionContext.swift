// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public protocol ActionContextProvider {
    func provide(context: ActionContext)
}

public class ActionContext {
    public static let SelectionKey = "selection"
    public static let TargetKey = "target"
    public static let SenderKey = "sender"
    public static let ModelObjectContextKey = "moc"
    public static let ActionKey = "action"
    public static let ActionComponentsKey = "components"
    
    public let sender: Any
    public var parameters: [String]
    public var info = [String:Any]()
    
    init(sender: Any, parameters: [String]) {
        self.sender = sender
        self.parameters = parameters
    }
}
