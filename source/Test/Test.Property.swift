import Nimble
import Quick
import ReactiveCocoa
import ReactiveSwift
import Rex

internal class MutablePropertySpec: QuickSpec {
    override internal func spec() {
        it("must not retain the base when bound to and from") {
            var value = ""
            let lifetime = Lifetime.make()
            let target = BindingTarget<String>(lifetime: lifetime.lifetime, action: { value = $0 })
            let pipe = Signal<String, Never>.pipe()

            var isDeallocated = false
            var foo = Foo() as Foo?
            foo!.reactive.lifetime.observeEnded({ isDeallocated = true })
            foo!.reactive.bar <~ pipe.output
            target <~ foo!.reactive.bar

            pipe.input.send(value: "foo")
            expect(foo?.bar) == "foo"
            expect(value) == "foo"

            foo = nil
            expect(isDeallocated) == true

            pipe.input.send(value: "bar")
            expect(foo?.bar).to(beNil())
            expect(value) == "foo"
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
