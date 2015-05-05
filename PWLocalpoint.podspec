Pod::Spec.new do |s|
  s.name         = "PWLocalpoint"
  s.version      = "3.0"
  s.summary      = "The MaaS Location Marketing SDK"
  s.homepage     = "https://github.com/xwang-phunware/maas-location-marketing-ios-sdk/"
  s.author       = { 'Phunware, Inc.' => 'http://www.phunware.com' }
  s.social_media_url = 'https://twitter.com/Phunware'

  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/phunware/maas-location-marketing-ios-sdk.git" }
  s.license      = { :type => 'Copyright', :text => 'Copyright 2014 by Phunware Inc. All rights reserved.' }

  s.public_header_files = 'Framework/PWLocalpoint.framework/Versions/A/Headers/*.h'
  s.ios.vendored_frameworks = 'Framework/PWLocalpoint.framework'
  s.dependency 'PWCore'

  s.xcconfig      = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/PWLocalpoint/**"'}
  s.ios.frameworks = 'Security', 'QuartzCore', 'SystemConfiguration', 'MobileCoreServices', 'CoreTelephony'
  s.requires_arc = true
end
