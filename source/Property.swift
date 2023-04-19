import Foundation
import ReactiveSwift
import ReactiveCocoa

extension PropertyProtocol {
    /// Sent when the property value changes.
    public var changed: Signal<(), Never> { self.signal.void() }
}

/// Lightweight non-mutable property-like class for expressing reactive mutable properties.
public final class PropertyProxy<Base: AnyObject, Value>: PropertyProtocol {
    public init(_ base: Base, _ keyPath: KeyPath<Base, Value>, _ signal: Signal<Value, Never>) {
        self.base = base
        self.keyPath = keyPath
        self.signal = signal
    }

    /// The base object owning the property.
    public let base: Base

    /// The key path to access the proxied base property.
    public let keyPath: KeyPath<Base, Value>

    /// The signal that sends the property's changes over time.
    public let signal: Signal<Value, Never>

    /// The values producer of the property.
    public var producer: SignalProducer<Value, Never> { self.signal.producer.prefix(SignalProducer({ self.value })) }

    /// The current value of the property.
    public var value: Value {
        self.base[keyPath: self.keyPath]
    }
}

/// Lightweight mutable property-like struct for expressing reactive mutable properties.
public final class MutablePropertyProxy<Base: AnyObject & ReactiveExtensionsProvider, Value>: MutablePropertyProtocol {
    public init(_ base: Base, _ keyPath: ReferenceWritableKeyPath<Base, Value>, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) {
        self.base = base
        self.keyPath = keyPath
        self.signal = signal
        self.scheduler = scheduler
    }

    /// The base object owning the property.
    public let base: Base

    /// The key path to access the proxied base property.
    public let keyPath: ReferenceWritableKeyPath<Base, Value>

    /// A signal that sends the property's changes over time.
    public let signal: Signal<Value, Never>

    /// The values producer of the property.
    public var producer: SignalProducer<Value, Never> { self.signal.producer.prefix(SignalProducer({ self.value })) }

    /// Scheduler on which the property gets written. This gets passed into a binding target.
    public let scheduler: Scheduler?

    /// The current value of the property.
    public var value: Value {
        get { self.base[keyPath: self.keyPath] }
        set { self.base[keyPath: self.keyPath] = newValue }
    }

    /// The lifetime of the property is the same as of the base object.
    public var lifetime: Lifetime {
        self.base.reactive.lifetime
    }

    /// The property's binding target.
    public var bindingTarget: BindingTarget<Value> {
        BindingTarget(on: self.scheduler ?? ImmediateScheduler(), lifetime: self.lifetime, action: { [weak base = self.base, keyPath = self.keyPath] in if let base = base { base[keyPath: keyPath] = $0 } })
    }
}

extension Reactive where Base: AnyObject {
    /// Constructs a property proxy from the key path and signal.
    public func property<Value>(_ keyPath: KeyPath<Base, Value>, _ signal: Signal<Value, Never>) -> PropertyProxy<Base, Value> {
        PropertyProxy(self.base, keyPath, signal)
    }

    /// Constructs a property proxy from the key path signal pipe.
    public func property<Value>(_ keyPath: KeyPath<Base, Value>, _ pipe: Signal<Value, Never>.Pipe) -> PropertyProxy<Base, Value> {
        PropertyProxy(self.base, keyPath, pipe.output)
    }

    /// Constructs a property proxy from the key path and another property.
    public func property<Value, Property: PropertyProtocol>(_ keyPath: KeyPath<Base, Value>, _ property: Property) -> PropertyProxy<Base, Value> where Property.Value == Value {
        PropertyProxy(self.base, keyPath, property.signal)
    }
}

extension Reactive where Base: AnyObject & ReactiveExtensionsProvider {
    /// Constructs a mutable property proxy from the key path and signal.
    public func property<Value>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> {
        MutablePropertyProxy(self.base, keyPath, signal, on: scheduler)
    }

    /// Constructs a mutable property proxy from the kay path and signal pipe.
    public func property<Value>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ pipe: Signal<Value, Never>.Pipe, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> {
        self.property(keyPath, pipe.output, on: scheduler)
    }

    /// Constructs a mutable property proxy from the key path and another property.
    public func property<Value, Property: PropertyProtocol>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ property: Property, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> where Property.Value == Value {
        self.property(keyPath, property.signal, on: scheduler)
    }
}
