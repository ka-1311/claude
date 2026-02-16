// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "KAApps",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "KAWindow",
            path: "KAWindow",
            exclude: ["Info.plist", "KAWindow.entitlements", "Assets.xcassets"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("ServiceManagement"),
            ]
        ),
        .executableTarget(
            name: "KAPointer",
            path: "KAPointer",
            exclude: ["Info.plist", "KAPointer.entitlements"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("QuartzCore"),
            ]
        )
    ]
)
