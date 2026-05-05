// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MenubarPrompter",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "MenubarPrompter")
    ]
)
