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

## LuaService / Prosody

Install Prosody via Homebrew tap and then modify installed package to support running within XPC sandbox.  

* `brew tap prosody/prosody`
* `brew install prosody`
* Copy `/usr/local/opt/prosody` to `prosody` directory within `LuaService` directory.
* Edit `prosody` file to support passing in container path via Lua C API.

```lua
-- Replace this at runtime with absolute path --
if not CONTAINER_DIR then
	CONTAINER_DIR="..";
end
print("container: ", CONTAINER_DIR);

package.path=string.format([[%s/libexec/share/lua/5.1/?.lua;%s/libexec/share/lua/5.1/?/init.lua]], CONTAINER_DIR, CONTAINER_DIR);
package.cpath=string.format([[%s/libexec/lib/lua/5.1/?.so]], CONTAINER_DIR);

CFG_SOURCEDIR=string.format("%s/lib/prosody", CONTAINER_DIR);
CFG_CONFIGDIR=string.format("%s/etc/prosody", CONTAINER_DIR);
CFG_PLUGINDIR=string.format("%s/lib/prosody/modules/", CONTAINER_DIR);
CFG_DATADIR=string.format("%s/var/lib/prosody", CONTAINER_DIR);
```

* Copy Homebrew dylib dependencies to `vendor` directory and modify to support loading bundled dylibs within sandbox.

```bash
cp /usr/local/opt/libidn/lib/libidn.11.dylib LuaService/vendor
cp /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib LuaService/vendor
cp /usr/local/opt/openssl/lib/libssl.1.0.0.dylib LuaService/vendor
cp /usr/local/opt/expat/lib/libexpat.1.dylib LuaService/vendor

```

* `otool -L library.so` to print linked libraries
* `install_name_tool` Changing dylib loading paths http://stackoverflow.com/a/1937331/805882
* Change library names to `@rpath/library.dylib`

```
cd LuaService/vendor
install_name_tool -id @rpath/libcrypto.1.0.0.dylib libcrypto.1.0.0.dylib
install_name_tool -id @rpath/libexpat.1.dylib libexpat.1.dylib 
install_name_tool -id @rpath/libidn.11.dylib libidn.11.dylib
install_name_tool -id @rpath/libssl.1.0.0.dylib libssl.1.0.0.dylib
install_name_tool -change /usr/local/Cellar/openssl/1.0.2j/lib/libcrypto.1.0.0.dylib @rpath/libcrypto.1.0.0.dylib libssl.1.0.0.dylib

cd LuaService/prosody/libexec/lib/lua/5.1
install_name_tool -change /usr/local/opt/openssl/lib/libssl.1.0.0.dylib @rpath/libssl.1.0.0.dylib ssl.so
install_name_tool -change /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib @rpath/libcrypto.1.0.0.dylib ssl.so
install_name_tool -change /usr/local/opt/expat/lib/libexpat.1.dylib @rpath/libexpat.1.dylib lxp.so

cd LuaService/prosody/lib/prosody/util
chmod 744 encodings.so
chmod 744 hashes.so
install_name_tool -change /usr/local/opt/libidn/lib/libidn.11.dylib @rpath/libidn.11.dylib encodings.so
install_name_tool -change /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib @rpath/libcrypto.1.0.0.dylib hashes.so
```


## TODO

* Add OS X support to CPAProxy build scripts and podspec
* Add OS X support to OTRKit build scripts and podspec
* All of it

## Author

[Chris Ballinger](https://github.com/chrisballinger)

## License

MPL 2.0
