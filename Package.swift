// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let forceNIOUse = false

// These variables configure SPM so we use NIO when running on Linux but can also force NIO use when
// when debugging using the forceNIOUse variable above
let targetDependencies: [Target.Dependency] = {
    if forceNIOUse {
        return [
            Target.Dependency.product(name: "NIOHTTP1", package: "swift-nio"),
            Target.Dependency.product(name: "AsyncHTTPClient", package: "async-http-client")
        ]
    }
    else {
        return  [
            
            Target.Dependency.product(name: "NIOHTTP1", package: "swift-nio", condition: .when(platforms: [.linux, .android, .wasi, .windows])),
            Target.Dependency.product(name: "AsyncHTTPClient", package: "async-http-client", condition: .when(platforms: [.linux, .android, .wasi, .windows]))
        ]
    }
}()

let useNIOSwiftSetting: SwiftSetting = {
    if forceNIOUse {
        return .define("USE_NIO")
    }
    else {
        return .define("USE_NIO", .when(platforms: [.linux, .android, .wasi, .windows]))
    }
}()

let package = Package(
    name: "openai-kit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "OpenAIKit",
            targets: ["OpenAIKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.13.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/ptliddle/swifty-json-schema.git", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OpenAIKit",
            dependencies: targetDependencies,
            swiftSettings: [useNIOSwiftSetting]),
        .testTarget(
            name: "OpenAIKitTests",
            dependencies: ["OpenAIKit",
                           .product(name: "SwiftyJsonSchema", package: "swifty-json-schema")
                          ],
            resources: [
                .copy("Resources/logo.png"),
                .copy("Resources/example.jsonl"),
                .copy("Resources/9000.mp3"),
                .copy("Resources/cena.mp3"),
            ]
        ),
    ]
)
