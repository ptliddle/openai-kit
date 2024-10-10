// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
        .package(url: "https://github.com/ptliddle/swifty-json-schema.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "OpenAIKit",
            dependencies: [
                .product(name: "SwiftyJsonSchema", package: "swifty-json-schema"),
                .product(name: "AsyncHTTPClient", package: "async-http-client", condition: .when(platforms: [.linux, .android, .wasi, .windows])),
            ]
        ),
        .testTarget(
            name: "OpenAIKitTests",
            dependencies: ["OpenAIKit"],
            resources: [
                .copy("Resources/logo.png"),
                .copy("Resources/example.jsonl"),
                .copy("Resources/9000.mp3"),
                .copy("Resources/cena.mp3"),
            ]
        ),
    ]
)
