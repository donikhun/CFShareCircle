#
# Be sure to run `pod spec lint Example.podspec.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "CFShareCircle"
  s.version      = "1.0.0.1"
  s.summary      = "CFShareCircle is a user interface component for iOS that can be integrated into an app as a sharing mechanism for any kind of content."
  s.homepage     = "https://github.com/bfcrampton/CFShareCircle"
  s.license      = 'MIT'
  s.author       = { "Bryan Crampton" => "bryancrampton@me.com" }
  s.source       = { :git => "https://github.com/bfcrampton/CFShareCircle.git", :tag => "1.0.0" }
  s.platform     = :ios, '5.0'
  s.source_files = 'Classes', 'Classes/**/*.{h,m}'
  s.resources = "Resources/*"
  s.dependency 'Facebook-iOS-SDK', '3.19.0'
  s.dependency 'Pinterest-iOS', '2.3'
  s.dependency 'MGInstagram', '0.0.1'
  s.frameworks = 'UIKit', 'QuartzCore', 'CoreGraphics', 'Twitter', 'Accounts', 'Social'
  s.requires_arc = true
end
