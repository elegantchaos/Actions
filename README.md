# Actions

An abstraction for action-handling, for Swift applications.

### Stability

Note that the API is in flux currently. 

Although I'm using semantic version numbers, I will abuse them until things settle down - so new maintenance releases are likely to contain breaking changes for a while. This is simply to avoid prematurely ending up at version 10.x!

## Concepts

Actions are discrete pieces of work that do something. This may be modifying the model, or performing a user interface action, it doesn't really matter.

Actions are registered with the ActionManager, using an identifier. They are then invoked via the ActionManager, using the same identifier.

Actions are decoupled from each other, and from everything that they don't need to perform their specific task.

When an action is performed, it is passed a context. This contains all the information that it needs to perform its action, and is the main mechanism for ensuring that coupling is loose and dynamic.

The context supplied to the action is filled in by items in the responder chain. In this way, it is literally dependent on the user interface context - which window is at the front, which item has focus, and so on. The same action can be invoked in many different situations, as long as something in the responder chain supplies the correct context. Swift's type safety helps here, making it easy to extract the relevant parameters from the context ensuring that they are of the right type. 

## UI Integration

The Actions module has no dependencies on AppKit/UIKit. It could be used to implement actions for a command line application, or on a non-Apple platform.

The ActionsKit module, on the other hand, builds on top of Actions and integrates it into the responder chain for AppKit or UIKit.

This allows you to bind UI buttons, menus etc to send `performAction` selector to the responder chain, and have the action manager pick them up, infer the action to execute, and perform is. It also implements some validation support.

Undo support is not there yet, but will be added.

## Usage

### Setup

Make an `ActionManager`, attach it to something global (eg your app delegate), and register some actions with it.

If you're going to bind UI items to it, use one of the `ActionManagerMac` or `ActionManagerMobile` subclasses, and hook it into the responder chain by calling `installResponder`.

```swift
class Application: NSObject, NSApplicationDelegate {
let actionManager = ActionManagerMac()

func applicationWillFinishLaunching(_ notification: Notification) {
    actionManager.register([
        MyAction(identifier: "MyAction"),
        AnotherAction(identifier: "AnotherAction")
    ])
    actionManager.installResponder()
}
```

### Invocation

Set the action of user interface objects to `performAction(_ sender: Any)`, and the target to the first responder. Set the identifier of the UI item to the identifier of the action you want to invoke.

Alternatively, invoke an action directly with `actionManager.perform("MyAction")`.

### Actions

Actions are classes.

To define an action, inherit from `Action`, and implement `perform`:

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

The action to invoke can be passed explicitly, or parsed out of the identifier of a user interface item.

User interface identifiers can take the form: `{prefix.}action{("key": "value", "key2": "value2")}`.

The optional prefix, which is discarded, can be any string, and can contain full stops.

This allows you to bind multiple user interface items to the same action, without giving them exactly the same identifier string (Xcode complains if they aren't unique). All of the following identifiers would invoke the `MyAction` action: `MyAction`, `button.MyAction`, `menu.MyAction`, `some.other.thing.MyAction`. 

If brackets are present after the action, their contents is interpreted as a list of key,value pairs to be added to the context. For example, two buttons might have identifiers to `MyAction("color": "red")` and `MyAction("color": "blue")`. Both will invoke the `MyAction` action, but the value of `context["color"]` will be set to `red` or `blue` respectively.

Currently these arguments are parsed as if they were a JSON dictionary, so both the key and the value need to be quoted. Xcode actually complains about the presence of the `"`  and `:` characters in identifiers, so a future version may remove this restriction and allow you to specify simply `(key: value, key2: value2)`.


### Validation

Actions are often only valid in certain situations - for example when some text is selected - or they want to change
their name or visibility depending on the context.

To perform validation, override the `validate(context: ActionContext) -> Validation` and examine the context that's passed in.

When using the Mac or iOS action managers, validation is invoked automatically for certain user interface actions. In other situations you can invoke it manually as appropriate.  The automatic validation is almost always appropriate, but if there's a situation where you want to skip it, you can do so by arranging for the context to contain a true value for the `skipValidation`.

### Action Observers

If your user interface wants to know when certain actions have been performed, this pattern may be useful.

Define a protocol for observers of your action(s). This can contain anything you need.

Implement your protocol in the user interface controllers that want to observe. Also implement the `ActionContextProvider` protocol, and append the controller to a key that the action(s) will read:

```swift

protocol MyActionObserver {
  func myMethod(myArgument: String)
}

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
            observer.myMethod(myArgument: "myValue")
        }
    }
}
```

