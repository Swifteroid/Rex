import Foundation
import ReactiveSwift

/// Reflects existing schedulers behaviour, see specific schedulers for details.
public enum ObservationMode {
    /// Observation on ui scheduler.
    case ui

    /// Observation asynchronously on the main queue.
    case main

    /// Observation asynchronously on new queue scheduler. 
    case asynchronous

    /// Observation asynchronously on new queue scheduler then on ui scheduler.
    case asynchronousUI
}

extension Signal {

    /// Forwards all events onto corresponding observation scheduler.
    private func observe(in mode: ObservationMode?) -> Signal<Value, Error> {
        guard let mode: ObservationMode = mode else { return self }
        switch mode {
            case .ui: return self.observe(on: UIScheduler())
            case .main: return self.observe(on: QueueScheduler.main)
            case .asynchronous: return self.observe(on: QueueScheduler())
            case .asynchronousUI: return self.observe(on: QueueScheduler()).observe(on: UIScheduler())
        }
    }

    @discardableResult public func observe(_ mode: ObservationMode? = nil, value: ((Value) -> Void)? = nil, failed: ((Error) -> Void)? = nil, completed: (() -> Void)? = nil, interrupted: (() -> Void)? = nil) -> Disposable? {
        return self.observe(in: mode).observe(.init(value: value, failed: failed, completed: completed, interrupted: interrupted))
    }

    @discardableResult public func observe(_ mode: ObservationMode?, _ value: @escaping (Value) -> Void) -> Disposable? {
        return self.observe(mode, value: value)
    }

    /// Observes events in the given scope during it's lifetime and passes scope into each callback. This a shorthand for the regular
    /// observing without boilerplate for lifetime and weak self handling.
    @discardableResult public func observe<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, value: ((Scope, Value) -> Void)? = nil, failed: ((Scope, Error) -> Void)? = nil, completed: ((Scope) -> Void)? = nil, interrupted: ((Scope) -> Void)? = nil) -> Disposable? {
        guard let scope: Scope = scope else { return nil }
        return self.take(duringLifetimeOf: scope).observe(mode,
            value: value.map({ block in { [unowned scope] in block(scope, $0) } }),
            failed: failed.map({ block in { [unowned scope] in block(scope, $0) } }),
            completed: completed.map({ block in { [unowned scope] in block(scope) } }),
            interrupted: interrupted.map({ block in { [unowned scope] in block(scope) } })
        )
    }

    @discardableResult public func observe<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, _ value: @escaping (Scope, Value) -> Void) -> Disposable? {
        return self.observe(mode, in: scope, value: value)
    }

    @discardableResult public func observe<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, value: ((Scope) -> Void)? = nil, failed: ((Scope, Error) -> Void)? = nil, completed: ((Scope) -> Void)? = nil, interrupted: ((Scope) -> Void)? = nil) -> Disposable? where Value == () {
        return self.observe(mode, in: scope, value: value.map({ block in { scope, _ in block(scope) } }), failed: failed, completed: completed, interrupted: interrupted)
    }

    @discardableResult public func observe<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, _ value: @escaping (Scope) -> Void) -> Disposable? where Value == () {
        return self.observe(mode, in: scope, value: value)
    }

    @discardableResult public func observe<Scope: AnyObject, V1, V2>(_ mode: ObservationMode? = nil, in scope: Scope?, value: ((Scope, V1, V2) -> Void)? = nil, failed: ((Scope, Error) -> Void)? = nil, completed: ((Scope) -> Void)? = nil, interrupted: ((Scope) -> Void)? = nil) -> Disposable? where Value == (V1, V2) {
        return self.observe(mode, in: scope, value: value.map({ block in { scope, value in block(scope, value.0, value.1) } }), failed: failed, completed: completed, interrupted: interrupted)
    }

    @discardableResult public func observe<Scope: AnyObject, V1, V2>(_ mode: ObservationMode? = nil, in scope: Scope?, _ value: @escaping (Scope, V1, V2) -> Void) -> Disposable? where Value == (V1, V2) {
        return self.observe(mode, in: scope, value: value)
    }
}

