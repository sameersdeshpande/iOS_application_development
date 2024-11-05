//
//  Payments.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/28/24.
//

import Foundation
class Payment {
    var id: Int
    var policyId: Int
    var paymentAmount: Double
    var paymentDate: String
    var paymentMethod: String
    var status: String

    init(id: Int, policyId: Int, paymentAmount: Double, paymentDate: String, paymentMethod: String, status: String) {
        self.id = id
        self.policyId = policyId
        self.paymentAmount = paymentAmount
        self.paymentDate = paymentDate
        self.paymentMethod = paymentMethod
        self.status = status
    }
}
