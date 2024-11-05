//
//  PolicyViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/23/24.
//

import UIKit

class PolicyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var addPolicyButton: UIButton!
    @IBOutlet weak var updatePolicyButton: UIButton!
    @IBOutlet weak var listPoliciesTable: UITableView!
    @IBOutlet weak var deletePolicyButton: UIButton!
    @IBOutlet weak var viewPolicyButton: UIButton!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var premiumAmountTextField: UITextField!
    @IBOutlet weak var policyTypeTextField: UITextField!
    @IBOutlet weak var customerIDPicker: UIPickerView!
    
    @IBOutlet weak var searchPolicyBar: UISearchBar!
    var filteredPolicies: [Policy] = []
    var isSearching = false
    var selectedPolicyIndex: Int?
    var selectedCustomerId: Int?
    var isPoliciesVisible = false
    var policies: [Policy] = []
    var customerIDs: [Int] = []
    var customers: [Customer] = DataManager.shared.getCustomers()
    required init?(coder: NSCoder) {
           super.init(coder: coder)
           // Any additional setup
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        listPoliciesTable.dataSource = self
        listPoliciesTable.delegate = self
        customerIDPicker.dataSource = self
        customerIDPicker.delegate = self
        searchPolicyBar.delegate = self
        loadCustomers()
        customerIDs = [0] + customers.map { $0.id }
        customers = DataManager.shared.getCustomers()
        listPoliciesTable.isHidden = true
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        // Initially disable update and delete buttons
        reloadPolicies() 
        updatePolicyButton.isEnabled = false
        deletePolicyButton.isEnabled = false
        if !customers.isEmpty {
              customerIDPicker.selectRow(0, inComponent: 0, animated: false)
          }
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPolicies()
    }
    func reloadPolicies() {
          policies = DataManager.shared.getPolicies() // Fetch the latest policies
          listPoliciesTable.reloadData() // Reload the table view
      }
        // MARK: - Customer Picker Data
        func loadCustomers() {
            customers = DataManager.shared.getCustomers()
            customerIDPicker.reloadAllComponents()
            print("Loaded Customers: \(customers.map { $0.id })")
        }
    @objc func startDateChanged() {
           // Set the minimum date of endDatePicker to the selected start date
           endDatePicker.minimumDate = startDatePicker.date
       }

    @IBAction func addPolicyTapped(_ sender: UIButton) {
        guard let policyType = policyTypeTextField.text, !policyType.isEmpty,
                  let premiumString = premiumAmountTextField.text, let premiumAmount = Double(premiumString) else {
                showMessage("Please fill in all fields correctly.")
                return
            }

            // Get the selected index from the customer ID picker
            let selectedIndex = customerIDPicker.selectedRow(inComponent: 0)

            // Determine the customer ID based on the selected index
            let customerId: Int
            if selectedIndex == 0 {
                customerId = 0 // If "NONE" is selected
            } else {
                customerId = customers[selectedIndex - 1].id // Get the correct customer ID
            }

            // Add the policy using the selected customer ID
            DataManager.shared.addPolicy(customerId: customerId, policyType: policyType, premiumAmount: premiumAmount, startDate: formatDate(startDatePicker.date), endDate: formatDate(endDatePicker.date))
            
            // Show success message
            showMessage("Policy added successfully!")

            // Reset form fields
            policyTypeTextField.text = ""
            premiumAmountTextField.text = ""
            customerIDPicker.selectRow(0, inComponent: 0, animated: true) // Reset to "NONE"
            startDatePicker.date = Date() // Reset to current date
            endDatePicker.date = Date() // Reset to current date
            
            // Reload the policies table view to reflect the newly added policy
            listPoliciesTable.reloadData()
    }

        
    @IBAction func viewPoliciesTapped(_ sender: UIButton) {
        isPoliciesVisible.toggle() // Toggle the visibility state
        listPoliciesTable.isHidden = !isPoliciesVisible // Show or hide the table view

        // Update button title based on visibility state
        if isPoliciesVisible {
            viewPolicyButton.setTitle("Hide", for: .normal)
            listPoliciesTable.reloadData() // Reload data when showing
        } else {
            viewPolicyButton.setTitle("View", for: .normal)
        }
    }
        
    @IBAction func updatePolicyTapped(_ sender: UIButton) {
        guard let index = selectedPolicyIndex else { return }

//        let existingPolicy = DataManager.shared.getPolicies()[index]
//        let policyType = policyTypeTextField.text ?? existingPolicy.policyType
//        let premiumAmount = Double(premiumAmountTextField.text ?? "") ?? existingPolicy.premiumAmount
//        let startDate = DateFormatter.localizedString(from: startDatePicker.date, dateStyle: .short, timeStyle: .none) // Keep start date unchanged
//        let endDate = DateFormatter.localizedString(from: endDatePicker.date, dateStyle: .short, timeStyle: .none)
//        // Update policy with existing customerId
//        DataManager.shared.updatePolicy(at: existingPolicy.id,
//                                          customerId: existingPolicy.customerId,
//                                          policyType: policyType,
//                                          premiumAmount: premiumAmount,
//                                          startDate: startDate,
//                                          endDate: endDate)
//        // Reset the form and reload the table view
//        resetForm()
//        listPoliciesTable.reloadData()
        // Get the selected policy to pass to the update view controller
        let existingPolicy = DataManager.shared.getPolicies()[index]
        // Perform the segue to the UpdatePolicyViewController
        performSegue(withIdentifier: "toUpdatePolicy", sender: existingPolicy)
        // Re-enable add policy button and disable update/delete buttons
             addPolicyButton.isEnabled = true
             updatePolicyButton.isEnabled = false
             deletePolicyButton.isEnabled = false
    }

    let dateFormatter: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd" // Adjust this format based on your date format
         return formatter
     }()
    
    @IBAction func deletePolicyTapped(_ sender: UIButton) {
        guard let index = selectedPolicyIndex else { return }
            
            let policy = DataManager.shared.getPolicies()[index]
            
            // Check if the policy is linked to a customer and its end date is in the future
            if policy.customerId != 0 , let endDate = dateFormatter.date(from: policy.endDate),
               endDate > Date() {
                
                // If both conditions are true, show a message and prevent deletion
                showMessage("Cannot delete policy linked to a customer with a future end date!")
                return
            }
            
            // Proceed to delete the policy
        DataManager.shared.removePolicy(id: policy.id)
            
            resetForm()
            listPoliciesTable.reloadData()
            
            addPolicyButton.isEnabled = true
            updatePolicyButton.isEnabled = false
            deletePolicyButton.isEnabled = false
            
            showMessage("Policy deleted successfully!")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdatePolicy" {
            if let destinationVC = segue.destination as? updatePolicyViewController,
               let policy = sender as? Policy {
                destinationVC.policy = policy // Pass the selected policy to the update screen
            }
        }
    }
        // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredPolicies.count : DataManager.shared.getPolicies().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Policy Cell", for: indexPath)
        let policy = isSearching ? filteredPolicies[indexPath.row] : DataManager.shared.getPolicies()[indexPath.row]
        cell.textLabel?.text = "ID: \(policy.id) | Type: \(policy.policyType) | Start: \(policy.startDate) | End: \(policy.endDate) | Premium: \(policy.premiumAmount)"
        cell.detailTextLabel?.text = nil
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPolicyIndex = indexPath.row
        let policy = DataManager.shared.getPolicies()[selectedPolicyIndex!]

        // Set policy type and premium amount in text fields
        policyTypeTextField.text = policy.policyType
        premiumAmountTextField.text = "\(policy.premiumAmount)"

        // Set date pickers
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Ensure this matches your date format in Policy

        if let startDate = dateFormatter.date(from: policy.startDate) {
            startDatePicker.date = startDate
        }
        if let endDate = dateFormatter.date(from: policy.endDate) {
            endDatePicker.date = endDate
        }

        // Set minimum date for endDatePicker
        endDatePicker.minimumDate = startDatePicker.date

        if policy.customerId == 0 {
            customerIDPicker.selectRow(0, inComponent: 0, animated: true) // Select "NONE"
        } else if let customerIndex = customers.firstIndex(where: { $0.id == policy.customerId }) {
            customerIDPicker.selectRow(customerIndex + 1, inComponent: 0, animated: true) // Adjust index for the actual customer
        }

        
        // Enable update and delete buttons, disable add policy button
        updatePolicyButton.isEnabled = true
        deletePolicyButton.isEnabled = true
        addPolicyButton.isEnabled = false

       }
    // MARK: - Picker View Data Source
 

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customerIDs.count // Total rows equal to customer IDs including "NONE"
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if customerIDs[row] == 0 {
            return "NONE" // Display "NONE" for the first row
        } else {
            return "\(customerIDs[row])" // Display the actual customer ID
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Set selected customer ID directly from the customerIDs array
        selectedCustomerId = customerIDs[row] == 0 ? nil : customerIDs[row]
        print("Selected Customer ID: \(String(describing: selectedCustomerId))") // Debugging
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredPolicies = DataManager.shared.getPolicies() // Show all policies
        } else {
            isSearching = true
            filteredPolicies = DataManager.shared.getPolicies().filter { $0.id == Int(searchText) }
            
            // Check if no results found
            if filteredPolicies.isEmpty {
                showMessage("No policies found matching ID '\(searchText)'.")
            }
        }
        listPoliciesTable.reloadData()
    }

        // MARK: - Reset Form
        func resetForm() {
         
               premiumAmountTextField.text = ""
               customerIDPicker.selectRow(0, inComponent: 0, animated: true) // Reset to "NONE"
               startDatePicker.date = Date() // Reset to current date
               endDatePicker.date = Date() // Reset to current date
            policyTypeTextField.text = ""
            selectedPolicyIndex = nil
            listPoliciesTable.isHidden = true // Hide the table view when no policies are added
        }
        
        // MARK: - Message Alert
        func showMessage(_ message: String) {
            let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    
    
    private func formatDate(_ date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateStyle = .short
         return formatter.string(from: date)
     }
    }


