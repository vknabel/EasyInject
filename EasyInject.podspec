#
# Be sure to run `pod lib lint EasyInject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasyInject'
  s.version          = '0.7.0'
  s.summary          = 'A lightweight composition and dependency injection framework for Swift.'
  s.description      = <<-DESC
EasyInject is designed to be an easy to use, lightweight composition and dependency injection library. Instead of injecting instances for specific types, you provide instances for keys, without losing any type information. This enables its Injectors to be used as a composable, dynamic and typesafe data structure. It may be comparable with a Dictionary that may contain several types, without losing type safety.
                       DESC
  s.social_media_url = "https://twitter.com/vknabel"
  s.homepage         = 'https://github.com/vknabel/EasyInject'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Valentin Knabel' => 'develop@vknabel.com' }
  s.source           = { :git => 'https://github.com/vknabel/EasyInject.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
	s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source_files = 'Sources/*.swift'
end
