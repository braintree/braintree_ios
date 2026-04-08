import XCTest
@testable import BraintreeShopperInsights

class BTPayPalCampaign_Tests: XCTestCase {
    
    func testBTPayPalCampaign_initializesWithId() {
        let campaign = BTPayPalCampaign(id: "test-campaign-123")
        
        XCTAssertEqual(campaign.id, "test-campaign-123")
    }
    
    func testBTPayPalCampaign_initializesWithEmptyId() {
        let campaign = BTPayPalCampaign(id: "")
        
        XCTAssertEqual(campaign.id, "")
    }
    
    func testBTPayPalCampaign_initializesWithSpecialCharacters() {
        let campaign = BTPayPalCampaign(id: "campaign-with-special_chars-#123")
        
        XCTAssertEqual(campaign.id, "campaign-with-special_chars-#123")
    }
    
    func testBTPayPalCampaign_encodesToJSON() throws {
        let campaign = BTPayPalCampaign(id: "test-campaign-456")
        let encoder = JSONEncoder()
        
        let jsonData = try encoder.encode(campaign)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
        
        XCTAssertNotNil(jsonObject)
        XCTAssertEqual(jsonObject?["id"] as? String, "test-campaign-456")
    }
    
    func testBTPayPalCampaign_encodesArrayToJSON() throws {
        let campaigns = [
            BTPayPalCampaign(id: "campaign-1"),
            BTPayPalCampaign(id: "campaign-2"),
            BTPayPalCampaign(id: "campaign-3")
        ]
        let encoder = JSONEncoder()
        
        let jsonData = try encoder.encode(campaigns)
        let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]]
        
        XCTAssertNotNil(jsonArray)
        XCTAssertEqual(jsonArray?.count, 3)
        XCTAssertEqual(jsonArray?[0]["id"] as? String, "campaign-1")
        XCTAssertEqual(jsonArray?[1]["id"] as? String, "campaign-2")
        XCTAssertEqual(jsonArray?[2]["id"] as? String, "campaign-3")
    }
    
    func testBTPayPalCampaign_encodesEmptyArrayToJSON() throws {
        let campaigns: [BTPayPalCampaign] = []
        let encoder = JSONEncoder()
        
        let jsonData = try encoder.encode(campaigns)
        let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]]
        
        XCTAssertNotNil(jsonArray)
        XCTAssertEqual(jsonArray?.count, 0)
    }
}
