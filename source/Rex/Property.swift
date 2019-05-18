import Foundation
import ReactiveSwift
import ReactiveCocoa

extension PropertyProtocol {
    /// Sent when the property value changes.
    public var trigger: Signal<(), Never> { return self.signal.void() }
}

public protocol PropertyProxyProtocol: PropertyProtocol {
    associatedtype Base

    /// The base object owning the property.
    var base: Base { get }
}

public protocol MutablePropertyProxyProtocol: PropertyProxyProtocol, MutablePropertyProtocol {
}

extension PropertyProxyProtocol {
    public var producer: SignalProducer<Value, Never> { return self.signal.producer.prefix(value: self.value) }
}

final fileprivate class PropertyGetter<Base: AnyObject, Value> {
    public typealias Block = (_ base: Base) -> Value
    fileprivate init(_ block: @escaping Block) { self.block = block }
    private let block: Block
    func get(in base: Base) -> Value { return self.block(base) }
}

final fileprivate class PropertySetter<Base: AnyObject, Value> {
    public typealias Block = (_ value: Value, _ base: Base) -> Void
    fileprivate init(_ block: @escaping Block) { self.block = block }
    private let block: Block
    func set(_ value: Value, in base: Base) { self.block(value, base) }
}

/// Lightweight non-mutable property-like class for expressing reactive mutable properties.
final public class PropertyProxy<Base: AnyObject, Value>: PropertyProxyProtocol {
    public typealias Getter = (_ base: Base) -> Value

    public init(_ base: Base, _ getter: @escaping (_ base: Base) -> Value, _ signal: Signal<Value, Never>) {
        self.base = base
        self.getter = PropertyGetter(getter)
        self.signal = signal
    }

    public init(_ base: Base, _ keyPath: KeyPath<Base, Value>, _ signal: Signal<Value, Never>) {
        self.base = base
        self.getter = PropertyGetter({ base in base[keyPath: keyPath] })
        self.signal = signal
    }

    private let getter: PropertyGetter<Base, Value>

    /// The base object owning the property.
    public let base: Base

    /// A signal that sends the property's changes over time.
    public let signal: Signal<Value, Never>

    /// The current value of the property.
    public var value: Value {
        return self.getter.get(in: self.base)
    }
}

/// Lightweight mutable property-like struct for expressing reactive mutable properties.
final public class MutablePropertyProxy<Base: AnyObject & ReactiveExtensionsProvider, Value>: MutablePropertyProxyProtocol {
    public typealias Getter = (_ base: Base) -> Value
    public typealias Setter = (_ value: Value, _ base: Base) -> Void

    public init(_ base: Base, _ getter: @escaping (_ base: Base) -> Value, _ setter: @escaping (_ value: Value, _ base: Base) -> Void, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) {
        self.base = base
        self.getter = PropertyGetter(getter)
        self.setter = PropertySetter(setter)
        self.signal = signal
        self.scheduler = scheduler
    }

    public convenience init(_ base: Base, _ keyPath: ReferenceWritableKeyPath<Base, Value>, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) {
        self.init(base, { base in base[keyPath: keyPath] }, { value, base in base[keyPath: keyPath] = value }, signal, on: scheduler)
    }

    private let getter: PropertyGetter<Base, Value>
    private let setter: PropertySetter<Base, Value>

    /// The base object owning the property.
    public let base: Base

    /// A signal that sends the property's changes over time.
    public let signal: Signal<Value, Never>

    /// Scheduler on which the property gets written, passed into a binding target.
    public let scheduler: Scheduler?

    /// The current value of the property.
    public var value: Value {
        get { return self.getter.get(in: self.base) }
        set { self.setter.set(newValue, in: self.base) }
    }

    /// The lifetime of the property.
    public var lifetime: Lifetime {
        return self.base.reactive.lifetime
    }

    /// The property's binding target.
    public var bindingTarget: BindingTarget<Value> {
        return BindingTarget(on: self.scheduler ?? ImmediateScheduler(), lifetime: self.lifetime, action: { self.setter.set($0, in: self.base) })
    }
}

extension Reactive where Base: AnyObject {
    /// Constructs a property proxy from the getter and signal.
    public func property<Value>(_ getter: @escaping PropertyProxy<Base, Value>.Getter, _ signal: Signal<Value, Never>) -> PropertyProxy<Base, Value> {
        return PropertyProxy(self.base, getter, signal)
    }

    /// Constructs a property proxy from the key path and signal.
    public func property<Value>(_ keyPath: KeyPath<Base, Value>, _ signal: Signal<Value, Never>) -> PropertyProxy<Base, Value> {
        return PropertyProxy(self.base, keyPath, signal)
    }

    /// Constructs a property proxy from the key path signal pipe.
    public func property<Value>(_ keyPath: KeyPath<Base, Value>, _ pipe: Signal<Value, Never>.Pipe) -> PropertyProxy<Base, Value> {
        return PropertyProxy(self.base, keyPath, pipe.output)
    }

    /// Constructs a property proxy from the key path and another property.
    public func property<Value, Property: PropertyProtocol>(_ keyPath: KeyPath<Base, Value>, _ property: Property) -> PropertyProxy<Base, Value> where Property.Value == Value {
        return PropertyProxy(self.base, keyPath, property.signal)
    }
}

extension Reactive where Base: AnyObject & ReactiveExtensionsProvider {
    /// Constructs a mutable property proxy from the getter, setter, and signal.
    public func property<Value>(_ getter: @escaping MutablePropertyProxy<Base, Value>.Getter, _ setter: @escaping MutablePropertyProxy<Base, Value>.Setter, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> {
        return MutablePropertyProxy(self.base, getter, setter, signal, on: scheduler)
    }

    /// Constructs a mutable property proxy from the key path and signal.
    public func property<Value>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ signal: Signal<Value, Never>, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> {
        return MutablePropertyProxy(self.base, keyPath, signal, on: scheduler)
    }

    /// Constructs a mutable property proxy from the kay path and signal pipe.
    public func property<Value>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ pipe: Signal<Value, Never>.Pipe, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> {
        return self.property(keyPath, pipe.output, on: scheduler)
    }

    /// Constructs a mutable property proxy from the key path and another property.
    public func property<Value, Property: PropertyProtocol>(_ keyPath: ReferenceWritableKeyPath<Base, Value>, _ property: Property, on scheduler: Scheduler? = nil) -> MutablePropertyProxy<Base, Value> where Property.Value == Value {
        return self.property(keyPath, property.signal, on: scheduler)
    }
}
