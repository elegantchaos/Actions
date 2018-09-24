// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 24/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/**
 Action which delegates to another action.

 We take a closure which returns the identifier
 of the other action to behave like.
 
 Since it's a closure, it can return different identifiers
 at different times, according to whatever criteria it wishes.
 
 This is useful for a user interface where buttons might perform
 a different action depending on some context, such as the visibility
 of a view or the state of another control.
 
 Example:
 
    Imagine we have a tab view which shows either a list of books
    or a list of people. We have a button that sits outside the view
    which should add either a book or a person, depending on which
    type is currently visible.
 
    To keep the code clean, we implement an AddPerson action, which
    just knows how to add people, and an AddBook action which just
    knows how to add books.
 
    We then create an AddItem action as a subclass of DelegatedAction,
    and bind our button to this. In the closure we pass when creating
    this, we delegate to either `AddPerson` or `AddBook`, depending on
    the setting of the tab view.
 
 */

class DelegatedAction: Action {
    typealias ActionDeterminer = (ActionContext) -> String
    let determiner: ActionDeterminer
    
    init(identifier: String, determiner: @escaping ActionDeterminer) {
        self.determiner = condition
        super.init(identifier: identifier)
    }
    
    override func validate(context: ActionContext) -> Bool {
        let manager = context.manager
        let identifier = determiner(context)
        return manager.validate(identifier: identifier, item: context.sender)
    }
    
    override func perform(context: ActionContext) {
        let manager = context.manager
        let identifier = determiner(context)
        manager.perform(identifier: identifier, sender: context.sender)
    }
}
