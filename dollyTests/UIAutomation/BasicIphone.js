
var target = UIATarget.localTarget();
var window = target.frontMostApp().mainWindow();

UIATarget.onAlert = function onAlert(alert) {
    var title = alert.name();
    UIALogger.logMessage("Alert with title ’" + title + "’ encountered!");
    if (title == "Logout") {
        alert.buttons()["Logout"].tap();
        return true; // bypass default handler
    }
    return false; // use default handler
 }


target.pushTimeout(10);
//Login
target.delay(1);
target.frontMostApp().mainWindow().buttons()["Login Navigation"].tap();
target.frontMostApp().keyboard().typeString("automator");
target.frontMostApp().mainWindow().secureTextFields()["Password Field"].tap();
target.frontMostApp().keyboard().typeString("banana\n");

//Navigate to a channel
window.staticTexts()["Page Title"].value() == "CHANNELS";
window.staticTexts()["Page Title"].withValueForKey(1, "isVisible");
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["BROWSE CATEGORIES"].tapWithOptions({tapOffset:{x:0.36, y:0.08}});
target.delay(2); // Give time for loading category data.
window.scrollViews()[0].tableViews()["Genre Table"].withValueForKey(1,"isVisible");
window.scrollViews()[0].tableViews()["Genre Table"].groups()["MUSIC"].checkIsValid();
target.frontMostApp().mainWindow().scrollViews()[0].tableViews()["Genre Table"].groups()["MUSIC"].buttons()[0].tap();
target.frontMostApp().mainWindow().scrollViews()[0].tableViews()["Genre Table"].cells()["POP"].checkIsValid();
target.frontMostApp().mainWindow().scrollViews()[0].tableViews()["Genre Table"].cells()["POP"].tap();
target.delay(2); //Allow cell data to be loaded (async call)
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[1].cells()[0].tap();
target.delay(2); //Allow videos to load
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();
target.delay(1);
target.frontMostApp().mainWindow().buttons()["onboarding button ok"].tap();

//Subscribe
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["Button Nav"].tap();

//Navigate to profile
target.frontMostApp().mainWindow().tableViews()["Navigation Table"].cells()["PROFILE"].tap();
window.staticTexts()["Page Title"].value() == "PROFILE";
target.delay(2);
target.frontMostApp().mainWindow().scrollViews()[0].staticTexts()["MY SUBSCRIPTIONS (1)"].tap();

//Select channel
target.delay(2);
target.frontMostApp().mainWindow().scrollViews()[0].collectionViews()[2].cells()[0].tap();

//Unsubscribe
target.frontMostApp().mainWindow().buttons()["ButtonSubscribe"].tap();
target.frontMostApp().mainWindow().buttons()["ButtonBackCD"].tap();

//Logout
target.frontMostApp().mainWindow().buttons()["Button Nav"].tap();
target.delay(1);
target.frontMostApp().mainWindow().buttons()["ButtonSettings"].tap();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].scrollDown();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].scrollDown();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].scrollDown();
target.frontMostApp().mainWindow().tableViews()["Settings Table"].cells()["Logout"].tap();

target.frontMostApp().alert();
target.popTimeout();

UIALogger.logPass("Login->Subscribe->Unsubscribe->Logout");