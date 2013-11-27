
var target = UIATarget.localTarget();

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logMessage("Alert with title ’" + title + "’ encountered!");
    if (title == "Logout") {
        alert.buttons()["Logout"].tap();
        return true; // bypass default handler
    }
    return false; // use default handler
 }

target.delay(2);
//Login
target.frontMostApp().mainWindow().buttons()["Login Navigation"].tap();
target.frontMostApp().keyboard().typeString("automator");
target.frontMostApp().mainWindow().secureTextFields()["Password Field"].tap();
target.frontMostApp().keyboard().typeString("banana");
target.frontMostApp().mainWindow().buttons()["Login Action"].tap();
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();

//Navigate to channel
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["MUSIC"].tapWithOptions({tapOffset:{x:0.79, y:0.50}});
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["POP"].tapWithOptions({tapOffset:{x:0.61, y:0.50}});
target.delay(1);
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[1].cells()[0].tap();
target.delay(2);
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.delay(1);
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();

//Subscribe
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonBackCD"].tap();

//Navigate to profile
target.frontMostApp().mainWindow().buttons()["Button Nav"].tap();
target.frontMostApp().mainWindow().tableViews()["Navigation Table"].cells()["PROFILE"].tap();
target.delay(2);
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[3].cells()[0].tap();

//Unsubscribe
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonBackCD"].tap();

// Logout
target.frontMostApp().mainWindow().buttons()["Button Nav"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonSettings"].tap();
target.frontMostApp().mainWindow().popover().tableViews()["Settings Table"].cells()["Logout"].tap();
target.frontMostApp().alert();

UIALogger.logPass("Login->Subscribe->Unsubscribe->Logout");

