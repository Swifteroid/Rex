import Foundation
import ReactiveSwift

extension Signal {

    /// Maps signal into void.
    public func void() -> Signal<(), Error> {
        return self.map({ _ in })
    }
}

extension SignalProducer {

    /// Maps producer into void.
    public func void() -> SignalProducer<(), Error> {
        return self.map({ _ in })
    }
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
