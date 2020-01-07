import XCTest

class BTThreeDSecureBrowserSwitchHelper_Tests: XCTestCase {

    func testProcessLookupResult_when3DSv1_constructsRedirectUrl() {

        let request = BTThreeDSecureRequest()
        request.versionRequested = .version1
        
        let lookupResult = BTThreeDSecureLookup()
        lookupResult.acsURL = URL(string: "https://acs.com")!
        lookupResult.threeDSecureVersion = "1.0"
        lookupResult.paReq = "pa.req"
        lookupResult.md = "m d"
        lookupResult.termURL = URL(string: "https://terms.com")!
                
        let actualURL = BTThreeDSecureV1BrowserSwitchHelper.url(withScheme: "com.braintreepayments.Demo.payments",
                                                                assetsURL: "https://assets.com",
                                                                threeDSecureRequest: request,
                                                                threeDSecureLookup: lookupResult)
        
        let expectedURL = URL(string:
            "https://assets.com/mobile/three-d-secure-redirect/0.2.0/index.html?" +
            "AcsUrl=https%3A%2F%2Facs.com&" +
            "PaReq=pa.req&" +
            "MD=m%20d&" +
            "TermUrl=https%3A%2F%2Fterms.com&" +
            "ReturnUrl=https%3A%2F%2Fassets.com%2Fmobile%2Fthree-d-secure-redirect%2F0.2.0%2Fredirect.html%3F" +
            "redirect_url%253Dcom.braintreepayments.Demo.payments%25253A%25252F%25252Fx-callback-url%25252Fbraintree%25252Fthreedsecure%25253F")
        
        XCTAssertEqual(actualURL, expectedURL)
    }
    
    func testProcessLookupResult_when3DSv1_andCustomButtonAndLabelTextIsRequested_constructsRedirectURLWithCustomizationParams() {
        
        let request = BTThreeDSecureRequest()
        request.versionRequested = .version1
        
        let v1UICustomization = BTThreeDSecureV1UICustomization()
        v1UICustomization.redirectButtonText = "button text"
        v1UICustomization.redirectDescription = "description text"
        request.v1UICustomization = v1UICustomization
        
        let lookupResult = BTThreeDSecureLookup()
        lookupResult.acsURL = URL(string: "https://acs.com")!
        lookupResult.threeDSecureVersion = "1.0"
        lookupResult.paReq = "pa.req"
        lookupResult.md = "m d"
        lookupResult.termURL = URL(string: "https://terms.com")!
        
        let actualURL = BTThreeDSecureV1BrowserSwitchHelper.url(withScheme: "com.braintreepayments.Demo.payments",
                                                                assetsURL: "https://assets.com",
                                                                threeDSecureRequest: request,
                                                                threeDSecureLookup: lookupResult)

        let expectedURL = URL(string:
            "https://assets.com/mobile/three-d-secure-redirect/0.2.0/index.html?" +
            "AcsUrl=https%3A%2F%2Facs.com&" +
            "PaReq=pa.req&" +
            "MD=m%20d&" +
            "TermUrl=https%3A%2F%2Fterms.com&" +
            "ReturnUrl=https%3A%2F%2Fassets.com%2Fmobile%2Fthree-d-secure-redirect%2F0.2.0%2Fredirect.html%3F" +
            "b%253Dbutton%252520text%2526d%253Ddescription%252520text%2526" +
            "redirect_url%253Dcom.braintreepayments.Demo.payments%25253A%25252F%25252Fx-callback-url%25252Fbraintree%25252Fthreedsecure%25253F")
        
        XCTAssertEqual(actualURL, expectedURL)
    }
}
