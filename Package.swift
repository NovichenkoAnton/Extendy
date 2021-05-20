// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Extendy",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "Extendy",
            targets: ["Extendy"]
        ),
    ],
    targets: [
        .target(
            name: "Extendy",
            path: "Sources"
        ),
    ]
)
