//
//  Customer.swift
//  Assignment_10
//
//  Created by Sameer Shashikant Deshpande on 11/15/24.
//

import Foundation

struct Customer: Identifiable, Decodable,Hashable {
    var id: Int { customerId }
    let customerId: Int
    var name: String
    var age: Int
    var email: String
    var profilePictureUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case customerId = "id"
        case name
        case age
        case email
        case profilePictureUrl = "profile_picture"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(customerId) // Use unique identifier for hashing
        hasher.combine(name)        // You can combine other fields if needed
    }
    
    static func ==(lhs: Customer, rhs: Customer) -> Bool {
        return lhs.customerId == rhs.customerId
    }
}



