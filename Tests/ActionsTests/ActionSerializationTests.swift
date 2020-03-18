// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/03/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions

class ActionSerializationTests: XCTestCase {

    func testStringSerialization() {
        XCTAssertEqual("test".serialized as? String, "test")
    }
    
    func testNumberSerialization() {
        let i = 123
        XCTAssertEqual(i.serialized as? Int, i)
        
        let d = 123.456
        XCTAssertEqual(d.serialized as? Double, d)
    }
    
    func testArraySerialization() {
        let list: [Any] = [1,2.3,"test"]
        let serialized = list.serialized as! [Any]
        XCTAssertEqual(serialized[0] as? Int, list[0] as? Int)
        XCTAssertEqual(serialized[1] as? Double, list[1] as? Double)
        XCTAssertEqual(serialized[2] as? String, list[2] as? String)
    }
    
    func testContextSerialization() {
        let manager = ActionManager()
        let action = Action(identifier: "Test")
        let context = ActionContext(manager: manager, action: action, identifier: "Test")
        context["foo"] = "bar"
        let packed = context.serializedDictionary
        XCTAssertEqual(packed[ActionKey.action.value] as? String, "Test")
        let info = packed[ActionKey.info.value] as! [String:Any]
        XCTAssertEqual(info["foo"] as? String, "bar")
        
        
    }

}
