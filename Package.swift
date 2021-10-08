// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleLogging",
    
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .watchOS(.v4),
        .tvOS(.v11),
    ],
    
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SimpleLogging",
            targets: ["SimpleLogging"]),
        
        // DEPRECATED: Does not play nice with App Store requirements
        .library(
            name: "SimpleLogging_dynamic",
            type: .dynamic,
            targets: ["SimpleLogging"]),
        
        .library(
            name: "SimpleLoggingDynamic",
            type: .dynamic,
            targets: ["SimpleLogging"]),
    ],
    
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "LazyContainers", url: "https://github.com/RougeWare/Swift-Lazy-Containers.git", from: "4.0.0"),
        .package(name: "FunctionTools", url: "https://github.com/RougeWare/Swift-Function-Tools.git", from: "1.2.3"),
    ],
    
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SimpleLogging",
            dependencies: ["LazyContainers", "FunctionTools"]),
        .testTarget(
            name: "SimpleLoggingTests",
            dependencies: ["SimpleLogging"]),
    ]
)
