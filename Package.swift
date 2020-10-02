// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "EasyInject",
    products: [
    .library(name: "EasyInject", targets: ["EasyInject"])
    ],
    targets: [
        .target(name: "EasyInject"),
        .testTarget(name: "EasyInjectTests", dependencies: ["EasyInject"])
    ]
)
