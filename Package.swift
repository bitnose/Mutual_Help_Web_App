// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Mutual_Help_Web_App",
    products: [
        .library(name: "Mutual_Help_Web_App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // Leaf is Vapor's templating language
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        // Authentication
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0")

    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

