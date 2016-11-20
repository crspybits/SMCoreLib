#
# Be sure to run `pod lib lint SMCoreLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SMCoreLib'
  s.version          = '0.0.13'
  s.summary      = 'Spastic Muffin Core Library for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  	Objective-C and Swift classes to support Spastic Muffin code.
                       DESC

  s.homepage     = "https://github.com/crspybits/SMCoreLib.git"
  s.license      = { :type => "GPL3", :file => "LICENSE.txt" }
  s.author             = { "Christopher Prince" => "chris@SpasticMuffin.biz" }

  s.platform     = :ios, "8.0"
  
  s.source       = { :git => "https://github.com/crspybits/SMCoreLib.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'

  # 'SMCoreLib/Classes/**' matches directories recursively, but doesn't match any files!
  s.source_files = 'SMCoreLib/Classes/**/*.{h,m,swift}'
  
  s.resources = "SMCoreLib/Assets/*.xcassets"
  
  # s.resource_bundles = {
  #   'SMCoreLib' => ['SMCoreLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.requires_arc = true

  s.pod_target_xcconfig = {
     # I haven't been able to get a DEBUG flag set in a Cocoapod, without these
	'GCC_PREPROCESSOR_DEFINITIONS[config=Debug]' => 'DEBUG=1',
	'OTHER_SWIFT_FLAGS[config=Debug]' => '-DDEBUG'
  }

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  
  s.dependency 'AFNetworking'
  s.dependency 'HPTextViewTapGestureRecognizer', '~> 0.1'
  s.dependency 'Reachability'
end
