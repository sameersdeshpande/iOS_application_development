//
//  Policy.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/23/24.
//

import Foundation


class Policy {
    var id: Int
    var customerId: Int
    var policyType: String
    var premiumAmount: Double
    var startDate: String
    var endDate: String

    init(id: Int, customerId: Int, policyType: String, premiumAmount: Double, startDate: String, endDate: String) {
        self.id = id
        self.customerId = customerId
        self.policyType = policyType
        self.premiumAmount = premiumAmount
        self.startDate = startDate
        self.endDate = endDate
    }
}
