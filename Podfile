source 'https://github.com/CocoaPods/Specs.git'
platform :osx, "10.10"

target :ChatSecure do
  pod 'PureLayout', '~> 2.0'
  pod 'YapDatabase/SQLCipher', '~> 2.5'
  pod 'Mantle', '~> 1.5'
end

target :XMPPService do
  # Waiting for 7.4.1 to be pushed to trunk
  pod 'CocoaAsyncSocket', :git => 'https://github.com/robbiehanson/CocoaAsyncSocket.git', :commit => 'c0bbcbcc5e039ca5d732f9844bf95c3d8ee31a5b'
  pod 'XMPPFramework', :podspec => 'Podspecs/XMPPFramework.podspec.json'
end

