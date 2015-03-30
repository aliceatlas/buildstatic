# BuildStatic #

This repository contains an approach to building Clang modules containing Swift code as static libraries. The Xcode toolchain currently lacks a workflow for this, but it's doable. "[Creation of pure Swift module](http://railsware.com/blog/2014/06/26/creation-of-pure-swift-module/)" and [robertjpayne/SwiftStaticCompile.rb](https://gist.github.com/robertjpayne/5dacd4d31299165c28ab) have been informative but are limited in several ways; I've attempted to put together a solution which integrates smoothly into a normal Xcode workflow, supports most of the same things you can do by building a module as an ordinary framework, and is easy to use whether building or using a module.

The main use cases for this are:

* Using Swift modules in products being deployed for iOS 7, which doesn't support apps with bundled dynamic frameworks
* Making modules more convenient to use in product types that lack a wrapper directory (e.g. command-line tools)
* Distributing Swift modules without source code when they might be used in one of the above contexts
* Using modules to improve organization within a project without having to include a bunch of extra frameworks in the built product, but without having to manually manage modulemap files either

## Approach ##

It seems you can take a framework and replace the enclosed dynamic library with a static library and continue using it pretty much normally — including it with a `-framework` flag to clang, swiftc, etc. will make the module available for importation, and when linking, it's incorporated into the built product statically. One thing to be aware of is that auto-linking doesn't work in this case, so you do need to include any static frameworks in your target or command lines manually.

Next, when building a framework with Xcode, it's pretty straightforward to use a Run Script build phase to build a new static library to replace the dynamic one Xcode will have already built: there's an intermediate file of type `LinkFileList` that lists object files to be compiled into the product, so we just use libtool to take those and make a static library instead. (Ideally we'd be able to change the Mach-O Type build setting to *Static Library* and have it build that way to begin with, but doing that with a target containing Swift code is what currently isn't supported by Xcode  ([rdar://17233107](http://openradar.appspot.com/radar?id=5536341827780608)). *Relocatable Object File* gets you most of the way to what this script does, but executables incorporating modules built that way will be larger.)

This is as seamless as I've been able to get it, but improvements are welcome.

## Usage ##

To make a framework target build statically:

1. Add `BuildStaticInPlace.sh` or `BuildStaticSeparate.sh` as a **Run Script** build phase (the former results in a static framework as the target's only product; the latter makes a separate static copy in a Static subdirectory of the build products directory)
2. Under **Input Files**, add `$(LD_DEPENDENCY_INFO_FILE)`
3. Under **Output Files**, add `$(BUILT_PRODUCTS_DIR)/$(EXECUTABLE_PATH)`

If you're using BuildStaticInPlace and your target's Debug Information Format build setting is set to *DWARF with dSYM File*, this needs to be replaced with *DWARF*.

Adding those entries under Input and Output Files is intended to keep Xcode from running the script when nothing was recompiled; I've found (with credit to "[Speeding Up Custom Script Phases](http://indiestack.com/2014/12/speeding-up-custom-script-phases/)") that you might need to close and reopen your project before this takes effect.

To use a static framework in another target (including in a separate project):

1. Add it to the target (via the **Target Membership** pane, or by adding it to the **Link Binary With Libraries** build phase)

## Todo ##

* Should rewrite the generated module.modulemap to add "link" commands for other libraries the module depends on. Currently you will have to manually add them to any target including a static module
* Warn about and/or clean up items found in the framework wrapper that are irrelevant when the library is static 
* Make an Xcode template for creating a framework target already configured to build statically
* Experiment with implementing support for this method in CocoaPods?

— Alice Atlas