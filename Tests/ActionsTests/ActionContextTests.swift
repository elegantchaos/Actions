// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions

class ActionContextTests: XCTestCase {
    func testBasics() {
        let manager = ActionManager()
        let context = ActionContext(manager: manager, sender: manager, parameters: ["p1", "p2"])
        context.append(key: "test", value: "item1")
        context.append(key: "test", value: "item2")
        
        var items = [String]()
        context.forEach(key: "test") {
            items.append($0)
        }
        
        print(context.info)
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0], "item1")
        XCTAssertEqual(items[1], "item2")
    }
    
}
