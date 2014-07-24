osascript SimulatorReset.txt

xcodebuild \
ARCHS=i386 \
ONLY_ACTIVE_ARCH=YES \
-workspace "../dolly.xcworkspace" \
-scheme "Dolly" \
-sdk iphonesimulator7.1 \
-configuration Debug \
SYMROOT="/Users/$USER/Documents/UIAutomationBuild/build" \
DSTROOT="/Users/$USER/Documents/UIAutomationBuild/build" \
TARGETED_DEVICE_FAMILY="1" \
clean \
build \
install

instruments -t BasicTest "/Users/$USER/Documents/UIAutomationBuild/build/Applications/dolly.app" -e UIASCRIPT "./login_tests.js"
