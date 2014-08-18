
var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

function findUser(user) {
	
	target.frontMostApp().mainWindow().buttons()["TabSearch"].tap();
	var searchBar = target.frontMostApp().mainWindow().searchBars()[0].searchBars()[0];
	searchBar.tap();
	searchBar.setValue(user);
	target.delay(1);
	target.frontMostApp().keyboard().typeString("\n");
	target.frontMostApp().mainWindow().buttons()["Users"].tap();
	target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.47, y:0.22}});
	
	
	target.delay(1);
	UIATarget.localTarget().logElementTree();
	var isProfile = target.frontMostApp().mainWindow().collectionViews()[1].buttons()["SecondSegmentedTab"].isValid();
	
	if(isProfile) {
		UIALogger.logMessage(user + " Valid");
		return true;
	} else { 
		UIALogger.logMessage(user + "Not valid");
		return false;
	}
	
	
	target.delay(2);
	
}


function goToEditorsPicks() {
	target.frontMostApp().mainWindow().buttons()["TabSearch"].tap();
	target.frontMostApp().mainWindow().collectionViews()[0].cells()["Editor's Choice"].tap();

	var navigationBar = app.navigationBar();

	if (app.navigationBar().name() == "Editor's Choice") {
		UIALogger.logPass("Found Editor's Choice screen");
	} else {
		UIALogger.logFail("Could not find Editor's Choice screen");	
	}	
}


function searchTests() {
    goToEditorsPicks();
}



