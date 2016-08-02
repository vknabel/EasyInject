#
# Be sure to run `pod lib lint EasyInject.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EasyInject'
  s.version          = '0.2.1'
  s.summary          = 'EasyInject is a micro-library for dependency injection.'
  s.description      = <<-DESC
EasyInject is a micro-library for dependency injection.
It is intended to be lightweight and platform independent.
                       DESC
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
