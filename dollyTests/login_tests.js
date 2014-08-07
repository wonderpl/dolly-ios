
DELAY=5;
var target = UIATarget.localTarget();


function logInWithUser(userName, password) {
	var testName = "logInWithUser";
	
	UIALogger.logStart(testName);
    
	UIALogger.logMessage("Tapping user name field");
	var userNameTextField = target.frontMostApp().mainWindow().textFields()["Username Field"].textFields()["Username Field"];
	userNameTextField.setValue(userName);
    
	UIALogger.logMessage("Tapping password field");
	var passwordTextField = target.frontMostApp().mainWindow().secureTextFields()["Password Field"].secureTextFields()["Password Field"];
	passwordTextField.tap();
	passwordTextField.setValue(password);
	
	UIALogger.logMessage("Tapping Log in button");
	target.frontMostApp().navigationBar().rightButton().tap();
	
	target.delay(2);
	
	if (feedCheck()) {
		logOut();
		return true;
	} else {
		return false;
	}

}

function logOut() {
	UIALogger.logStart("logInWithUser");
	
	UIALogger.logMessage("Tapping on Profile tab");
	target.frontMostApp().mainWindow().buttons()["TabProfile"].tap();
	
	UIALogger.logMessage("Tapping on Profile more button");
	target.frontMostApp().mainWindow().collectionViews()[0].buttons()["ButtonMore"].tap();
	
	UIALogger.logMessage("Tapping on logout button");
	target.frontMostApp().mainWindow().buttons()["Logout"].tap();
	
	target.delay(3);
}


function feedCheck() {
	
	var destinationScreen = "MY FEED";
	var isFeed = target.frontMostApp().navigationBar().name() == destinationScreen;
	if (isFeed) {
		UIALogger.logMessage("feedcheck true");
		return true;
	} else {
		UIALogger.logMessage("feedcheck false");
		return false;
	}
}

function forgotPassword() {
	
	var testName = "forgotPassword";
	
	UIALogger.logStart(testName);
	
	target.frontMostApp().mainWindow().buttons()["Login Navigation"].tap();
	target.frontMostApp().mainWindow().buttons()["Forgot password?"].tap();
    
	target.delay(1);
	
	var textField = target.frontMostApp().mainWindow().textFields()[0].textFields()[0];
	textField.tap();
	
	textField.setValue("noreply@rockpack.com");
    
	target.frontMostApp().navigationBar().rightButton().tap();
	target.delay(2);
	
	
 	var alertView = target.frontMostApp().alert();
	
	if (alertView.isValid) {
		target.frontMostApp().alert().cancelButton().tap();
		UIALogger.logPass(testName);
	} else {
		UIALogger.logFail(testName);
	}
	
	target.delay(5);
	
	target.frontMostApp().mainWindow().buttons()["Forgot password?"].tap();
	target.delay(1);
	
	textField.tap();
	target.frontMostApp().mainWindow().textFields()[0].textFields()[0].setValue("aa");
    
    
	if(alertView.isValid) {
		UIALogger.logFail(testName);
	} else {
		UIALogger.logPass(testName);
	}
	
	target.frontMostApp().navigationBar().leftButton().tap();
	target.frontMostApp().navigationBar().leftButton().tap();
	
}


UIATarget.onAlert = function onAlert(alert) {
    
    var title = alert.name();
    
    UIALogger.logWarning("Alert with title '" + title + "' encountered.");
    
    if (title == "Password Reset") {
        return true;
    }

    return false;
}


function loginTests() {

    
    target.delay(5);
    
    var logInButton = target.frontMostApp().mainWindow().buttons()["Login Navigation"];
    UIALogger.logMessage("Tapping default Log in button");
    logInButton.tap();
    if (logInWithUser("111111","rockpack")) {
        UIALogger.logMessage("Pass test");
        UIALogger.logPass("logInWith real user");
    } else {
        UIALogger.logFail("logInWith real user");
    }
    
    logInButton.tap();
    
    if (logInWithUser("213eu8qdoji","")) {
        UIALogger.logFail("log in with user name only");
    } else {
        UIALogger.logMessage("Pass test");
        UIALogger.logPass("log in with user name only");
    }
    
    if (logInWithUser("","")) {
        UIALogger.logFail("log in with no data");
    } else {
        UIALogger.logMessage("Pass test");
        UIALogger.logPass("log in with no data");
    }
    
    if (logInWithUser("qwdqwddqwd","asdad((£U*(@OIJ")) {
        UIALogger.logFail("log in with invalid user");
    } else {
        UIALogger.logMessage("Pass test");
        UIALogger.logPass("log in with invalid user");
    }
    
    target.frontMostApp().navigationBar().leftButton().tap();
    forgotPassword();
    

}

