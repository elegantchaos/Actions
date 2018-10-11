// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 06/09/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions

final class ActionsTests: XCTestCase, ActionResponder, ActionContextProvider {
    class TestAction: Action {
        var performed = false
        var performedContext: ActionContext?
        
        override func perform(context: ActionContext) {
            performed = true
            performedContext = context
        }
    }

    class NormalSender {
    }
    
    class ResponderSender: ActionResponder, ActionContextProvider {
        let test: ActionsTests
        
        init(test: ActionsTests) {
            self.test = test
        }

        func next() -> ActionResponder? {
            return test
        }
        
        func provide(context: ActionContext) {
            context.info["valueProvidedBySender"] = "valueProvidedBySender"
        }
    }

    class ActionManagerWithTestAsResponder: ActionManager {
        let test: ActionsTests
        
        init(test: ActionsTests) {
            self.test = test
        }
        
        override func responderChains(for item: Any) -> [ActionResponder] {
            var chains = super.responderChains(for: item)
            chains.append(test)
            return chains
        }
    }

    class ActionManagerWithTestAsProvider: ActionManager {
        let test: ActionsTests
        
        init(test: ActionsTests) {
            self.test = test
        }

        override func providers(for item: Any) -> [ActionContextProvider] {
            var providers = super.providers(for: item)
            providers.append(test)
            return providers
        }
    }

    override func setUp() {
        actionChannel.enabled = true
    }
    
    func next() -> ActionResponder? {
        return nil
    }
    
    func provide(context: ActionContext) {
        context.info["valueProvidedByTest"] = "valueProvidedByTest"
    }
    
    func testPerform() {
        // test that an action gets performed
        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "test", sender: NormalSender())
        XCTAssertTrue(action.performed)
    }

    func testUnregistered() {
        // test that an action doesn't get performed if it's not registered
        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.perform(identifier: "test", sender: NormalSender())
        XCTAssertFalse(action.performed)
    }

    func testDefaultAction() {
        // test the default implementations of perform() and validate() if
        // an action class hasn't overridden them
        let action = Action(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "test", sender: NormalSender())
        XCTAssertTrue(manager.validate(identifier: "test", item: self))
    }
    
    func testArguments() {
        // test parsing of arguments from the identifier in a perform call
        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "test.param1.param2", sender: NormalSender())
        XCTAssertEqual(action.performedContext!.parameters.count, 2)
        XCTAssertEqual(action.performedContext!.parameters[0], "param1")
        XCTAssertEqual(action.performedContext!.parameters[1], "param2")
    }

    func testPrefix() {
        // test stripping of prefix from the identifier in a perform call
        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "prefix.test", sender: NormalSender())
        XCTAssertTrue(action.performed)
    }
    
    func testCustomResponderChain() {
        // test a custom action manager which supplies responder chains
        // to be searched for context information
        // (in this case we supply the test itself as a responder chain)
        let action = TestAction(identifier: "test")
        let manager = ActionManagerWithTestAsResponder(test: self)
        manager.register([action])
        manager.perform(identifier: "test", sender: NormalSender())
        XCTAssertEqual(action.performedContext!.info["valueProvidedByTest"] as? String, "valueProvidedByTest")
    }
    
    func testCustomProvider() {
        // test a custom action manager which supplies other providers
        // to be searched for context information
        // (in this case we supply the test itself as a provider)
        let action = TestAction(identifier: "test")
        let manager = ActionManagerWithTestAsProvider(test: self)
        manager.register([action])
        manager.perform(identifier: "test", sender: NormalSender())
        XCTAssertEqual(action.performedContext!.info["valueProvidedByTest"] as? String, "valueProvidedByTest")
    }
    
    func testSenderIsResponder() {
        // test the sending object being a responder itself
        // (it should be included in the responder chains)
        let sender = ResponderSender(test: self)
        let action = TestAction(identifier: "test")
        let manager = ActionManager()
        manager.register([action])
        manager.perform(identifier: "test", sender: sender)
        XCTAssertEqual(action.performedContext!.info["valueProvidedByTest"] as? String, "valueProvidedByTest")
        XCTAssertEqual(action.performedContext!.info["valueProvidedBySender"] as? String, "valueProvidedBySender")
    }
    
    static var allTests = [
        ("testBasics", testBasics),
        ("testArguments", testArguments),
        ("testPrefix", testPrefix),
    ]
}
