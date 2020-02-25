# Uncomment the next line to define a global platform for your project
# platform :ios, '12.1'

target 'PassengerApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PassengerApp

  pod 'GoogleMaps'
  pod 'SDWebImage'
  pod 'GoogleSignIn'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Core'
  pod 'Firebase/Database'
  pod 'Braintree'
  pod 'BraintreeDropIn'
  pod 'Braintree/PayPal'
  pod 'HandyJSON'
  pod 'CropViewController'
  pod 'Xendit'
  pod 'IQKeyboardManagerSwift'
  pod 'NVActivityIndicatorView'
  pod 'Starscream'
  pod 'NBMaterialDialogIOS'
  pod 'PayMayaSDK', '~> 0.3'
  pod 'Stripe'
  pod 'MXParallaxHeader'
  pod 'BEMCheckBox'
  pod 'JSQMessagesViewController'
  pod 'Alamofire'

  target 'PassengerAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PassengerAppUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['CLANG_WARN_UNGUARDED_AVAILABILITY'] = 'YES'
    puts "CLANG_WARN_UNGUARDED_AVAILABILITY was set to YES for all pods"
  end
end
