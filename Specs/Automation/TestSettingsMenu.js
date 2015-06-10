
var testName = "Settings Menu Test";

var target = UIATarget.localTarget();

target.frontMostApp().navigationBar().rightButton().tap();

var title = target.frontMostApp().mainWindow().elements().firstWithName("Settings");

if (title.isValid()) {
    UIALogger.logPass(testName);
} else {
    UIALogger.logFail(testName);
}
