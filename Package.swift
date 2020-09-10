// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LifeWikiScraper",
    platforms: [
         .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "LifeWikiScraper",
            targets: ["LifeWikiScraper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.2"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftRLE.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Main",
            dependencies: ["LifeWikiScraper"]),
        .target(
            name: "LifeWikiScraper",
            dependencies: ["SwiftSoup", "SwiftRLE"]),
        .testTarget(
            name: "ScraperTests",
            dependencies: ["LifeWikiScraper"]),
    ]
)
