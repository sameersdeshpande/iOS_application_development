//
//  main.swift
//  Assignment_5
//
//  Created by Sameer Shashikant Deshpande on 10/13/24.
//
import Foundation
// MARK: - Menu Items
class MenuItem {
    var name: String
    var description: String
    var price: Double
    var category: String
    
    init(name: String, description: String, price: Double, category: String) {
        self.name = name
        self.description = description
        self.price = price
        self.category = category
    }
}
// MARK: - Declaring Orders
class Order {
    let oid: String
    var cid: Customer
    var items: [MenuItem]
    var totalAmount: Double
    var status: String
    let orderDate: Date
    
    init(oid: String, cid: Customer, items: [MenuItem]) {
        self.oid = oid
        self.cid = cid
        self.items = items
        self.totalAmount = items.reduce(0) { $0 + $1.price }
        self.status = "Pending"
        self.orderDate = Date()
    }
}

// MARK: - Declaring Customers
class Customer {
    let cid: String
    var name: String
    var email: String
    var phoneNumber: String
    
    init(cid: String, name: String, email: String, phoneNumber: String) {
        self.cid = cid
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
    }
}
// MARK: - Restaurant Management System
class RestaurantManagement {
    private var menuItems: [String: MenuItem] = [:]
    private var orders: [String: Order] = [:]
    private var customers: [String: Customer] = [:]
    private var lastCustomerId: Int = 0
    private var lastOrderId: Int = 0
    
    func initializeSampleData() {
           
            let customer1 = Customer(cid: "1", name: "Sameer ", email: "sameer@gmail.com", phoneNumber: "1234567890")
            let customer2 = Customer(cid: "2", name: "Aheesh", email: "aheesh@gmail.com", phoneNumber: "0987654321")
            
            customers[customer1.cid] = customer1
            customers[customer2.cid] = customer2
        
            let menuItem1 = MenuItem(name: "Pizza", description: "Delicious pizza", price: 12.99, category: "Main Course")
            let menuItem2 = MenuItem(name: "Pasta", description: "Creamy pasta", price: 10.99, category: "Main Course")
            let menuItem3 = MenuItem(name: "Salad", description: "Fresh garden salad", price: 7.99, category: "Appetizer")
            
            menuItems[menuItem1.name] = menuItem1
            menuItems[menuItem2.name] = menuItem2
            menuItems[menuItem3.name] = menuItem3
            
            
            let order1 = Order(oid: "1", cid: customer1, items: [menuItem1, menuItem3])
            let order2 = Order(oid: "2", cid: customer2, items: [menuItem2])
            
            orders[order1.oid] = order1
            orders[order2.oid] = order2
            
            lastCustomerId = 2
            lastOrderId = 2
        }

    
    // MARK: Menu Item Operations
    func addMenuItem() {
        print("Enter menu item name:")
        guard let name = readLine(), menuItems[name] == nil else {
            print("Menu item already exists.")
            return
        }
        print("Enter description:")
        let description = readLine() ?? ""
        
        print("Enter price:")
        guard let priceString = readLine(), let price = Double(priceString), price > 0 else {
            print("Invalid price.")
            return
        }
        
        print("Enter category:")
        let category = readLine() ?? ""
        
        let newItem = MenuItem(name: name, description: description, price: price, category: category)
        menuItems[name] = newItem
        print("Menu item added.")
    }
    
    func viewMenuItems() {
      
        let groupedItems = Dictionary(grouping: menuItems.values) { $0.category }
        let sortedCategories = groupedItems.keys.sorted()
        for category in sortedCategories {
            print("\nCategory: \(category)")
            let itemsInCategory = groupedItems[category]?.sorted(by: { $0.name < $1.name }) ?? []
            for item in itemsInCategory {
                print("  Name: \(item.name), Description: \(item.description), Price: \(item.price)")
            }
        }
    }
    
    func updateMenuItem() {
        print("Enter the name of the menu item to update:")
        guard let name = readLine(), let item = menuItems[name] else {
            print("Menu item not found.")
            return
        }
        print("Enter new name (leave empty to keep current):")
        let newName = readLine() ?? ""
        if !newName.isEmpty && menuItems[newName] == nil {
            menuItems[newName] = item
            menuItems.removeValue(forKey: name)
            item.name = newName
        } else if !newName.isEmpty {
            print("Menu item with the new name already exists or is invalid.")
        }
        
        print("Enter new description (leave empty to keep current):")
        let description = readLine() ?? ""
        item.description = description.isEmpty ? item.description : description
        
        print("Enter new price (must be greater than 0, leave empty to keep current):")
        let priceString = readLine()

        if let priceInput = priceString, !priceInput.isEmpty {
            if let price = Double(priceInput), price > 0 {
                item.price = price
                print("Price updated to \(price).")
            } else {
                print("Invalid price. The price must be greater than 0.")
            }
        } else {
            print("Price not updated; keeping current price of \(item.price).")
        }
        print("Menu item updated.")
    }
    func deleteMenuItem() {
        print("Enter the name of the menu item to delete:")
        guard let name = readLine(), let _ = menuItems[name] else {
            print("Menu item not found.")
            return
        }
        if orders.values.contains(where: { $0.items.contains(where: { $0.name == name }) }) {
            print("Cannot delete menu item that is part of an active order.")
            return
        }
        
        menuItems.removeValue(forKey: name)
        print("Menu item deleted.")
    }
    
