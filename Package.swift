// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FASnetSpoofDetection",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FASnetSpoofDetection",
            targets: ["FASnetSpoofDetection"]),
        .library(
            name: "FASnetSpoofDetectionCore",
            targets: ["FASnetSpoofDetectionCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FASnetSpoofDetection",
            dependencies: [
                "FASnetSpoofDetectionCore"
            ]),
        .target(
            name: "FASnetSpoofDetectionCore",
            dependencies: [
                .product(name: "VerIDCommonTypes", package: "Ver-ID-Common-Types-Apple")
            ]),
        .testTarget(
            name: "FASnetSpoofDetectionTests",
            dependencies: [
                "FASnetSpoofDetection",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            resources: [
                .process("Resources")
            ]),
    ]
)
