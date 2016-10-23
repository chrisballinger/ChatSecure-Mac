# [ChatSecure-Mac](https://github.com/chrisballinger/ChatSecure-Mac) [![Build Status](https://travis-ci.org/chrisballinger/ChatSecure-Mac.svg?branch=master)](https://travis-ci.org/chrisballinger/ChatSecure-Mac)

ChatSecure for Mac OS X. Work in progress.

## Goals

* Use separate sandboxed[1] NSXPC[2] services for [XMPP](https://en.wikipedia.org/wiki/XMPP), [Tor](https://en.wikipedia.org/wiki/Tor_(anonymity_network)), and [OTR](https://en.wikipedia.org/wiki/Off-the-Record_Messaging)
* Store conversation logs in [SQLCipher](https://github.com/sqlcipher/sqlcipher)
* Usable by regular humans

Further reading:

1. [App Sandbox in Depth](https://developer.apple.com/library/mac/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html)
2. [Creating XPC Services](https://developer.apple.com/library/mac/documentation/macosx/conceptual/bpsystemstartup/Chapters/CreatingXPCServices.html)
3. [XPC - objc.io](https://www.objc.io/issues/14-mac/xpc/)

## Installation

You'll need [Cocoapods](http://cocoapods.org) for most of our dependencies.
    
    $ gem install cocoapods
    
Download the source code and **don't forget** to pull down all of the submodules as well.

    $ git clone https://github.com/chrisballinger/ChatSecure-Mac.git
    $ cd ChatSecure-Mac/
    $ git submodule update --init --recursive
    $ cp ./Podspecs/XMPPFramework.podspec.json ./Submodules/XMPPFramework/XMPPFramework.podspec.json
    
Now you'll need to build the dependencies.
    
    $ bash ./Submodules/CPAProxy/scripts/build-all.sh
    $ bash ./Submodules/OTRKit/scripts/build-all.sh
    $ pod install
    
Open `ChatSecure.xcworkspace` in Xcode and build. 

*Note*: **Don't open the `.xcodeproj`** because we're using Cocoapods.

If you're still having trouble compiling check out the Travis-CI build status and `.travis.yml` file.

## TODO

* Add OS X support to CPAProxy build scripts and podspec
* Add OS X support to OTRKit build scripts and podspec
* All of it

## Author

[Chris Ballinger](https://github.com/chrisballinger)

## License

MPL 2.0
