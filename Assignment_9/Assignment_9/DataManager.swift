//
//  DataManager.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/22/24.
//
//
import Foundation
import SQLite

class DataManager {
    static let shared = DataManager()
 
    private var db: Connection!
    
    // Define the tables
    private let customersTable = Table("customers")
    private let policiesTable = Table("policies")
    private let claimsTable = Table("claims")
    private let paymentsTable = Table("payments")
    
    // Define the columns for customers
    private let customerId = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let age = Expression<Int>("age")
    private let email = Expression<String>("email")
    private let profilePictureUrl = Expression<String?>("profile_picture_url")


    // Define columns for policies
    private let policyId = Expression<Int64>("id")
    private let customerIdFK = Expression<Int64>("customer_id")
    private let policyType = Expression<String>("policy_type")
    private let premiumAmount = Expression<Double>("premium_amount")
    private let startDate = Expression<String>("start_date")
    private let endDate = Expression<String>("end_date")
    
    // Define columns for claims
    private let claimId = Expression<Int64>("id")
    private let policyIdFK = Expression<Int64>("policy_id")
    private let claimAmount = Expression<Double>("claim_amount")
    private let dateOfClaim = Expression<String>("date_of_claim")
    private let status = Expression<String>("status")
    
    // Define columns for payments
    private let paymentId = Expression<Int64>("id")
    private let paymentPolicyId = Expression<Int64>("policy_id")
    private let paymentAmount = Expression<Double>("payment_amount")
    private let paymentDate = Expression<String>("payment_date")
    private let paymentMethod = Expression<String>("payment_method")
    private let paymentStatus = Expression<String>("status")

    private init() {
        setupDatabase()
        preloadData()
    }
    
    private func setupDatabase() {
        do {
            let fileURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("New12database.sqlite")
            db = try Connection(fileURL!.path)
            print("Database Path: \(fileURL?.path ?? "Not Found")")
            
            try db.run(customersTable.create(ifNotExists: true) { t in
                t.column(customerId, primaryKey: .autoincrement)
                t.column(name)
                t.column(age)
                t.column(email)
                t.column(profilePictureUrl)  // Add this line if needed
            })
            try db.run(policiesTable.create(ifNotExists: true) { t in
                t.column(policyId, primaryKey: .autoincrement)
                t.column(customerIdFK)
                t.column(policyType)
                t.column(premiumAmount)
                t.column(startDate)
                t.column(endDate)
            })

            try db.run(claimsTable.create(ifNotExists: true) { t in
                t.column(claimId, primaryKey: .autoincrement)
                t.column(policyIdFK)
                t.column(claimAmount)
                t.column(dateOfClaim)
                t.column(status)
            })

            try db.run(paymentsTable.create(ifNotExists: true) { t in
                t.column(paymentId, primaryKey: .autoincrement)
                t.column(paymentPolicyId)
                t.column(paymentAmount)
                t.column(paymentDate)
                t.column(paymentMethod)
                t.column(paymentStatus)
            })

        } catch {
            print("Error setting up database: \(error)")
        }
    }

    // Add a customer with a profile image and persist to the database
    func addCustomer(name: String, age: Int, email: String, profileImage: String) {
        do {
            let insert = customersTable.insert(
                self.name <- name,
                self.age <- age,
                self.email <- email,
                self.profilePictureUrl <- profileImage // Insert the base64 string into the profileImage column
            )
            try db.run(insert)
        } catch {
            print("Error adding customer: \(error)")
        }
    }

    
    // Fetch customers from the database
    func getCustomers() -> [Customer] {
        var customers: [Customer] = []
        
        do {
            // Fetch all customers from the database
            for customer in try db.prepare(customersTable) {
                // Read the profilePictureUrl from the database (it can be a base64-encoded string or a URL)
                let profilePicture = customer[profilePictureUrl] as? String
                
                // Create a new Customer object and append it to the customers array
                let newCustomer = Customer(
                    id: Int(customer[customerId]),
                    name: customer[name],
                    age: customer[age],
                    email: customer[email],
                    profilePictureUrl: profilePicture  // Include the profile picture URL/base64 string
                )
                
                customers.append(newCustomer)
            }
        } catch {
            print("Error fetching customers: \(error)")
        }
        
        return customers
    }

    func updateCustomer(at id: Int64, name: String, age: Int, profilePictureUrl: String?) {
        let customer = customersTable.filter(self.customerId == id)
        
        do {
            // Update the customer information, including the profile picture URL (if provided)
            try db.run(customer.update(
                self.name <- name,
                self.age <- age,
                self.profilePictureUrl <- profilePictureUrl // Update profile picture URL or base64 string
            ))
        } catch {
            print("Error updating customer: \(error)")
        }
    }



