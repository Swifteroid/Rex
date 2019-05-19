import Foundation
import ReactiveSwift

extension Signal {
    public typealias Pipe = (output: Signal<Value, Never>, input: Signal<Value, Never>.Observer)
}

extension Signal {
    /// Returns new signal with no value.
    public func void() -> Signal<(), Error> { return self.map({ _ in }) }
}

extension SignalProducer {
    /// Returns new producer with no value.
    public func void() -> SignalProducer<(), Error> { return self.map({ _ in }) }
}

extension Signal {
    /// Extends the signal value with the given object and returns new signal with the tuple, valid during the lifetime of the extending object.
    public func extend<Extension: AnyObject>(_ value: Extension) -> Signal<(Extension, Value), Error> { return self.take(duringLifetimeOf: value).map({ [unowned value] in (value, $0) }) }
    public func extend<Extension: AnyObject>(_ value: Extension) -> Signal<Extension, Error> where Value == () { return self.take(duringLifetimeOf: value).map({ [unowned value] in value }) }
    public func extend<Extension: AnyObject, V1, V2>(_ value: Extension) -> Signal<(Extension, V1, V2), Error> where Value == (V1, V2) { return self.take(duringLifetimeOf: value).map({ [unowned value] in (value, $0.0, $0.1) }) }
}

extension SignalProducer {
    /// Extends the producer value with the given object and returns new producer with the tuple, valid during the lifetime of the extending object.
    public func extend<Extension: AnyObject>(_ value: Extension) -> SignalProducer<(Extension, Value), Error> { return self.take(duringLifetimeOf: value).map({ [unowned value] in (value, $0) }) }
    public func extend<Extension: AnyObject>(_ value: Extension) -> SignalProducer<Extension, Error> where Value == () { return self.take(duringLifetimeOf: value).map({ [unowned value] in value }) }
    public func extend<Extension: AnyObject, V1, V2>(_ value: Extension) -> SignalProducer<(Extension, V1, V2), Error> where Value == (V1, V2) { return self.take(duringLifetimeOf: value).map({ [unowned value] in (value, $0.0, $0.1) }) }
}

extension Reactive {
    /// A proxy which holds reactive binding target extensions of `Base`.
    public struct Binds<Base> {
        fileprivate init(_ base: Base) { self.base = base }
        public let base: Base
    }

    public var bind: Binds<Base> { return Binds(self.base) }

    /// A proxy which holds reactive signal extensions of `Base`.
    public struct Signals<Base> {
        fileprivate init(_ base: Base) { self.base = base }
        public let base: Base
    }

    public var signal: Signals<Base> { return Signals(self.base) }

    /// A proxy which holds reactive signal producer extensions of `Base`.
    public struct Producers<Base> {
        fileprivate init(_ base: Base) { self.base = base }
        public let base: Base
    }

    public var producer: Producers<Base> { return Producers(self.base) }
}

extension Reactive.Binds where Base: ReactiveExtensionsProvider {
    /// Convenience `self.base.reactive` accessor.
    public var reactive: Reactive<Base> { return self.base.reactive }
}

extension Reactive.Signals where Base: ReactiveExtensionsProvider {
    /// Convenience `self.base.reactive` accessor.
    public var reactive: Reactive<Base> { return self.base.reactive }
}

extension Reactive.Producers where Base: ReactiveExtensionsProvider {
    /// Convenience `self.base.reactive` accessor.
    public var reactive: Reactive<Base> { return self.base.reactive }
}
