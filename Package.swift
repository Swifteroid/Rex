// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Rex",
    platforms: [
        .macOS(.v10_10)
    ],
    products: [
        .library(name: "Rex", targets: ["Rex"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "10.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "5.0.0"),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveCocoa.git", from: "12.0.0"),
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "7.0.0"),
    ],
    targets: [
        .target(name: "Rex", dependencies: ["ReactiveCocoa", "ReactiveSwift"], path: "source", exclude: ["Test"]),
        .testTarget(name: "Rex-Test", dependencies: ["Rex", "Quick", "Nimble"], path: "source/Test"),
    ],
    swiftLanguageVersions: [.v5]
)
