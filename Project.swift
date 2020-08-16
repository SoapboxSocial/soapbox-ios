import ProjectDescription

let settings = Settings(
    base: [
        "ENABLE_BITCODE": SettingValue.string("NO"),
        "CURRENT_PROJECT_VERSION": SettingValue.string("33"),
        "MARKETING_VERSION": SettingValue.string("1.3"),
    ],
    configurations: [
        CustomConfiguration.debug(
            name: "debug",
            settings: ["CODE_SIGN_ENTITLEMENTS": SettingValue.string("./Entitlements/debug.entitlements")],
            xcconfig: "./Configurations/Debug.xcconfig"
        ),
        CustomConfiguration.release(
            name: "release",
            settings: ["CODE_SIGN_ENTITLEMENTS": SettingValue.string("./Entitlements/release.entitlements")],
            xcconfig: "./Configurations/Release.xcconfig"
        ),
    ]
)

let project = Project(
    name: "Voicely",
    targets: [
        Target(
            name: "Voicely",
            platform: .iOS,
            product: .app,
            bundleId: "com.voicely.voicely",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: .iphone),
            infoPlist: "Info.plist",
            sources: ["Sources/**"],
            resources: ["Configurations/*", "Entitlements/*", "Assets.xcassets", "Localization/**/*.strings"],
            dependencies: [
                .cocoapods(path: "."),
            ],
            settings: settings
        ),
        Target(
            name: "VoicelyTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "com.voicely.voicelyTests",
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
            bundleId: "com.voicely.voicelyUITests",
            infoPlist: "UITests.plist",
            sources: "UITests/**",
            dependencies: [
                .target(name: "Voicely"),
            ]
        ),
    ]
)
