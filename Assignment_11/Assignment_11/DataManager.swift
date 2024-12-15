//
//  DataManager.swift
//  Assignment_11
//
//  Created by Sameer Shashikant Deshpande on 11/20/24.
//
import SQLite
import Foundation

class DataManager {
    private var customers: [Customer] = []
    private var db: Connection?
    private let customersTable = Table("customers")
    private let policiesTable = Table("policies")
    private let customerId = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let age = Expression<Int>("age")
    private let email = Expression<String>("email")
    private let profilePictureUrl = Expression<String?>("profilePictureUrl") // Optional
    private let policyId = Expression<Int>("id")
    private let custId = Expression<Int>("custId")
    private let policyType = Expression<String?>("policyType")
    private let premiumAmount = Expression<Double?>("premiumAmount")
    private let startDate = Expression<Date?>("startDate")
    private let endDate = Expression<Date?>("endDate")
    
    init() {
        do {
            let dbPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("appData2.sqlite").path
            db = try Connection(dbPath)
            print("Database path: \(dbPath)")
            
            try db?.run(customersTable.create(ifNotExists: true) { t in
                t.column(customerId, primaryKey: true)
                t.column(name)
                t.column(age)
                t.column(email)
                t.column(profilePictureUrl)
            })
            
            try db?.run(policiesTable.create(ifNotExists: true) { t in
                t.column(policyId, primaryKey: true)
                t.column(custId)
                t.column(policyType)
                t.column(premiumAmount)
                t.column(startDate)
                t.column(endDate)
            })
            
        } catch {
            print("Database initialization error: \(error)")
        }
    }
    
    func addCustomer(customer: Customer) {
        do {
            let insert = customersTable.insert(
                name <- customer.name,
                age <- customer.age,
                email <- customer.email,
                profilePictureUrl <- customer.profilePictureUrl
            )
            try db?.run(insert)
            print("Customer added to the database.")
        } catch {
            print("Insert customer error: \(error)")
        }
    }
    func doesEmailExist(email: String) -> Bool {
        do {
            let query = customersTable.filter(self.email == email)
            let customer = try db!.pluck(query)
            
            return customer != nil
        } catch {
            print("Error checking email existence: \(error)")
            return false
        }
    }
    func getNextCustomerId() -> Int {
        do {
            if let highestId = try db?.scalar(customersTable.select(customerId.max)) as? Int {
                return highestId + 1
            }
        } catch {
            print("Failed to get next customer id: \(error)")
        }
        
        return 1
    }
    func fetchCustomers() -> [Customer] {
        var customerList: [Customer] = []
        
        guard let db = db else {
            print("Database connection is unavailable.")
            return []
        }
        do {
            let rows = try db.prepare(customersTable)
            
            customerList = rows.map { row in
                Customer(
                    customerId: row[customerId],
                    name: row[name],
                    age: row[age],
                    email: row[email],
                    profilePictureUrl: row[profilePictureUrl] ?? ""
                )
            }
        } catch {
            print("Error fetching customers from SQLite: \(error)")
        }
        return customerList
    }
    // Assuming this method is part of the DataManager class
    func fetchCustomer(byId customerId: Int) -> Customer? {
        guard let db = db else {
            print("Database connection is unavailable.")
            return nil
        }
        
        let query = customersTable.filter(self.customerId == customerId)
        do {
            if let row = try db.pluck(query) {
                return Customer(
                    customerId: row[self.customerId],
                    name: row[self.name],
                    age: row[self.age],
                    email: row[self.email],
                    profilePictureUrl: row[self.profilePictureUrl] ?? ""
                )
            }
        } catch {
            print("Error fetching customer from SQLite: \(error)")
        }
        return nil
    }
    
    func updateCustomer(customer: Customer) {
        let customerToUpdate = customersTable.filter(customerId == customer.customerId)
        
        do {
            try db?.run(customerToUpdate.update(
                name <- customer.name,
                age <- customer.age,
                email <- customer.email,
                profilePictureUrl <- customer.profilePictureUrl
            ))
        } catch {
            print("Error updating customer: \(error)")
        }
    }

    func deleteCustomer(_ customer: Customer) {
        do {
            let customerTable = Table("customers")
            let idColumn = Expression<Int>("id")
            let customerToDelete = customerTable.filter(idColumn == customer.customerId)
            try db?.run(customerToDelete.delete())
            print("Successfully deleted customer from database")
        } catch {
            print("Failed to delete customer from database: \(error)")
        }
    }
    func addPolicy(policy: Policy) {
        do {
            let insert = policiesTable.insert(
                policyId <- policy.id,
                custId <- policy.customerId,
                policyType <- policy.policyType,
                premiumAmount <- policy.premiumAmount,
                startDate <- policy.startDate,
                endDate <- policy.endDate
            )
            try db?.run(insert)
        } catch {
            print("Insert policy error: \(error)")
        }
    }
    func doesPolicyExist(policyId: Int) -> Bool {
        let query = policiesTable.filter(self.policyId == policyId)
        do {
            let count = try db?.scalar(query.count) ?? 0
            return count > 0
        } catch {
            print("Error checking policy ID existence: \(error)")
            return false
        }
    }
    func updatePolicy(policy: Policy) {
        let policyToUpdate = policiesTable.filter(policyId == policy.id)
        
        do {
            try db?.run(policyToUpdate.update(
                custId <- policy.customerId,
                policyType <- policy.policyType,
                premiumAmount <- policy.premiumAmount,
                startDate <- policy.startDate,
                endDate <- policy.endDate
            ))
        } catch {
            print("Update policy error: \(error)")
        }
    }
    func deletePolicy(policy: Policy) {
        let policyToDelete = policiesTable.filter(policyId == policy.id)
        
        do {
            try db?.run(policyToDelete.delete())
        } catch {
            print("Delete policy error: \(error)")
        }
    }
    
    func policyExists(withId policyId: Int) -> Bool {
        guard let db = db else {
            print("Database connection is unavailable.")
            return false
        }
        let query = policiesTable.filter(self.policyId == policyId)

        do {
            let count = try db.scalar(query.count)
            return count > 0
        } catch {
            print("Error checking if policy exists: \(error)")
            return false
        }
    }

    func getNextPolicyId() -> Int {
         do {
             // Query the highest policy ID in the policies table
             if let highestId = try db?.scalar(policiesTable.select(policyId.max)) as? Int {
                 return highestId + 1  // Return the next available ID
             }
         } catch {
             print("Failed to fetch next policy ID: \(error)")
         }
         return 1  // Default to 1 if no policies exist yet
     }
    
    
    func fetchPolicies() -> [Policy] {
        var policyList: [Policy] = []
        
        // Make sure the database connection is available
        guard let db = db else {
            print("Database connection is unavailable.")
            return []
        }
        
        do {
            // Fetch all rows from the policies table
            let rows = try db.prepare(policiesTable)
            
            // Map each row to a Policy model
            policyList = rows.map { row in
                // Assuming Policy model has an initializer matching the row structure
                Policy(
                    id: row[policyId],
                    customerId: row[customerId],
                    policyType: row[policyType],
                    premiumAmount: row[premiumAmount],
                    startDate: row[startDate],
                    endDate: row[endDate]
                )
            }
        } catch {
            print("Error fetching policies from SQLite: \(error)")
        }
        
        return policyList
    }
}
