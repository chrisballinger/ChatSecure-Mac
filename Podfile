source 'https://github.com/CocoaPods/Specs.git'
platform :osx, "10.10"
use_frameworks!

abstract_target 'ChatSecurePods' do
	pod 'XMPPFramework', :path => 'Submodules/XMPPFramework/XMPPFramework.podspec'
	pod 'CocoaAsyncSocket', :git => 'https://github.com/robbiehanson/CocoaAsyncSocket.git', :commit => 'f3cf8a6fb27de57bd70b40cf4173d695d4a17b22'

	target 'ChatSecure' do
		pod 'PureLayout', '~> 3.0'
  	pod 'YapDatabase/SQLCipher', '~> 2.9'
  	pod 'Mantle', '~> 2.1'
  	target 'ChatSecureTests'
	end

	target 'XMPPService'
end
