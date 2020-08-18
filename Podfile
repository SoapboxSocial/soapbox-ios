# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Voicely' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for trollbox
  pod 'GoogleWebRTC'
  pod 'Alamofire'
  pod 'SwiftProtobuf'
  pod "DrawerView"
  pod 'NotificationBannerSwift'
  pod 'KeychainAccess'
  pod 'SwiftConfettiView'
  pod 'UIWindowTransitions'
  pod 'AlamofireImage'

  target 'VoicelyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'VoicelyUITests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['VALID_ARCHS'] = 'arm64'
    end
  end  
end

