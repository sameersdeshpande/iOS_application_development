//
//  Customer.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/22/24.
//


import Foundation

class Customer {
    var id: Int
    var name: String
    var age: Int
    var email: String
    
    init(id: Int, name: String, age: Int, email: String) {
        self.id = id
        self.name = name
        self.age = age
        self.email = email
    }
}
