// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MatrixRainApp",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "MatrixRainApp",
            targets: ["MatrixRainApp"]
        ),
    ],
    targets: [
        .target(
            name: "MatrixRainApp",
            path: "MatrixRainApp/Shared"
        ),
        .testTarget(
            name: "MatrixRainAppTests",
            dependencies: ["MatrixRainApp"]
        ),
    ]
)
