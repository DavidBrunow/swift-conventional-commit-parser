#! /bin/sh

if [ -z "$1" ]
then
  echo "Provide a destination to copy the built product."
  exit 1
fi

# Enable all the macros to run
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

rm -rf .build

# CI=true will disable things in the package that only help users interacting
# with the code, like linting plugins.
CI=true swift build -c release --arch arm64
CI=true swift build -c release --arch x86_64

# Enable all the macros to run on CI
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool NO

lipo -create -output $1/swift-conventional-commit-parser .build/arm64-apple-macosx/release/swift-conventional-commit-parser .build/x86_64-apple-macosx/release/swift-conventional-commit-parser
