# [ChatSecure-Mac](https://github.com/chrisballinger/ChatSecure-Mac) [![Build Status](https://travis-ci.org/chrisballinger/ChatSecure-Mac.svg?branch=master)](https://travis-ci.org/chrisballinger/ChatSecure-Mac)

ChatSecure for Mac OS X. Work in progress.

## Goals

* Use separate sandboxed NSXPC services for XMPP, Tor, and OTR
* Store conversation logs in SQLCipher
* Usable by regular humans

## Installation

You'll need [Cocoapods](http://cocoapods.org) for most of our dependencies.
    
    $ gem install cocoapods
    
Download the source code and **don't forget** to pull down all of the submodules as well.

    $ git clone https://github.com/chrisballinger/ChatSecure-Mac.git
    $ cd ChatSecure-Mac/
    $ git submodule update --init --recursive
    
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
