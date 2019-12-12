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
    public static let action: Self = "action"
    public static let actionComponents: Self = "components"
    public static let document: Self = "document"
    public static let info: Self = "info"
    public static let model: Self = "model"
    public static let notification: Self = "notification"
    public static let object: Self = "object"
    public static let observer: Self = "observer"
    public static let root: Self = "root"
    public static let selection: Self = "selection"
    public static let sender: Self = "sender"
    public static let skipValidation: Self = "skipValidation"
    public static let target: Self = "target"
    public static let viewModel: Self = "viewModel"
    public static let window: Self = "window"    
}
