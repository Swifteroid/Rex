# Rex 🦖

ReactiveSwift and ReactiveCocoa extensions and utilities.

## API Guidelines

These guidelines aim at improving consistency and intuitiveness of reactive API design.

### Signal Naming

While ReactiveSwift and ReactiveCocoa tend to use past sense for naming signal events, like `Life.ended` or `Action.completed`, Apple prefers emphatic form, like `NSView.didHide` or `AVCaptureSessionDidStartRunning`, complimented by auxiliary verbs (`will`, `did`, `was`). Moreover, Swift also uses emphatic form in the language itself, like `willSet` and `didSet` property observers, so it's safe to assume that this is the overall convention at Apple. Hence, events should use emphatic naming form with auxiliary verbs and follow established Apple's convention as closely as possible.

```swift
extension Reactive {
    var willAppear: Signal<…>
    var didAppear: Signal<…>
}
```
