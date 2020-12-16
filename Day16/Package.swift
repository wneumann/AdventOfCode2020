// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "day16",
    dependencies: [
	.package(
    		url: "https://github.com/apple/swift-se0270-range-set",
    		from: "1.0.0"),
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "day16",
            dependencies: [.product(name: "SE0270_RangeSet", package: "swift-se0270-range-set"),]),
        .testTarget(
            name: "day16Tests",
            dependencies: ["day16"]),
    ]
)
