# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Soapbox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for trollbox
  pod 'GoogleWebRTC'
  pod 'Alamofire'
  pod 'SwiftProtobuf'
  pod 'DrawerView', git: 'git@github.com:mkko/DrawerView.git', commit: '812a2ac4c01306817f5838da73ce46a45bc98830'
  pod 'NotificationBannerSwift'
  pod 'KeychainAccess'
  pod 'SwiftConfettiView'
  pod 'UIWindowTransitions'
  pod 'AlamofireImage'
  pod 'gRPC-Swift', '~> 1.0.0-alpha.20'
  pod 'GSImageViewerController'
  pod 'Swifter', git: 'git@github.com:mattdonnelly/Swifter.git'
  pod 'CCBottomRefreshControl'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'EasyTipView'

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
end

