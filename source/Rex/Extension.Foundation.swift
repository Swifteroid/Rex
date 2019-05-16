import Foundation
import ReactiveCocoa
import ReactiveSwift

extension Reactive where Base: NSObject {
    /// Creates the signal for the given `Swift.KeyPath` changes. The property must be dynamic and the key path must return 
    /// valid `_kvcKeyPathString`, otherwise will return an empty signal.
    public func signal<V>(forKeyPath keyPath: KeyPath<Base, V>) -> Signal<V, Never> {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            NSLog("\(keyPath) doesn't provide a valid KVC key path, make sure the property is `@objc` and `dynamic`.")
            return .empty
        }
        return self.signal(forKeyPath: keyPathString).map({ [unowned base] in $0 as? V ?? base[keyPath: keyPath] })
    }

    /// Creates the signal producer for the given `Swift.KeyPath` changes. The property must be dynamic and the key path must return 
    /// valid `_kvcKeyPathString`, otherwise will return an empty signal.
    public func producer<V>(forKeyPath keyPath: KeyPath<Base, V>) -> SignalProducer<V, Never> {
        guard let keyPathString = keyPath._kvcKeyPathString else {
            NSLog("\(keyPath) doesn't provide a valid KVC key path, make sure the property is `@objc` and `dynamic`.")
            return .empty
        }
        return self.producer(forKeyPath: keyPathString).map({ [unowned base] in $0 as? V ?? base[keyPath: keyPath] })
    }
}

extension Reactive where Base: AnyObject {
    /// Returns give notification signal for current object mapping it to object itself to avoid object capturing inside a block.
    public func notifications(forName name: Notification.Name) -> Signal<Notification, Never> {
        return NotificationCenter.default.reactive.notifications(forName: name, object: self.base).take(duringLifetimeOf: self.base)
    }

    /// Returns give notification signal for current object mapping it to object itself to avoid object capturing inside a block.
    public func notifications(forNames names: [Notification.Name]) -> Signal<Notification, Never> {
        return Signal.merge(names.map({ NotificationCenter.default.reactive.notifications(forName: $0, object: self.base) })).take(duringLifetimeOf: self.base)
    }
}
