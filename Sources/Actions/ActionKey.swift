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
    public static let action: ActionKey = "action"
    public static let actionComponents: ActionKey = "components"
    public static let document: ActionKey = "document"
    public static let info: ActionKey = "info"
    public static let model: ActionKey = "model"
    public static let notification: ActionKey = "notification"
    public static let object: ActionKey = "object"
    public static let observer: ActionKey = "observer"
    public static let root: ActionKey = "root"
    public static let selection: ActionKey = "selection"
    public static let sender: ActionKey = "sender"
    public static let skipValidation: ActionKey = "skipValidation"
    public static let target: ActionKey = "target"
    public static let viewModel: ActionKey = "viewModel"
    public static let window: ActionKey = "window"
}
