import AppKit
import Foundation
import ReactiveCocoa
import ReactiveSwift

extension Reactive where Base: NSControl {
    /// Sent when the control sends an action.
    public var didSendAction: Signal<(), Never> { self.trigger(for: #selector(self.base.sendAction(_:to:))) }
}

extension Reactive where Base: NSTextField {
    public var didBeginEditing: Signal<(), Never> { self.notifications(forName: NSControl.textDidBeginEditingNotification).void() }
    public var didEndEditing: Signal<(), Never> { self.notifications(forName: NSControl.textDidEndEditingNotification).void() }
}
