// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import AppKit
import Logger

let ActionChannel = Logger("Actions")





@objc public class ActionManager: NSResponder {
    var actions = [String:Action]()
    
    public func register(action: Action) {
        actions[action.identifier] = action
    }

    func gather(context: ActionContext) {
        let app = NSApplication.shared
        let keyWindow = app.keyWindow
        gather(context: context, from: keyWindow?.firstResponder)
        let mainWindow = app.mainWindow
        if keyWindow != mainWindow {
            gather(context: context, from: mainWindow?.firstResponder)
        }
        if let appProvider = app.delegate as? ActionContextProvider {
            appProvider.provide(context: context)
        }
    }

    func gather(context: ActionContext, from: NSResponder?) {
        var responder = from
        while (responder != nil) {
            if let provider = responder as? ActionContextProvider {
                provider.provide(context: context)
            }
            responder = responder?.nextResponder
        }
    }

    func perform(_ sender: Any) {
    }

    @IBAction func performAction(_ sender: Any) {
        guard let identifier = (sender as? NSUserInterfaceItemIdentification)?.identifier?.rawValue else {
            ActionChannel.log("couldn't identify action")
            return
        }
        
        var components = ArraySlice(identifier.split(separator: ".").map { String($0) })
        while let actionID = components.popFirst() {
            if let action = actions[actionID] {
                ActionChannel.log("performing \(action)")
                let context = ActionContext(sender: sender, parameters: Array(components))
                gather(context: context)
                action.perform(context: context)
                return
            }
        }
        
        ActionChannel.log("no registered actions for: \(identifier)")
    }
    
}
