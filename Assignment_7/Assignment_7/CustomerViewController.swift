//
//  CustomerViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/22/24.
//

import Foundation
import UIKit

class CustomerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate{

    @IBOutlet weak var searchCustomer: UISearchBar!
    @IBOutlet weak var customerstableView: UITableView!
    @IBOutlet weak var buttonDeleteCustomer: UIButton!
    @IBOutlet weak var buttonUpdateCustomer: UIButton!
    @IBOutlet weak var buttonViewCustomer: UIButton!
    @IBOutlet weak var buttonAddCustomer: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var selectedCustomerIndex: Int?
    var customers: [Customer] = [] // Assuming Customer is your model
    var filteredCustomers: [Customer] = []
    var isSearching: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        customerstableView.dataSource = self
        customerstableView.delegate = self
        customerstableView.isHidden = true
        customerstableView.reloadData()
        searchCustomer.delegate = self  // Set search bar delegate
        customers = DataManager.shared.getCustomers() // Load initial customers
        filteredCustomers = customers // Start with all customers
       
        updateButtonStates()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customers = DataManager.shared.getCustomers() // Refresh customer list
        
        customerstableView.reloadData() // Reload the table view
    }

    @IBAction func addCustomerTapped(_ sender: UIButton) {
        // Validate input fields
        guard let name = nameTextField.text, !name.isEmpty,
              let ageString = ageTextField.text, let age = Int(ageString), age > 0,
              let email = emailTextField.text, !email.isEmpty else {
            showMessage("Please fill in all fields correctly.")
            return
        }

        DataManager.shared.addCustomer(name: name, age: age, email: email)
        customers = DataManager.shared.getCustomers() // Refresh customer list
        resetForm()
        customerstableView.reloadData()
        showMessage("Customer added successfully!")
    }

    @IBAction func viewCustomersTapped(_ sender: UIButton) {
        if customerstableView.isHidden {
            customerstableView.isHidden = false
            customerstableView.reloadData()
        } else {
            customerstableView.isHidden = true
        }
        updateButtonStates()
    }


    @IBAction func updateCustomerTapped(_ sender: UIButton) {
        guard let index = selectedCustomerIndex else {
            showMessage("No customer selected for update.")
            return
        }
        
        // Perform the segue to the UpdateCustomerViewController
        performSegue(withIdentifier: "toUpdateCustomer", sender: self)

    }


    @IBAction func deleteCustomerTapped(_ sender: UIButton) {
        guard let index = selectedCustomerIndex else { return }
        let customer = DataManager.shared.getCustomers()[index]
        
        let associatedPolicies = DataManager.shared.getPolicies().filter { $0.customerId == customer.id }
        
        if !associatedPolicies.isEmpty {

            showMessage("This customer has associated policies and cannot be deleted.")
            return
        }

        // Remove the customer from the DataManager
       // DataManager.shared.removeCustomer(at: index)
        DataManager.shared.removeCustomer(id: customer.id)
        // Clear the text fields and reload the table
        customers = DataManager.shared.getCustomers() // Refresh customer list
    
        resetForm()
        customerstableView.reloadData()
        showMessage("Customer deleted successfully!")
    }


    func resetForm() {
        nameTextField.text = ""
        ageTextField.text = ""
        emailTextField.text = ""
        selectedCustomerIndex = nil
        updateButtonStates()
    }

    func updateButtonStates() {
        let hasSelectedCustomer = selectedCustomerIndex != nil
        buttonUpdateCustomer.isEnabled = hasSelectedCustomer
        buttonDeleteCustomer.isEnabled = hasSelectedCustomer
    }

    func showMessage(_ message: String) {
        // Show a simple alert
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredCustomers = customers
        } else {
            isSearching = true
            filteredCustomers = customers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            
            if filteredCustomers.isEmpty{
                showMessage("No customer found")
            }
        }
        customerstableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredCustomers = customers
        customerstableView.reloadData()
        searchBar.resignFirstResponder()
    }


    // MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredCustomers.count : customers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        let customer = isSearching ? filteredCustomers[indexPath.row] : customers[indexPath.row]
        cell.textLabel?.text = "ID: \(customer.id)  Name: \(customer.name) Age: \(customer.age) Email: \(customer.email)"
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateCustomer" {
            if let destinationVC = segue.destination as? updateCustomerViewController {
                if let index = selectedCustomerIndex {
                    let selectedCustomer = customers[index]
                    destinationVC.customer = selectedCustomer // Pass the selected customer
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCustomerIndex = indexPath.row

        // Get the selected customer using the correct index
        let customer = customers[selectedCustomerIndex!]

        // Populate the text fields with the selected customer's data
        nameTextField.text = customer.name
        ageTextField.text = "\(customer.age)"
        emailTextField.text = customer.email
    
        // Enable the update and delete buttons
        updateButtonStates()
    }

}