    func removeCustomer(id: Int) {
        do {
            // Remove associated policies first
            let policiesToRemove = policiesTable.filter(customerIdFK == Int64(id))
            try db.run(policiesToRemove.delete())
            
            // Now remove the customer
            let customerToRemove = customersTable.filter(customerId == Int64(id))
            try db.run(customerToRemove.delete())
            
            print("Customer with id \(id) removed successfully.")
        } catch {
            print("Error removing customer: \(error)")
        }
    }
    // Add a policy and persist to database
    func addPolicy(customerId: Int, policyType: String, premiumAmount: Double, startDate: String, endDate: String) {
        do {
            let insert = policiesTable.insert(customerIdFK <- Int64(customerId), self.policyType <- policyType, self.premiumAmount <- premiumAmount, self.startDate <- startDate, self.endDate <- endDate)
            try db.run(insert)
        } catch {
            print("Error adding policy: \(error)")
        }
    }

    // Fetch policies from the database
    func getPolicies() -> [Policy] {
        var policies: [Policy] = []
        do {
            for policy in try db.prepare(policiesTable) {
                policies.append(Policy(id: Int(policy[policyId]), customerId: Int(policy[customerIdFK]), policyType: policy[policyType], premiumAmount: policy[premiumAmount], startDate: policy[startDate], endDate: policy[endDate]))
            }
        } catch {
            print("Error fetching policies: \(error)")
        }
        return policies
    }
    //Remove Policy
    func removePolicy(id: Int) {
        do {
            let policyToDelete = policiesTable.filter(policyId == Int64(id))
            try db.run(policyToDelete.delete())
        } catch {
            print("Error deleting policy: \(error)")
        }
    }
    // Update Policy
    func updatePolicy(at policyId: Int, customerId: Int, policyType: String, premiumAmount: Double, startDate: String, endDate: String) {
        do {
            // Assuming policyId directly corresponds to the ID in your database
            let policyToUpdate = policiesTable.filter(self.policyId == Int64(policyId))
            
            // Perform the update
            let updatedRows = try db.run(policyToUpdate.update(
                self.customerIdFK <- Int64(customerId),
                self.policyType <- policyType,
                self.premiumAmount <- premiumAmount,
                self.startDate <- startDate,
                self.endDate <- endDate
            ))
            
            print("Updated \(updatedRows) row(s)")
        } catch {
            print("Error updating policy: \(error)")
        }
    }
    // Add a claim and persist to database
    func addClaim(policyId: Int, claimAmount: Double, dateOfClaim: String, status: String) {
        do {
            let insert = claimsTable.insert(policyIdFK <- Int64(policyId), self.claimAmount <- claimAmount, self.dateOfClaim <- dateOfClaim, self.status <- status)
            try db.run(insert)
        } catch {
            print("Error adding claim: \(error)")
        }
    }
    // Fetch claims from the database
    func getClaims() -> [Claims] {
        var claims: [Claims] = []
        do {
            for claim in try db.prepare(claimsTable) {
                claims.append(Claims(id: Int(claim[claimId]), policyId: Int(claim[policyIdFK]), claimAmount: claim[claimAmount], dateOfClaim: claim[dateOfClaim], status: claim[status]))
            }
        } catch {
            print("Error fetching claims: \(error)")
        }
        return claims
    }
    func removeClaim(at index: Int) {
        do {
            let claimToDelete = claimsTable.filter(claimId == Int64(index + 1)) // Assuming index matches the claim ID directly
            try db.run(claimToDelete.delete())
        } catch {
            print("Error deleting claim: \(error)")
        }
    }

    func updateClaim(at id: Int, policyId: Int, claimAmount: Double, dateOfClaim: String, status: String) {
        do {
            let claimToUpdate = claimsTable.filter(claimId == Int64(id))
            let updateStatement = claimToUpdate.update(
                self.policyId <- Int64(policyId),
                self.claimAmount <- claimAmount,
                self.dateOfClaim <- dateOfClaim,
                self.status <- status
            )
            
            let rowsAffected = try db.run(updateStatement)
            if rowsAffected > 0 {
                print("Successfully updated claim with ID \(id).")
            } else {
                print("No claim found with ID \(id).")
            }
        } catch {
            print("Error updating claim: \(error)")
        }
    }
    // Add a payment and persist to database
    func addPayment(policyId: Int, paymentAmount: Double, paymentDate: String, paymentMethod: String, status: String) {
        do {
            let insert = paymentsTable.insert(paymentPolicyId <- Int64(policyId), self.paymentAmount <- paymentAmount, self.paymentDate <- paymentDate, self.paymentMethod <- paymentMethod, self.paymentStatus <- status)
            try db.run(insert)
        } catch {
            print("Error adding payment: \(error)")
        }
    }

