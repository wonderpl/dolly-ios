osascript ./SimulatorReset.txt

xcodebuild \
ARCHS=i386 \
ONLY_ACTIVE_ARCH=NO \
-workspace "../../rockpack.xcworkspace" \
-scheme "rockpack" \
-sdk iphonesimulator6.1 \
-configuration Debug \
SYMROOT="/Users/$USER/Documents/UIAutomationBuild/build" \
DSTROOT="/Users/$USER/Documents/UIAutomationBuild/build" \
TARGETED_DEVICE_FAMILY="1" \
clean \
build \
install

./choose_sim_device "iPhone"

instruments -t BasicTest "/Users/$USER/Documents/UIAutomationBuild/build/Applications/rockpack.app" -e UIASCRIPT "./BasicIphone.js" -e UIARESULTSPATH "./result"

ERR=$(grep -c "<string>Error</string>" result/Run\ 1/Automation\ Results.plist)
FAIL=$(grep -c "<string>Fail</string>" result/Run\ 1/Automation\ Results.plist)

rm -r instrumentscli*.trace
rm -r result/Run*

echo "number of Errors"
echo $ERR
if [ "$ERR" == "0" ]; then
    echo "Great!"
else
    echo "error"
	exit 1
fi
echo "number of Fails"
echo $FAIL
if  [ "$FAIL" == "0" ]; then
	echo "Great!"
else
	echo "failure"
	exit 1
fi