//
//  Policy.swift
//  Assignment_10
//
//  Created by Sameer Shashikant Deshpande on 11/15/24.
//
import Foundation

struct Policy: Identifiable, Decodable {
    var id: Int
    var customerId: Int
    var policyType: String?
    var premiumAmount: Double?
    var startDate: Date?
    var endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case customerId
        case policyType
        case premiumAmount
        case startDate
        case endDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        customerId = try container.decode(Int.self, forKey: .customerId)
        policyType = try container.decodeIfPresent(String.self, forKey: .policyType)
        premiumAmount = try container.decodeIfPresent(Double.self, forKey: .premiumAmount)
        if let startTimestamp = try container.decodeIfPresent(Int.self, forKey: .startDate) {
            startDate = Date(timeIntervalSince1970: TimeInterval(startTimestamp))
        } else {
            startDate = nil
        }
        if let endTimestamp = try container.decodeIfPresent(Int.self, forKey: .endDate) {
            endDate = Date(timeIntervalSince1970: TimeInterval(endTimestamp))
        } else {
            endDate = nil
        }
    }
    // Custom initializer for manual creation of a Policy object
    init(id: Int, customerId: Int, policyType: String?, premiumAmount: Double?, startDate: Date?, endDate: Date?) {
        self.id = id
        self.customerId = customerId
        self.policyType = policyType
        self.premiumAmount = premiumAmount
        self.startDate = startDate
        self.endDate = endDate
    }
}
