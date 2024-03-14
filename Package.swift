// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ModalSheet",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ModalSheet",
            targets: ["ModalSheet"]),
    ],
    targets: [
        .target(
            name: "ModalSheet"),
        .testTarget(
            name: "ModalSheetTests",
            dependencies: ["ModalSheet"]),
    ]
)
