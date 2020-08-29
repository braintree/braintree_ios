import UIKit

public class FakeDevice: UIDevice {
    var fakeSystemVersion:String = "8.9"
    
    override public var systemVersion: String {
        get {
            return fakeSystemVersion
        }
        set(newSystemVersion) {
            fakeSystemVersion = newSystemVersion
        }
    }
}
