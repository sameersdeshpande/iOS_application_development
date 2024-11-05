//
//  Customer.swift
//  Assignment_6
//
//  Created by Sameer Shashikant Deshpande on 10/20/24.
//


import Foundation

class Customer {
    var id: Int
    var name: String
    var age: Int
    var email: String
    var policies: [InsurancePolicy] // New property for attached policies
    
    init(id: Int, name: String, age: Int, email: String) {
        self.id = id
        self.name = name
        self.age = age
        self.email = email
        self.policies = [] // Initialize as empty
    }
}

