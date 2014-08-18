#import "login_tests.js"
#import "profile_tests.js"
#import "search_tests.js"

var target = UIATarget.localTarget();
var host = target.host();

UIALogger.logStart("Running iPhone UI test suite...");

loginTests();
logInWithUser("111111", "rockpack");
profileTests();
searchTests();
logOut();
