// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if !os(watchOS)
import XCTest
@testable import Actions

class ActionContextTests: XCTestCase {
    func testBasics() {
        let manager = ActionManager()
        let action = Action(identifier: "Test")
        let context = ActionContext(manager: manager, action:action, identifier: "Test", parameters: ["p1", "p2"])
        context.info.append(key: "test", value: "item1")
        context.info.append(key: "test", value: "item2")
        
        var items = [String]()
        context.info.forEach(key: "test") {
            items.append($0)
        }
        
        print(context.info)
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0], "item1")
        XCTAssertEqual(items[1], "item2")
    }
    
    func testExplicitSender() {
        let manager = ActionManager()
        let action = Action(identifier: "Test")
        let context = ActionContext(manager: manager, action:action, identifier: "Test", info: ActionInfo(sender: self))
        XCTAssertTrue(context.sender as? ActionContextTests === self)
    }
    
    func testDefaultSender() {
        let manager = ActionManager()
        let action = Action(identifier: "Test")
        let context = ActionContext(manager: manager, action:action, identifier: "Test")
        XCTAssertTrue(context.sender as! ActionManager === manager)
    }
    
    func testFlags() {
        let info = ActionInfo()
        XCTAssertFalse(info.flag(key: "test"))

        info["test"] = 0
        XCTAssertFalse(info.flag(key: "test"))

        info["test"] = false
        XCTAssertFalse(info.flag(key: "test"))

        info["test"] = "false"
        XCTAssertFalse(info.flag(key: "test"))

        info["test"] = "NO"
        XCTAssertFalse(info.flag(key: "test"))

        info["test"] = 1
        XCTAssertTrue(info.flag(key: "test"))
        
        info["test"] = true
        XCTAssertTrue(info.flag(key: "test"))
        
        info["test"] = "true"
        XCTAssertTrue(info.flag(key: "test"))

        info["test"] = "YES"
        XCTAssertTrue(info.flag(key: "test"))

    }
    
    func testDescription() {
        let manager = ActionManager()
        let action = Action(identifier: "Test")
        let context = ActionContext(manager: manager, action: action, identifier: "Test")
        context["foo"] = "bar"
        XCTAssertEqual(context.description, "«context Actions.Action keys: foo»")
    }
    
    func testDefaultIdentifierTrailingAction() {
        class DoStuffAction: Action {
        }
        
        let action = DoStuffAction()
        XCTAssertEqual(action.identifier, "DoStuff")
    }

    func testDefaultIdentifierMultipleActions() {
        class DoActionStuffAction: Action {
        }
        
        let action = DoActionStuffAction()
        XCTAssertEqual(action.identifier, "DoActionStuff")
    }

    func testDefaultIdentifierNoTrailingAction() {
        class DoStuff: Action {
        }
        
        let action = DoStuff()
        XCTAssertEqual(action.identifier, "DoStuff")
    }

}
#endif
