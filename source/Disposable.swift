import Foundation
import ReactiveSwift

/// Disposable type that automatically disposes upon deinitialization.
public protocol Autodisposable: Disposable {
}

extension ScopedDisposable: Autodisposable {
}

extension Disposable {
    /// Returns autodisposable of self.
    public func autodispose() -> Autodisposable { ScopedDisposable<Self>(self) }
}
