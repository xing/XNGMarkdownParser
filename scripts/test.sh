#! /bin/bash
xcodebuild -workspace XNGMarkdownParser.xcworkspace -scheme ExampleTests -sdk iphonesimulator -destination platform='iOS Simulator',OS=7.1,name='iPhone Retina (4-inch)' clean build test | xcpretty -tc
