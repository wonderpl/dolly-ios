var target = UIATarget.localTarget();

function editDescriptionTest() {
	var testName = "EditDescriptionTest";
	var testDescription = "Test Description";
	
	target.frontMostApp().mainWindow().buttons()["TabProfile"].tap();
	
	var editButton = target.frontMostApp().mainWindow().collectionViews()[0].buttons()["EditButton"];
	editButton.tap();
	
	var textView = 	target.frontMostApp().mainWindow().textViews()["DescriptionLabel"];
	textView.tap();
	textView.setValue(testDescription);
	target.frontMostApp().mainWindow().buttons()["save"].tap();
	
	target.delay(3);
	
	var textView = target.frontMostApp().mainWindow().collectionViews()[0].textViews()["FixedDescriptionLabel"];

	if (textView.value() == testDescription) {
		UIALogger.logPass(testName);		
	} else {
		UIALogger.logFail(testName);	
	}
}

	
function moreToEdit() {
	target.frontMostApp().mainWindow().collectionViews()[0].buttons()["ButtonMore"].tap();
	target.frontMostApp().mainWindow().buttons()["ButtonMoreEdit"].tap();
	target.frontMostApp().mainWindow().buttons()["cancel"].tap();	
}

function createNewCollection() {

	target.frontMostApp().mainWindow().collectionViews()[0].textViews()["FixedDescriptionLabel"].scrollToVisible();
	target.frontMostApp().mainWindow().collectionViews()[0].cells()["Create New Collection"].buttons()["Create New Collection"].tap();
	
	target.delay(2);
	UIATarget.localTarget().logElementTree();
		
}

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
}



editDescriptionTest();
createNewCollection();
editDescriptionTest();
