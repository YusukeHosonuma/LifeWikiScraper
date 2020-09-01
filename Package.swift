// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Scraper",
    platforms: [
         .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftRLE.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Main",
            dependencies: ["Scraper"]),
        .target(
            name: "Scraper",
            dependencies: ["SwiftSoup", "SwiftRLE"]),
        .testTarget(
            name: "ScraperTests",
            dependencies: ["Scraper"]),
    ]
)
