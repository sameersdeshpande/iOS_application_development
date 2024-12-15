//
//  NetworkManager.swift
//  Assignment_9
//
//  Created by Sameer Shashikant Deshpande on 11/6/24.
//import Foundation

// Define API_Customer struct to decode JSON data
import Foundation
import UIKit
struct API_Customer: Decodable {
    let id: Int
    let name: String
    let age: Int
    let email: String
    let profile_picture: String  // URL of the profile picture
}
struct API_Policy: Decodable {
    let id: String
    let customerId: Int
    let policyType: String
    let premiumAmount: Double
    let startDate: String  // Keep as String
    let endDate: String    // Keep as String

    enum CodingKeys: String, CodingKey {
        case id
        case customerId = "customerId"
        case policyType
        case premiumAmount
        case startDate
        case endDate
    }

    // Custom init to decode the fields, converting numbers to strings if necessary
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode the id as a string (API returns it as a string)
        self.id = try container.decode(String.self, forKey: .id)
        
        // Decode the customerId and other fields normally
        self.customerId = try container.decode(Int.self, forKey: .customerId)
        self.policyType = try container.decode(String.self, forKey: .policyType)
        self.premiumAmount = try container.decode(Double.self, forKey: .premiumAmount)

        // Decode startDate and endDate as String, even if they come as numbers
        let startDateValue = try container.decodeIfPresent(Int.self, forKey: .startDate) ?? 0
        self.startDate = String(startDateValue)

        let endDateValue = try container.decodeIfPresent(Int.self, forKey: .endDate) ?? 0
        self.endDate = String(endDateValue)
    }
}


class NetworkManager {

    static let shared = NetworkManager()

    func fetchCustomers(completion: @escaping ([API_Customer]?, Error?) -> Void) {
        guard let url = URL(string: "https://672be2841600dda5a9f6a9dc.mockapi.io/customers") else {
            print("Invalid URL")
            completion(nil, NSError(domain: "URL Error", code: 400, userInfo: nil))
            return
        }
        
        // Perform the network request
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Handle any error that occurred
            if let error = error {
                print("Error fetching customers: \(error)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(nil, NSError(domain: "Data Error", code: 500, userInfo: nil))
                return
            }
            
            // Print the raw response data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw Response: \(jsonString)")
            }
            
            do {
                // Attempt to decode the response as an array of API_Customer
                let decoder = JSONDecoder()
                let customers = try decoder.decode([API_Customer].self, from: data)
                completion(customers, nil)
            } catch {
                // If decoding fails, print error and pass it to completion handler
                print("Error decoding customers data: \(error)")
                completion(nil, error)
            }
        }.resume()
    }

    func fetchImage(from url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        // Ensure the URL string is correctly formatted
        guard let imageURL = URL(string: url) else {
            print("Invalid image URL: \(url)")  // Debug log to check the URL
            completion(nil, NSError(domain: "URL Error", code: 400, userInfo: nil))
            return
        }

        // Log the URL to make sure it's being parsed correctly
        print("Fetching image from URL: \(imageURL)")

        // Perform the download request in the background
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                print("Error fetching image: \(error)")  // Log error
                completion(nil, error)
                return
            }

            guard let data = data else {
                print("No image data received.")  // Log if no data is returned
                completion(nil, NSError(domain: "Data Error", code: 500, userInfo: nil))
                return
            }

            // Log the length of the data (should give an idea of whether it's a valid image)
            print("Received image data: \(data.count) bytes")

            // Convert the data to UIImage
            if let image = UIImage(data: data) {
                completion(image, nil)
            } else {
                print("Error: Failed to convert data to UIImage.")  // Log if conversion fails
                completion(nil, NSError(domain: "Image Error", code: 500, userInfo: nil))
            }
        }.resume()
    }



    
    // This method fetches customers and stores them into local DB, but removes the showMessage
    func fetchAndStoreCustomers(completion: @escaping (Bool, String?) -> Void) {
        fetchCustomers { [weak self] customers, error in
            if let error = error {
                completion(false, "Error fetching customers: \(error.localizedDescription)")
                return
            }
            
            guard let customers = customers else {
                completion(false, "No customers data available")
                return
            }
            
            // Convert the API customer data into your local Customer model
            var localCustomers: [Customer] = []
            // Assuming you have a Customer model with id as a required parameter
            for apiCustomer in customers {
                let localCustomer = Customer(id: apiCustomer.id, // pass the id from API
                                             name: apiCustomer.name,
                                             age: apiCustomer.age,
                                             email: apiCustomer.email,
                                             profilePictureUrl: apiCustomer.profile_picture)
                localCustomers.append(localCustomer)
            }

            // Save to local database using DataManager
            DataManager.shared.saveCustomers(customers: localCustomers)
            
            // Return success message through completion
            completion(true, "Customers fetched and stored successfully.")
        }
    }
    
    //MARK: Fetch Policies
       func fetchPolicies(completion: @escaping ([API_Policy]?, Error?) -> Void) {
           guard let url = URL(string: "https://672be2841600dda5a9f6a9dc.mockapi.io/policies") else {
               print("Invalid URL")
               completion(nil, NSError(domain: "URL Error", code: 400, userInfo: nil))
               return
           }

           URLSession.shared.dataTask(with: url) { (data, response, error) in
               // Handle any error
               if let error = error {
                   print("Error fetching policies: \(error)")
                   completion(nil, error)
                   return
               }

               guard let data = data else {
                   print("No data received.")
                   completion(nil, NSError(domain: "Data Error", code: 500, userInfo: nil))
                   return
               }

               do {
                   // Decode JSON into array of API_Policy
                   let decoder = JSONDecoder()
                   let policies = try decoder.decode([API_Policy].self, from: data)
                   completion(policies, nil)
               } catch {
                   print("Error decoding policies data: \(error)")
                   completion(nil, error)
               }
           }.resume()
       }
    
    static func formatUnixTimestampToString(timestamp: Int) -> String {
           let date = Date(timeIntervalSince1970: TimeInterval(timestamp))  // Convert to Date
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"  // Set the desired format
           return dateFormatter.string(from: date)  // Return the formatted date as a string
       }

    func fetchAndStorePolicies(completion: @escaping (Bool, String?) -> Void) {
        fetchPolicies { [weak self] policies, error in
            if let error = error {
                completion(false, "Error fetching policies: \(error.localizedDescription)")
                return
            }

            guard let policies = policies else {
                completion(false, "No policies data available")
                return
            }

            // Convert the API policies into local Policy models
            var localPolicies: [Policy] = []
            for apiPolicy in policies {
                // Convert the startDate and endDate (String) to Int and format them
                let formattedStartDate = NetworkManager.formatUnixTimestampToString(timestamp: Int(apiPolicy.startDate) ?? 0)
                let formattedEndDate = NetworkManager.formatUnixTimestampToString(timestamp: Int(apiPolicy.endDate) ?? 0)

                // Convert the apiPolicy.id (String) to Int before creating the local Policy
                let localPolicy = Policy(
                    id: Int(apiPolicy.id) ?? 0,  // Convert String to Int (default to 0 if conversion fails)
                    customerId: apiPolicy.customerId,
                    policyType: apiPolicy.policyType,
                    premiumAmount: apiPolicy.premiumAmount,
                    startDate: formattedStartDate,  // Use formatted date string
                    endDate: formattedEndDate       // Use formatted date string
                )
                localPolicies.append(localPolicy)
            }

            // Save to local database using DataManager
            DataManager.shared.savePolicies(policies: localPolicies)

            // Return success message through completion
            completion(true, "Policies fetched and stored successfully.")
        }
    }

}
