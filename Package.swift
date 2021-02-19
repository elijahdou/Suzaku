// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Suzaku",
    platforms: [.iOS(.v10), .macOS(.v10_12),],
    products: [
        .library(name: "Suzaku", targets: ["Suzaku"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Suzaku", path: "Suzaku/Classes"),
    ],
    swiftLanguageVersions: [.v5]
)
