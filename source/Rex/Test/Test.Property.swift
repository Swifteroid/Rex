import Nimble
import Quick
import ReactiveCocoa
import ReactiveSwift
import Rex

internal class MutablePropertySpec: Spec {
    override internal func spec() {
        it("must not retain the base when bound to and from") {
            var isDeallocated = false
            let lifetime = Lifetime.make()
            var foo = Foo() as Foo?
            foo!.reactive.lifetime.observeEnded({ isDeallocated = true })
            foo!.reactive.bar <~ Signal.empty.producer.prefix(value: "qux")
            BindingTarget<String>(lifetime: lifetime.lifetime, action: { _ in }) <~ foo!.reactive.bar
            foo = nil
            expect(isDeallocated) == true
        }
    }
}

fileprivate class Foo: ReactiveExtensionsProvider {
    fileprivate let pipe = Signal<String, Never>.pipe()
    fileprivate var bar = "bar" { didSet { self.pipe.input.send(value: self.bar) } }
}

extension Reactive where Base: Foo {
    fileprivate var bar: MutablePropertyProxy<Base, String> { self.property(\.bar, self.base.pipe) }
}
