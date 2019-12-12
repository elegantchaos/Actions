// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 12/12/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public struct ActionKey: Equatable, Hashable, ExpressibleByStringLiteral {
    public let value: String
    public init(_ value: String) { self.value = value }
    public init?(_ value: String?) {
        guard let value = value else { return nil }
        self.value = value
    }
    public init(stringLiteral: String) { self.value = stringLiteral }
}

// MARK: - Standard Keys

extension ActionKey {
    public static let actionKey: Self = "action"
    public static let actionComponentsKey: Self = "components"
    public static let documentKey: Self = "document"
    public static let infoKey: Self = "info"
    public static let modelKey: Self = "model"
    public static let notificationKey: Self = "notification"
    public static let objectKey: Self = "object"
    public static let observerKey: Self = "observer"
    public static let rootKey: Self = "root"
    public static let selectionKey: Self = "selection"
    public static let senderKey: Self = "sender"
    public static let skipValidationKey: Self = "skipValidation"
    public static let targetKey: Self = "target"
    public static let viewModelKey: Self = "viewModel"
    public static let windowKey: Self = "window"
    
}
