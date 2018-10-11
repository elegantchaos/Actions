import XCTest

extension ActionContextTests {
    static let __allTests = [
        ("testBasics", testBasics),
    ]
}

extension ActionIdentificationTests {
    static let __allTests = [
        ("testAssociated", testAssociated),
        ("testAssociatedNotSet", testAssociatedNotSet),
        ("testBasics", testBasics),
        ("testFixed", testFixed),
    ]
}

extension ActionsTests {
    static let __allTests = [
        ("testArguments", testArguments),
        ("testCantGetIdentifierFromSender", testCantGetIdentifierFromSender),
        ("testCustomProvider", testCustomProvider),
        ("testCustomResponderChain", testCustomResponderChain),
        ("testDefaultAction", testDefaultAction),
        ("testGetIdentifierFromSender", testGetIdentifierFromSender),
        ("testPerform", testPerform),
        ("testPrefix", testPrefix),
        ("testSenderIsResponder", testSenderIsResponder),
        ("testUnregistered", testUnregistered),
        ("testValidate", testValidate),
        ("testValidateCantGetIdentifierFromSender", testValidateCantGetIdentifierFromSender),
        ("testValidateGettingIdentifierFromSender", testValidateGettingIdentifierFromSender),
    ]
}

extension DelegatedActionTests {
    static let __allTests = [
        ("testAction1", testAction1),
        ("testAction2", testAction2),
        ("testDelegated", testDelegated),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ActionContextTests.__allTests),
        testCase(ActionIdentificationTests.__allTests),
        testCase(ActionsTests.__allTests),
        testCase(DelegatedActionTests.__allTests),
    ]
}
#endif
