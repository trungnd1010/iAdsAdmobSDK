#
# Be sure to run `pod lib lint iAdsAdmobSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iAdsAdmobSDK'
  s.version          = '1.6.0'
  s.summary          = 'A short description of iAdsAdmobSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/trungnd1010/iAdsAdmobSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Trung Nguyen' => 'trungnd@ikameglobal.com' }
  s.source           = { :git => 'https://github.com/trungnd1010/iAdsAdmobSDK', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'

  s.source_files = 'iAdsAdmobSDK/Classes/**/*'
  
  s.static_framework = true
  
  s.dependency 'Google-Mobile-Ads-SDK'
  s.dependency 'iAdsCoreSDK'
  s.dependency 'iComponentsSDK'
end
