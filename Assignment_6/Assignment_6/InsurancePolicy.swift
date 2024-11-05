//
//  InsurancePolicy.swift
//  Assignment_6
//
//  Created by Sameer Shashikant Deshpande on 10/20/24.
//

import Foundation

class InsurancePolicy {
    var id: Int
    var customerId: Int
    var policyType: String
    var premiumAmount: Double
    var startDate: Date
    var endDate: Date
    
    init(id: Int, customerId: Int, policyType: String, premiumAmount: Double, startDate: Date, endDate: Date) {
        self.id = id
        self.customerId = customerId
        self.policyType = policyType
        self.premiumAmount = premiumAmount
        self.startDate = startDate
        self.endDate = endDate
    }
    var description: String {
         return "ID: \(id), Customer ID: \(customerId), Type: \(policyType), Premium: \(premiumAmount), Start Date: \(startDate.toString()), End Date: \(endDate.toString())"
     }

}

