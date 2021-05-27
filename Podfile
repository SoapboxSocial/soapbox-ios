# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Soapbox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for trollbox
  pod 'Alamofire'
  pod 'SwiftProtobuf'
  pod 'DrawerView', git: 'git@github.com:SoapboxSocial/DrawerView.git', commit: 'b0f4ad7ac60e0a5cfe089e55995115ccb7893d01'
  pod 'NotificationBannerSwift'
  pod 'KeychainAccess'
  pod 'UIWindowTransitions'
  pod 'AlamofireImage'
  pod 'GSImageViewerController'
  pod 'Swifter', git: 'git@github.com:mattdonnelly/Swifter.git'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'EasyTipView'
  pod 'Siren'
  pod 'KDCircularProgress'
  pod 'ACBAVPlayer'

  target 'SoapboxTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SoapboxUITests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end

require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-Soapbox/Pods-Soapbox-acknowledgements.plist', 'Resources/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.xcconfigs.each do |config_name, config_file|
      xcconfig_path = aggregate_target.xcconfig_path(config_name)
      config_file.save_as(xcconfig_path)
    end
  end
end

