#! /bin/bash
xcodebuild -workspace XNGMarkdownParser.xcworkspace -scheme ExampleTests -sdk iphonesimulator clean build test | xcpretty -tc
