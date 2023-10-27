// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FilePath",
    platforms: [.macOS(.v10_13), .iOS(.v13)],
    products: [
        .library(name: "FilePath", targets: ["Path"]),
    ],
    targets: [
        .target(name: "Path")
    ]
)

