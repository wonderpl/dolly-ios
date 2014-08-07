#import "login_tests.js"



var target = UIATarget.localTarget();
var host = target.host();



UIALogger.logStart("Running iPhone UI test suite...");

loginTests();
