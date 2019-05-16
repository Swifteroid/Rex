import AppKit
import Foundation
import ReactiveCocoa
import ReactiveSwift

extension Reactive where Base: NSControl {
    public var isEnabled: MutablePropertyProxy<Base, Bool> { return self.property(\.isEnabled, self.signal(forKeyPath: \.isEnabled)) }

    /// Sent when the control sends an action.
    public var didSendAction: Signal<(), Never> { return self.trigger(for: #selector(self.base.sendAction(_:to:))) }
}

extension Reactive where Base: NSTextField {
    public var didBeginEditing: Signal<(), Never> { return self.notifications(forName: NSControl.textDidBeginEditingNotification).void() }
    public var didEndEditing: Signal<(), Never> { return self.notifications(forName: NSControl.textDidEndEditingNotification).void() }
}

extension Reactive where Base: NSView {
    public var isHidden: MutablePropertyProxy<Base, Bool> { return self.property(\.isHidden, self.signal(forKeyPath: \.isHidden)) }
}
