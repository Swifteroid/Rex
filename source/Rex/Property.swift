import Foundation
import ReactiveSwift

extension PropertyProtocol {
    /// Sent when the property value changes.
    public var trigger: Signal<(), Never> { return self.signal.void() }
}

public protocol PropertyProxyProtocol: PropertyProtocol {
    associatedtype Base
}

extension PropertyProxyProtocol {
    public var producer: SignalProducer<Value, Never> { return self.signal.producer.prefix(value: self.value) }
}

/// Lightweight non-mutable property-like class for expressing reactive mutable properties.
final public class PropertyProxy<Base: AnyObject & ReactiveExtensionsProvider, Value>: PropertyProxyProtocol {
    public init(_ base: Base, _ keyPath: KeyPath<Base, Value>, _ signal: Signal<Value, Never>) {
        self.base = base
        self.keyPath = keyPath
        self.signal = signal
    }

    public let base: Base
    public let keyPath: KeyPath<Base, Value>

    /// A signal that sends the property's changes over time.
    public let signal: Signal<Value, Never>

    /// The current value of the property.
    public var value: Value {
        return self.base[keyPath: self.keyPath]
    }
}

/// Lightweight mutable property-like struct for expressing reactive mutable properties.
final public class MutablePropertyProxy<Base: AnyObject & ReactiveExtensionsProvider, Value>: PropertyProxyProtocol, BindingTargetProvider {
    public init(_ base: Base, _ keyPath: ReferenceWritableKeyPath<Base, Value>, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) {
        self.base = base
        self.keyPath = keyPath
        self.scheduler = scheduler
        self.signal = signal
    }

    public let base: Base
    public let keyPath: ReferenceWritableKeyPath<Base, Value>

    /// Scheduler on which the property gets written, passed into a binding target.
    public let scheduler: Scheduler?

    /// A signal that sends the property's changes over time.
    public let signal: Signal<Value, Never>

    /// The current value of the property.
    public var value: Value {
        get { return self.base[keyPath: self.keyPath] }
        set { self.base[keyPath: self.keyPath] = newValue }
    }

    /// The property's binding target.
    public var bindingTarget: BindingTarget<Value> {
        return self.base.reactive[self.keyPath, on: scheduler ?? ImmediateScheduler()]
    }
}

extension Reactive where Base: AnyObject {
    /// Constructs a property proxy from the signal.
    public func property<Value>(_ keyPath: KeyPath<Base, Value>, _ signal: Signal<Value, Never>) -> PropertyProxy<Base, Value> {
        return PropertyProxy(self.base, keyPath, signal)
    }

    /// Constructs a property proxy from the signal pipe.
    public func property<Value>(_ keyPath: KeyPath<Base, Value>, _ pipe: (output: Signal<Value, Never>, input: Signal<Value, Never>.Observer)) -> PropertyProxy<Base, Value> {
        return PropertyProxy(self.base, keyPath, pipe.output)
    }

    /// Constructs a property proxy from another property.
    public func property<Value, Property: PropertyProtocol>(_ keyPath: KeyPath<Base, Value>, _ property: Property) -> PropertyProxy<Base, Value> where Property.Value == Value {
        return PropertyProxy(self.base, keyPath, property.signal)
    }

    /// Constructs a mutable property proxy from the signal.
    public func property<Value>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> {
        return MutablePropertyProxy(self.base, keyPath, signal, on: scheduler)
    }

    /// Constructs a mutable property proxy from the signal pipe.
    public func property<Value>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ pipe: (output: Signal<Value, Never>, input: Signal<Value, Never>.Observer), on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> {
        return self.property(keyPath, pipe.output, on: scheduler)
    }

    /// Constructs a mutable property proxy from another property.
    public func property<Value, Property: PropertyProtocol>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ property: Property, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> where Property.Value == Value {
        return self.property(keyPath, property.signal, on: scheduler)
    }
}
