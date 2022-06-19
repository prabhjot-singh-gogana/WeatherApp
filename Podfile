# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
    pod 'RxSwift', '6.5.0'
    pod 'RxCocoa', '6.5.0'
end

target 'WeatherApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!
  # Pods for WeatherApp
  use_modular_headers!
  shared_pods

  target 'WeatherAppTests' do
    inherit! :search_paths
      shared_pods
    # Pods for testing
  end

end