    // MARK: Order Operations
    func placeOrder() {
        print("Available Menu Items:")
           for (key, menuItem) in menuItems {
               print("\(key): \(menuItem.name) - \(menuItem.description) - $\(menuItem.price) - Category: \(menuItem.category)")
           }
        print("Enter customer ID for the order:")
        guard let customerId = readLine(), let customer = customers[customerId] else {
            print("Invalid customer.")
            return
        }
        lastOrderId += 1
        let orderId = String(lastOrderId)
        
        print("Enter menu item names (comma-separated):")
        guard let itemsInput = readLine() else { return }
        let itemNames = itemsInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let orderItems = itemNames.compactMap { menuItems[String($0)] }
        guard !orderItems.isEmpty else {
            print("No valid menu items selected.")
            return
        }
        let order = Order(oid: orderId, cid: customer, items: orderItems)
        orders[orderId] = order
        print("Order placed with ID: \(orderId). Total amount: \(order.totalAmount)")
    }
    
    func viewOrders() {
        let sortedOrders = orders.values.sorted { $0.orderDate > $1.orderDate }
        for order in sortedOrders {
            print("Order ID: \(order.oid), Customer: \(order.cid.name), Total Amount: \(order.totalAmount), Status: \(order.status), Date: \(order.orderDate)")
        }
    }
    
    func updateOrder() {
        print("Enter order ID to update:")
        guard let orderId = readLine(), let order = orders[orderId] else {
            print("Order not found.")
            return
        }
        
        if order.status == "Completed" {
            print("Cannot update a completed order.")
            return
        }

        var running = true
        while running {
            print("""
            Current Order Items:
            \(order.items.map { $0.name }.joined(separator: ", "))
            
            Choose an action:
            1. Update status
            2. Add an item
            3. Remove an item
            0. Back
            """)
            
            guard let action = readLine() else { return }
            
            switch action {
            case "1":
                print("Enter new status (e.g., In Progress, Completed, Delivered):")
                if let status = readLine() {
                    order.status = status
                    print("Order status updated to '\(status)'.")
                }
            case "2":
              
                print("Available Menu Items:")
                for (key, menuItem) in menuItems {
                    print("\(key): \(menuItem.name) - \(menuItem.description) - $\(menuItem.price) - Category: \(menuItem.category)")
                }
                
                print("Enter the name of the item to add:")
                if let itemName = readLine(), let itemToAdd = menuItems[itemName] {
                    order.items.append(itemToAdd)
                    order.totalAmount += itemToAdd.price
                    print("Item '\(itemToAdd.name)' added to the order.")
                } else {
                    print("Invalid item name.")
                }
            case "3":
            
                print("Enter the name of the item to remove:")
                if let itemName = readLine() {
                    if let index = order.items.firstIndex(where: { $0.name == itemName }) {
                        let removedItem = order.items.remove(at: index)
                        order.totalAmount -= removedItem.price
                        print("Item '\(removedItem.name)' removed from the order.")
                    } else {
                        print("Item not found in the order.")
                    }
                }
            case "0":
                running = false // Exit the update loop
            default:
                print("Invalid choice.")
            }
        }
    }
    func cancelOrder() {
        print("Enter order ID to cancel:")
        guard let orderId = readLine(), let order = orders[orderId] else {
            print("Order not found.")
            return
        }
        
        if order.status == "Delivered" {
            print("Cannot cancel a delivered order.")
            return
        }
        
        orders.removeValue(forKey: orderId)
        print("Order canceled.")
    }
    // MARK: Customer Operations
    func registerCustomer() {
        lastCustomerId += 1
        let customerId = String(lastCustomerId)
        
        print("Enter customer name:")
        let name = readLine() ?? ""
        
        print("Enter email:")
        guard let email = readLine(),
              email.contains("@"),
              email.hasSuffix(".com"),
              customers.values.allSatisfy({ $0.email != email }) else {
            print("Email must be unique and valid.")
            return
        }
        print("Enter phone number (digits only):")
          guard let phoneNumber = readLine(), phoneNumber.allSatisfy({ $0.isNumber }) else {
              print("Phone number must contain digits only.")
              return
          }
        
        let newCustomer = Customer(cid: customerId, name: name, email: email, phoneNumber: phoneNumber)
        customers[customerId] = newCustomer
        print("Customer registered.")
    }
    func viewCustomers() {
        let sortedCustomers = customers.values.sorted { $0.name < $1.name }
        for customer in sortedCustomers {
            print("Customer ID: \(customer.cid), Name: \(customer.name), Email: \(customer.email), Phone: \(customer.phoneNumber)")
        }
    }
    
