# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'StockMarketApp' do
  # Uncomment this line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  source 'https://github.com/CocoaPods/Specs.git'
  platform :ios, '8.0'
  # Pods for StockMarketApp

  #AFNetworking requires NS* type classes which Swift 3.0 doesn't allow so can't use it
  #pod 'AFNetworking', '~> 3.0'
  #pod 'Alamofire', '~> 4.0'
  pod 'Alamofire'

  target 'StockMarketAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'StockMarketAppUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
