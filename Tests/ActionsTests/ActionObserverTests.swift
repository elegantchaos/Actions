// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 18/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


import XCTest
@testable import Actions


final class ActionObserverTests: XCTestCase {
    class TestObserver: ActionObserver, Hashable {
        
        let name: String
        
        init(_ name: String) {
            self.name = name
        }
        
        final class func == (lhs: ActionObserverTests.TestObserver, rhs: ActionObserverTests.TestObserver) -> Bool {
            return lhs.name == rhs.name
        }
        
        func hash(into hasher: inout Hasher) {
            name.hash(into: &hasher)
        }
    }
    
    func testBasics() {
        let manager = ActionManager()
        let context = ActionContext(manager: manager, sender: manager)
        let obs1 = TestObserver("test1")
        context.addObserver(obs1)

        let obs2 = TestObserver("test2")
        context.addObserver(obs2)

        var observers = [TestObserver]()
        context.forObservers {
            observers.append($0)
        }
        
        XCTAssertEqual(observers.count, 2)
        XCTAssertTrue(observers.contains(obs1))
        XCTAssertTrue(observers.contains(obs2))
    }

    func testNoDuplication() {
        let manager = ActionManager()
        let context = ActionContext(manager: manager, sender: manager)
        let obs1 = TestObserver("test1")
        context.addObserver(obs1)
        context.addObserver(obs1)
        
        var observers = [TestObserver]()
        context.forObservers {
            observers.append($0)
        }
        
        XCTAssertEqual(observers.count, 1)
        XCTAssertTrue(observers.contains(obs1))
    }
}
