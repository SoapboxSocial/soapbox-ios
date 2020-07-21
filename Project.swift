import ProjectDescription

let project = Project(
    name: "Voicely",
    targets: [
        Target(
            name: "Voicely",
            platform: .iOS,
            product: .app,
            bundleId: "io.voicely.voicely",
            infoPlist: "Info.plist",
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .cocoapods(path: "."),
            ]
        ),
        Target(
            name: "VoicelyTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "io.voicely.voicelyTests",
            infoPlist: "Tests.plist",
            sources: "Tests/**",
            dependencies: [
                .target(name: "Voicely"),
            ]
        ),
        Target(
            name: "VoicelyUITests",
            platform: .iOS,
            product: .uiTests,
            bundleId: "io.voicely.voicelyUITests",
            infoPlist: "UITests.plist",
            sources: "UITests/**",
            dependencies: [
                .target(name: "Voicely"),
            ]
        ),
    ]
)
