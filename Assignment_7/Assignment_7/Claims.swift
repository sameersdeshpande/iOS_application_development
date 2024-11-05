//
//  Claims.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/23/24.
//

import Foundation

class Claims {
    var id: Int
    var policyId: Int
    var claimAmount: Double
    var dateOfClaim: String
    var status: String
    
    init(id: Int, policyId: Int, claimAmount: Double, dateOfClaim: String, status: String) {
        self.id = id
        self.policyId = policyId
        self.claimAmount = claimAmount
        self.dateOfClaim = dateOfClaim
        self.status = status
    }
}
