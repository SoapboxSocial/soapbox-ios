import ProjectDescription

let settings = Settings(
    base: [
        "ENABLE_BITCODE": SettingValue.string("NO"),
        "CURRENT_PROJECT_VERSION": SettingValue.string(""),
        "MARKETING_VERSION": SettingValue.string("0.1"),
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
    name: "Soapbox",
    targets: [
        Target(
            name: "Soapbox",
            platform: .iOS,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTarget: .iOS(targetVersion: "13.0", devices: .iphone),
            infoPlist: "Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**", "Configurations/*", "Entitlements/*", "Assets.xcassets", "Localization/**/*.strings"],
            dependencies: [
                .cocoapods(path: "."),
                .xcFramework(path: "../WebRTC.xcframework")
            ],
            settings: settings
        ),
        Target(
            name: "SoapboxTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "app.social.soapboxTests",
            infoPlist: "Tests.plist",
            sources: "Tests/**",
            dependencies: [
                .target(name: "Soapbox"),
            ]
        ),
        Target(
            name: "SoapboxUITests",
            platform: .iOS,
            product: .uiTests,
            bundleId: "app.social.soapboxUITests",
            infoPlist: "UITests.plist",
            sources: "UITests/**",
            dependencies: [
                .target(name: "Soapbox"),
            ]
        ),
    ]
)
