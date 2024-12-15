//
//  MockAPI.swift
//  Assignment_10
//
//  Created by Sameer Shashikant Deshpande on 11/15/24.
//

import Foundation

class MockAPI {
    
    
    static func fetchCustomers(completion: @escaping (Result<[Customer], Error>) -> Void) {
        guard let url = URL(string: "https://672be2841600dda5a9f6a9dc.mockapi.io/customers") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                
                do {
                    let apiCustomers = try JSONDecoder().decode([Customer].self, from: data)
                    let dataManager = DataManager()
                    let dbCustomers = dataManager.fetchCustomers()
                    let dbEmails = Set(dbCustomers.map { $0.email })
                    
                    let newCustomers = apiCustomers.filter { customer in
                        !dbEmails.contains(customer.email)
                    }
                    for customer in newCustomers {
                        dataManager.addCustomer(customer: customer)
                    }
                    DispatchQueue.main.async {
                        completion(.success(apiCustomers))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
        task.resume()
    }
    
    static func fetchPolicies(completion: @escaping (Result<[Policy], Error>) -> Void) {
        guard let url = URL(string: "https://672be2841600dda5a9f6a9dc.mockapi.io/policies") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        let dataManager = DataManager()
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                // Optionally, you can print the raw JSON response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON Response: \(jsonString)")
                }
                
                do {
                    // Decode the fetched policies from the API response
                    let policies = try JSONDecoder().decode([Policy].self, from: data)
                    
                    // Insert only policies that do not already exist in the DB
                    for policy in policies {
                        // Check if policy exists in the database
                        if !dataManager.policyExists(withId: policy.id) {
                            // If it doesn't exist, add it to the database
                            dataManager.addPolicy(policy: policy)
                        }
                    }
                    
                    // Call completion handler on the main thread
                    DispatchQueue.main.async {
                        completion(.success(policies)) // Return the fetched policies
                    }
                } catch {
                    // Handle JSON decoding error
                    DispatchQueue.main.async {
                        completion(.failure(error)) // Pass the error to completion handler
                    }
                }
            }
        }
        task.resume() // Start the data task to fetch the data
    }
}