    func getPayments() -> [Payment] {
        var payments: [Payment] = []
        do {
            for payment in try db.prepare(paymentsTable) {
                payments.append(Payment(id: Int(payment[paymentId]), policyId: Int(payment[paymentPolicyId]), paymentAmount: payment[paymentAmount], paymentDate: payment[paymentDate], paymentMethod: payment[paymentMethod], status: payment[paymentStatus]))
            }
        } catch {
            print("Error fetching payments: \(error)")
        }
        return payments
    }
    func removePayment(at index: Int) {
        do {
            let paymentToDelete = paymentsTable.filter(paymentId == Int64(index + 1))
            try db.run(paymentToDelete.delete())
        } catch {
            print("Error deleting payment: \(error)")
        }
    }
    func updatePayment(at index: Int, policyId: Int, paymentAmount: Double, paymentDate: String, paymentMethod: String, status: String) {
        do {
            // Assuming index directly corresponds to paymentId
            let paymentToUpdate = paymentsTable.filter(paymentId == Int64(index))
            let updateStatement = paymentToUpdate.update(
                paymentPolicyId <- Int64(policyId),
                self.paymentAmount <- paymentAmount,
                self.paymentDate <- paymentDate,
                self.paymentMethod <- paymentMethod,
                self.paymentStatus <- status
            )
            
            let rowsAffected = try db.run(updateStatement)
            if rowsAffected > 0 {
                print("Successfully updated payment with ID \(index).")
            } else {
                print("No payment found with ID \(index).")
            }
        } catch {
            print("Error updating payment: \(error)")
        }
    }
    // Preload initial data into the database
    private func preloadData() {
        if getCustomers().isEmpty {
            DataManager.shared.addCustomer(name: "John Doe", age: 30, email: "john@example.com", profileImage: "johnImageBase64")
              DataManager.shared.addCustomer(name: "Jane Smith", age: 28, email: "jane@example.com", profileImage: "janeImageBase64")
              DataManager.shared.addCustomer(name: "Sameer Deshpande", age: 26, email: "same@example.com", profileImage: "sameerImageBase64")
        }
        
        if getPolicies().isEmpty {
            addPolicy(customerId: 1, policyType: "Health Insurance", premiumAmount: 200.0, startDate: "2023-01-01", endDate: "2027-01-01")
            addPolicy(customerId: 2, policyType: "Car Insurance", premiumAmount: 150.0, startDate: "2023-02-01", endDate: "2024-02-01")
            addPolicy(customerId: 3, policyType: "Home Insurance", premiumAmount: 300.0, startDate: "2022-03-01", endDate: "2023-03-01")
        }

        if getClaims().isEmpty {
            addClaim(policyId: 1, claimAmount: 5000.0, dateOfClaim: "2023-05-01", status: "Pending")
            addClaim(policyId: 2, claimAmount: 1500.0, dateOfClaim: "2023-06-15", status: "Approved")
            addClaim(policyId: 3, claimAmount: 2500.0, dateOfClaim: "2022-07-20", status: "Rejected")
        }

        if getPayments().isEmpty {
            addPayment(policyId: 1, paymentAmount: 200.0, paymentDate: "2023-01-10", paymentMethod: "Credit Card", status: "Processed")
            addPayment(policyId: 2, paymentAmount: 150.0, paymentDate: "2023-02-05", paymentMethod: "Debit Card", status: "Pending")
            addPayment(policyId: 3, paymentAmount: 300.0, paymentDate: "2022-03-10", paymentMethod: "Bank Transfer", status: "Failed")
        }
    }
}
extension DataManager {
    func saveCustomers(customers: [Customer]) {
        for customer in customers {
            let query = customersTable.filter(email == customer.email)
            if (try? db.pluck(query)) == nil {
                let insert = customersTable.insert(
                    name <- customer.name,
                    age <- customer.age,
                    email <- customer.email,
                    profilePictureUrl <- (customer.profilePictureUrl ?? "")
                )
                try? db.run(insert)
            }
        }
    }
    func savePolicies(policies: [Policy]) {
        for policy in policies {
            let insert = policiesTable.insert(or: .replace,
                policyId <- Int64(policy.id),
                customerIdFK <- Int64(policy.customerId),
                policyType <- policy.policyType,
                premiumAmount <- policy.premiumAmount,
                startDate <- policy.startDate,  // Start date is already formatted (yyyy-MM-dd)
                endDate <- policy.endDate       // End date is already formatted (yyyy-MM-dd)
            )
            
            do {
                try db.run(insert)
                print("Policy with ID \(policy.id) inserted or replaced successfully.")
            } catch {
                print("Error inserting policy: \(error)")
            }
        }
    }




}

