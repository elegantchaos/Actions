
import Foundation

/**
 Represents an action to be performed.
 
 Instances are located using an identifier, so the same action class can
 be used to implement multiple actions, which each instance potentially
 configured differently and assigned a different identifier.
 */

open class Action {
    public enum State {
        case ineligable
        case inactive
        case active
    }
    
    public struct Validation {
        public let identifier: String
        public var state: State
        public var fullName: String
        public var shortName: String
        public var iconName: String
        public var localizationInfo: [String:Any] = [:]
        
        public static func defaultFullName(for identifier: String) -> String { return "action.\(identifier).title" }
        public static func defaultShortName(for identifier: String) -> String { return "action.\(identifier).short" }
        public static func defaultIconName(for identifier: String) -> String { return "action.\(identifier).icon" }

        public var defaultFullName: String { return Validation.defaultFullName(for: identifier) }
        public var defaultShortName: String { return Validation.defaultShortName(for: identifier) }
        public var defaultIconName: String { return Validation.defaultIconName(for: identifier) }

        public var enabled: Bool {
            get { return state == .active }
            set { state = newValue ? .active : .inactive }
        }
        
        public var visible: Bool {
            get { return state != .ineligable }
        }
        
        public init(identifier: String, state: State = .active, fullName: String? = nil, shortName: String? = nil, iconName: String? = nil) {
            self.identifier = identifier
            self.state = state
            self.fullName = fullName ?? Validation.defaultFullName(for: identifier)
            self.shortName = shortName ?? Validation.defaultShortName(for: identifier)
            self.iconName = iconName ?? Validation.defaultIconName(for: identifier)
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
     Validate this action.
     
     The validation process gives actions a
     chance to change their enabled state, their visibility,
     and their name according to the current context.
     
     */
    
    open func validate(context: ActionContext) -> Validation {
        // by default we call onto the legacy version of the validation,
        // which just returns a bool indicating enabled/disabled status
        return Validation(identifier: identifier)
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
