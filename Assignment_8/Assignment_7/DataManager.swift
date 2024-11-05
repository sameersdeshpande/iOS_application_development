//
//  DataManager.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/22/24.
//
//
//import SQLite
//
//class DataManager {
//    static let shared = DataManager()
//    private var customers: [Customer] = []
//    private var lastCustomerId: Int = 0
//    private var policies: [Policy] = []
//    private var nextPolicyId: Int = 1 // Incremental ID for new policies
//    private var claims: [Claims] = []
//    private var nextClaimId: Int = 1
//    private var payments: [Payment] = []
//    private var nextPaymentId: Int = 1 // Incremental ID for new payments
//    
//    private init() {
//        preloadData()
//    }
//    
//    func addCustomer(name: String, age: Int, email: String) {
//        lastCustomerId += 1 // Increment the last ID
//        let newCustomer = Customer(id: lastCustomerId, name: name, age: age, email: email)
//        customers.append(newCustomer)
//    }
//    
//    func getCustomers() -> [Customer] {
//        return customers
//    }
//    
//    func removeCustomer(at index: Int) {
//        customers.remove(at: index)
//    }
//    
//    func updateCustomer(at index: Int, name: String, age: Int, email: String) {
//        let customer = customers[index]
//        customer.name = name
//        customer.age = age
//        customer.email = email
//    }
//    
//    // MARK: - Policy Functions
//    
//    func addPolicy(customerId: Int, policyType: String, premiumAmount: Double, startDate: String, endDate: String) {
//        let newPolicy = Policy(id: nextPolicyId, customerId: customerId, policyType: policyType, premiumAmount: premiumAmount, startDate: startDate, endDate: endDate)
//        policies.append(newPolicy)
//        nextPolicyId += 1 // Increment for next policy
//    }
//    
//    func getPolicies() -> [Policy] {
//        return policies
//    }
//    
//    func updatePolicy(at index: Int, customerId: Int, policyType: String, premiumAmount: Double, startDate: String, endDate: String) {
//        guard index >= 0 && index < policies.count else { return }
//        policies[index] = Policy(id: policies[index].id, customerId: customerId, policyType: policyType, premiumAmount: premiumAmount, startDate: startDate, endDate: endDate)
//    }
//    
//    func removePolicy(at index: Int) {
//        guard index >= 0 && index < policies.count else { return }
//        policies.remove(at: index)
//    }
//    
//    //MARK: Claims Functions
//    
//    func addClaim(policyId: Int, claimAmount: Double, dateOfClaim: String, status: String) {
//        let claim = Claims(id: nextClaimId, policyId: policyId, claimAmount: claimAmount, dateOfClaim: dateOfClaim, status: status)
//        claims.append(claim)
//        nextClaimId += 1
//    }
//    
//    func getClaims() -> [Claims] {
//        return claims
//    }
//    
//    func updateClaim(at index: Int, claimAmount: Double, status: String) {
//        var claim = claims[index] // Assuming `claims` is an array of Claim objects
//        claim.claimAmount = claimAmount
//        claim.status = status
//        claims[index] = claim // Update the claim in the array
//    }
//    
//    
//    func removeClaim(at index: Int) {
//        if claims[index].status != "Approved" {
//            claims.remove(at: index)
//        }
//    }
//    
//    // MARK: - Payment Functions
//    
//    func addPayment(policyId: Int, paymentAmount: Double, paymentDate: String, paymentMethod: String, status: String) {
//        let newPayment = Payment(id: nextPaymentId, policyId: policyId, paymentAmount: paymentAmount, paymentDate: paymentDate, paymentMethod: paymentMethod, status: status)
//        payments.append(newPayment)
//        nextPaymentId += 1 // Increment for the next payment
//    }
//    
//    func getPayments() -> [Payment] {
//        return payments
//    }
//    
//    func updatePayment(at index: Int, policyId: Int, paymentAmount: Double, paymentDate: String, paymentMethod: String, status: String) {
//        guard index >= 0 && index < payments.count else { return }
//        payments[index] = Payment(id: payments[index].id, policyId: policyId, paymentAmount: paymentAmount, paymentDate: paymentDate, paymentMethod: paymentMethod, status: status)
//    }
//    
//    func removePayment(at index: Int) {
//        guard index >= 0 && index < payments.count else { return }
//        payments.remove(at: index)
//    }
//    
//    func preloadData() {
//        // Preload Customers
//        addCustomer(name: "John Doe", age: 30, email: "john@example.com")
//        addCustomer(name: "Jane Smith", age: 28, email: "jane@example.com")
//        addCustomer(name: "Sameer Deshpande", age: 26, email: "same@example.com")
//        // Preload Policies with previous start and end dates
//        addPolicy(customerId: 1, policyType: "Health Insurance", premiumAmount: 200.0, startDate: "2023-01-01", endDate: "2027-01-01") // Previous year
//        addPolicy(customerId: 2, policyType: "Car Insurance", premiumAmount: 150.0, startDate: "2023-02-01", endDate: "2024-02-01") // Previous year
//        addPolicy(customerId: 3, policyType: "Home Insurance", premiumAmount: 300.0, startDate: "2022-03-01", endDate: "2023-03-01") // Two years ago
//        
//        // Preload Claims
//        addClaim(policyId: 1, claimAmount: 5000.0, dateOfClaim: "2023-05-01", status: "Pending")
//        addClaim(policyId: 2, claimAmount: 1500.0, dateOfClaim: "2023-06-15", status: "Approved")
//        addClaim(policyId: 3, claimAmount: 2500.0, dateOfClaim: "2022-07-20", status: "Rejected") // Claim from a previous policy
//        
//        // Preload Payments
//        addPayment(policyId: 1, paymentAmount: 200.0, paymentDate: "2023-01-10", paymentMethod: "Credit Card", status: "Processed")
//        addPayment(policyId: 2, paymentAmount: 150.0, paymentDate: "2023-02-05", paymentMethod: "Debit Card", status: "Pending")
//        addPayment(policyId: 3, paymentAmount: 300.0, paymentDate: "2022-03-10", paymentMethod: "Bank Transfer", status: "Failed") // Payment for previous policy
//    }
//
//   
//}
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
                .appendingPathComponent("database.sqlite")
            db = try Connection(fileURL!.path)
            print("Database Path: \(fileURL?.path ?? "Not Found")")
            try db.run(customersTable.create(ifNotExists: true) { t in
                t.column(customerId, primaryKey: .autoincrement)
                t.column(name)
                t.column(age)
                t.column(email)
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

    // Add a customer and persist to database
    func addCustomer(name: String, age: Int, email: String) {
        do {
            let insert = customersTable.insert(self.name <- name, self.age <- age, self.email <- email)
            try db.run(insert)
        } catch {
            print("Error adding customer: \(error)")
        }
    }
    
    // Fetch customers from the database
    func getCustomers() -> [Customer] {
        var customers: [Customer] = []
        do {
            for customer in try db.prepare(customersTable) {
                customers.append(Customer(id: Int(customer[customerId]), name: customer[name], age: customer[age], email: customer[email]))
            }
        } catch {
            print("Error fetching customers: \(error)")
        }
        return customers
    }
    func updateCustomer(at customerId: Int64, name: String, age: Int) {
        do {
            // Assuming you have a column for customer ID in your table
            let customerToUpdate = customersTable.filter(self.customerId == customerId) // Use the actual customerId column

            // Update the customer's information
            try db.run(customerToUpdate.update(
                self.name <- name,
                self.age <- age
            ))

            print("Customer updated successfully.")
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
            addCustomer(name: "John Doe", age: 30, email: "john@example.com")
            addCustomer(name: "Jane Smith", age: 28, email: "jane@example.com")
            addCustomer(name: "Sameer Deshpande", age: 26, email: "same@example.com")
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
