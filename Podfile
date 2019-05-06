# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

workspace 'SimpleAppStore.xcworkspace'

def shared_pods
  # Pods for ReactiveDataSource, which also require include in main app target (SimpleAppStore)
  pod 'ReactiveSwift'
  pod 'ReactiveCocoa', '~> 10.0'
  pod 'FlexibleDiff'
end

target 'SimpleAppStore' do
  project 'SimpleAppStore.xcodeproj'
  
  use_frameworks!
  
  shared_pods
  # Pods for SimpleAppStore
  pod 'Alamofire', '~> 4.8'
  pod 'AlamofireNetworkActivityIndicator', '~> 2.4'
  pod 'SkeletonView'
  pod 'Kingfisher'
  
  target 'SimpleAppStoreTests' do
    pod 'Nimble', '~> 8.0'
  end
  
end

target 'ReactiveDataSource' do
  project 'Library/ReactiveDataSource/ReactiveDataSource.xcodeproj'
  
  shared_pods
  use_frameworks!
end


