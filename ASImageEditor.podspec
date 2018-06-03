#
# Be sure to run `pod lib lint ASImageEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ASImageEditor'
  s.version          = '1.0.0'
  s.summary          = 'Image editor for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This library provides the ability to crop a given image.
                       DESC

  s.homepage         = 'https://github.com/avigit/ASImageEditor.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Avigit Saha' => 'me@avigit.com' }
  s.source           = { :git => 'https://github.com/avigit/ASImageEditor.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'ASImageEditor/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ASImageEditor' => ['ASImageEditor/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
