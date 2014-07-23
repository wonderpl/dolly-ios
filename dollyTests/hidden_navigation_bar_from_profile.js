var testName = "HiddenNavigationBar";
var target = UIATarget.localTarget();

function popingToDiscoverRoot() {
	
	target.frontMostApp().mainWindow().buttons()["TabSearch"].tap();
	target.frontMostApp().mainWindow().collectionViews()[0].cells()["Editor's Choice"].tap();
	target.delay(1);
	target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.52, y:0.20}});	
	target.frontMostApp().mainWindow().buttons()["TabProfile"].tap();
	target.frontMostApp().mainWindow().buttons()["TabSearch"].tap();
	
	var navBarHidden = target.frontMostApp().navigationBar().accessibilityElementsHidden;
	
	if(navBarHidden) {
		UIALogger.logFail("navigation bar is hidden");
	} else {
		UIALogger.logPass("navigation bar is not hidden");
	}
	
}

popingToDiscoverRoot();