extension SignalProducer {

    /// Forwards all events onto corresponding observation scheduler.
    private func observe(in mode: ObservationMode?) -> SignalProducer<Value, Error> {
        guard let mode: ObservationMode = mode else { return self }
        switch mode {
            case .ui: return self.observe(on: UIScheduler())
            case .main: return self.observe(on: QueueScheduler.main)
            case .asynchronous: return self.observe(on: QueueScheduler())
            case .asynchronousUI: return self.observe(on: QueueScheduler()).observe(on: UIScheduler())
        }
    }

    @discardableResult public func start(_ mode: ObservationMode? = nil, value: ((Value) -> Void)? = nil, failed: ((Error) -> Void)? = nil, completed: (() -> Void)? = nil, interrupted: (() -> Void)? = nil) -> Disposable? {
        return self.observe(in: mode).start(.init(value: value, failed: failed, completed: completed, interrupted: interrupted))
    }

    @discardableResult public func start(_ mode: ObservationMode?, _ value: @escaping (Value) -> Void) -> Disposable? {
        return self.start(mode, value: value)
    }

    /// Starts observing signal events in the given scope during it's lifetime and passes scope into each callback. This a shorthand for the regular
    /// observing without boilerplate for lifetime and weak self handling.
    @discardableResult public func start<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, value: ((Scope, Value) -> Void)? = nil, failed: ((Scope, Error) -> Void)? = nil, completed: ((Scope) -> Void)? = nil, interrupted: ((Scope) -> Void)? = nil) -> Disposable? {
        guard let scope: Scope = scope else { return nil }
        return self.take(duringLifetimeOf: scope).start(mode,
            value: value.map({ block in { [unowned scope] in block(scope, $0) } }),
            failed: failed.map({ block in { [unowned scope] in block(scope, $0) } }),
            completed: completed.map({ block in { [unowned scope] in block(scope) } }),
            interrupted: interrupted.map({ block in { [unowned scope] in block(scope) } })
        )
    }

    @discardableResult public func start<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, _ value: @escaping (Scope, Value) -> Void) -> Disposable? {
        return self.start(mode, in: scope, value: value)
    }

    @discardableResult public func start<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, value: ((Scope) -> Void)? = nil, failed: ((Scope, Error) -> Void)? = nil, completed: ((Scope) -> Void)? = nil, interrupted: ((Scope) -> Void)? = nil) -> Disposable? where Value == () {
        return self.start(mode, in: scope, value: value.map({ block in { scope, _ in block(scope) } }), failed: failed, completed: completed, interrupted: interrupted)
    }

    @discardableResult public func start<Scope: AnyObject>(_ mode: ObservationMode? = nil, in scope: Scope?, _ value: @escaping (Scope) -> Void) -> Disposable? where Value == () {
        return self.start(mode, in: scope, value: value)
    }

    @discardableResult public func start<Scope: AnyObject, V1, V2>(_ mode: ObservationMode? = nil, in scope: Scope?, value: ((Scope, V1, V2) -> Void)? = nil, failed: ((Scope, Error) -> Void)? = nil, completed: ((Scope) -> Void)? = nil, interrupted: ((Scope) -> Void)? = nil) -> Disposable? where Value == (V1, V2) {
        return self.start(mode, in: scope, value: value.map({ block in { scope, value in block(scope, value.0, value.1) } }), failed: failed, completed: completed, interrupted: interrupted)
    }

    @discardableResult public func start<Scope: AnyObject, V1, V2>(_ mode: ObservationMode? = nil, in scope: Scope?, _ value: @escaping (Scope, V1, V2) -> Void) -> Disposable? where Value == (V1, V2) {
        return self.start(mode, in: scope, value: value)
    }
}