    func updateCustomer() {
        print("Enter customer ID to update:")
        guard let customerId = readLine(), let customer = customers[customerId] else {
            print("Customer not found.")
            return
        }
        let hasPendingOrders = orders.values.contains { $0.cid.cid == customer.cid && $0.status == "Pending" }
        if hasPendingOrders {
            print("Cannot update customer information with pending orders.")
            return
        }
        print("Enter new name (leave empty to keep current):")
        let name = readLine() ?? ""
        customer.name = name.isEmpty ? customer.name : name
        
        print("Enter new email (leave empty to keep current):")
        let email = readLine() ?? ""
        if !email.isEmpty && customers.values.allSatisfy({ $0.email != email }) {
            customer.email = email
        }
        
        print("Enter new phone number (leave empty to keep current):")
        let phoneNumber = readLine() ?? ""
        customer.phoneNumber = phoneNumber.isEmpty ? customer.phoneNumber : phoneNumber
        
        print("Customer updated.")
    }
    
    func deleteCustomer() {
        print("Enter customer ID to delete:")
        guard let customerId = readLine(), let customer = customers[customerId] else {
            print("Customer not found.")
            return
        }
        
        if orders.values.contains(where: { $0.cid.cid == customer.cid }) {
            print("Cannot delete customer with active or past orders.")
            return
        }
        
        customers.removeValue(forKey: customerId)
        print("Customer deleted.")
    }
    // MARK: Main Menu Operations
    func mainMenu() {
        var running = true
        while running {
            print("""
            \nRestaurant Management System
            1. Menu Items
            2. Orders
            3. Customers
            0. Exit
            Enter your choice:
            """)
            if let choice = readLine() {
                switch choice {
                case "1":
                    menuItemsMenu()
                case "2":
                    ordersMenu()
                case "3":
                    customersMenu()
                case "0":
                    running = false
                default:
                    print("Invalid choice. Please try again.")
                }
            }
        }
    }
    // MARK: Menu Items
    func menuItemsMenu() {
        var running = true
        while running {
            print("""
            \nMenu Items
            1. Add Menu Item
            2. View Menu Items
            3. Update Menu Item
            4. Delete Menu Item
            0. Back
            Enter your choice:
            """)
            if let choice = readLine() {
                switch choice {
                case "1":
                    addMenuItem()
                case "2":
                    viewMenuItems()
                case "3":
                    updateMenuItem()
                case "4":
                    deleteMenuItem()
                case "0":
                    running = false
                default:
                    print("Invalid choice. Please try again.")
                }
            }
        }
    }
    
    // MARK: Orders
    func ordersMenu() {
        var running = true
        while running {
            print("""
            \nOrders
            1. Place Order
            2. View Orders
            3. Update Order
            4. Cancel Order
            0. Back
            Enter your choice:
            """)
            if let choice = readLine() {
                switch choice {
                case "1":
                    placeOrder()
                case "2":
                    viewOrders()
                case "3":
                    updateOrder()
                case "4":
                    cancelOrder()
                case "0":
                    running = false
                default:
                    print("Invalid choice. Please try again.")
                }
            }
        }
    }
    
    // MARK: Customers Sub-Menu
    func customersMenu() {
        var running = true
        while running {
            print("""
            \nCustomers
            1. Register Customer
            2. View Customers
            3. Update Customer
            4. Delete Customer
            0. Back
            Enter your choice:
            """)
            if let choice = readLine() {
                switch choice {
                case "1":
                    registerCustomer()
                case "2":
                    viewCustomers()
                case "3":
                    updateCustomer()
                case "4":
                    deleteCustomer()
                case "0":
                    running = false
                default:
                    print("Invalid choice. Please try again.")
                }
            }
        }
    }
}

// MARK: - Run the Application
let restaurantManagement = RestaurantManagement()
restaurantManagement.initializeSampleData()
restaurantManagement.mainMenu()
