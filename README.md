# Actions

An abstraction for action-handling, for Swift/AppKit-based applications.

## Usage

### Setup

Make an ActionManager, attach it to something global (eg your app delegate), and register some actions with it.

If you're going to bind UI items to it, hook it into the responder chain:

```swift
class Application: NSObject, NSApplicationDelegate {
let actionManager = ActionManager()

func applicationWillFinishLaunching(_ notification: Notification) {
    actionManager.register([
        MyAction(identifier: "MyAction"),
        AnotherAction(identifier: "AnotherAction")
    ])

    actionManager.nextResponder = NSApp.nextResponder
    NSApp.nextResponder = actionManager
}
```

### Invocation

Set the action of user interface objects to `performAction(_ sender: Any)`, and the target to the first responder. Set the identifier of the UI item to the identifier of the action you want to invoke.

Alternatively, invoke an action directly with `actionManager.perform("MyAction")`.

### Actions

Inherit from `Action`, and implement `perform`:

```swift
class MyAction: PersonAction {
    override func perform(context: ActionContext) {
        // do stuff here
    }
}
```

### Context

The `context` passed to `perform` contains the original sender.

It also contains a dictionary of other information. Items in the responder chain can add items to this dictionary whenever actions are performed, by implementing the `ActionContextProvider` protocol. 

This lets a view controller or window controller pass essential information to actions whilst keeping them fully decoupled.

The context also contains a parameters array. Parameters are parsed out of the identifier that was used to invoke the action.

The algorithm for parsing the identifier is:

- split it into a list of strings separated by '.'
- pop items from the left of the list until we find one that matches a registered action
- everything unused to the right of the list becomes the context parameters

This allows you to bind multiple user interface items to the same action, in a parameterised way.

For example you can set a button's identifier to `button.MyAction` and a menu item's to `menu.MyAction`. Both will have unique identifiers - which Xcode insists on - but both will be resolved to the `MyAction` action.

In another example, you could set two button identifiers to `MyAction.red` and `MyAction.blue`. Both will invoke `MyAction`, but the `context.parameters` array will contain `["red"]` for the first one, and `["blue"]` for the second. The action can read this parameter and behave differently in either case. 


### Action Observers

If your user interface wants to know when certain actions have been performed, this pattern may be useful.

Define a protocol for observers of your action(s). This can contain anything you need.

Implement your protocol in the user interface controllers that want to observe. Also implement the `ActionContextProvider` protocol, and append the controller to a key that the action(s) will read:

```swift

extension MyViewController: ActionContextProvider, MyActionObserver {

func provide(context: ActionContext) {
    context.append(key: "MyActionObserver", value: self)
}
```

In the action, as well as perfoming the actual work, enumerate the observer key. For each observer, call a method from your protocol, passing any arguments or context that is relevant:

```swift
class MyAction: PersonAction {
    override func perform(context: ActionContext) {
        // do some stuff here
        
        // notify observers
        context.forEach(key: "MyActionObserver") { (observer: MyActionObserver) in
            observer.myMethod(myArgument: myValue)
        }
    }
}
```

