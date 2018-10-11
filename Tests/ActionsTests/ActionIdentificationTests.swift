// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 11/10/2018.
//  All code (c) 2018 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import XCTest
@testable import Actions

class FixedIdentifiable: ActionIdentification {
    public var actionID: String {
        get { return "myID" }
        set(value) { }
    }
}

class BasicIdentifiable: ActionIdentification {
    var actionID: String = ""
}

#if os(macOS) || os(iOS)
@objc class AssociatedIdentifiable: NSObject, ActionIdentification {
    @objc public var actionID: String {
        get { return retrieveID() }
        set(value) { storeID(value) }
    }
}
#endif

class ActionIdentificationTests: XCTestCase {
    func testBasics() {
        let thing = BasicIdentifiable()
        thing.actionID = "testID"
        XCTAssertEqual(thing.actionID, "testID")
    }
    
    #if os(macOS) || os(iOS)
    func testAssociated() {
        let thing = AssociatedIdentifiable()
        thing.actionID = "testID"
        XCTAssertEqual(thing.actionID, "testID")
    }

    func testAssociatedNotSet() {
        let thing = AssociatedIdentifiable()
        XCTAssertEqual(thing.actionID, "")
    }

    #endif

    func testFixed() {
        let thing = FixedIdentifiable()
        XCTAssertEqual(thing.actionID, "myID")
    }

}
