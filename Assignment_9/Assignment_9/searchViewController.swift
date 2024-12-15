//
//  searchViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 11/3/24.
//


import UIKit

class searchiewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchAll: UITableView!
    @IBOutlet weak var searchBarAll: UISearchBar!
    @IBOutlet weak var searchSegmentedControl: UISegmentedControl!
    
    
    var customers: [Customer] = []
    var policies: [Policy] = []
    var claims: [Claims] = []
    
    var filteredCustomers: [Customer] = []
    var filteredPolicies: [Policy] = []
    var filteredClaims: [Claims] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up table view
        searchAll.dataSource = self
        searchAll.delegate = self
        
        // Load data from DataManager
        loadData()
        
        // Set the initial filter for the table view
        filteredCustomers = customers
        filteredPolicies = policies
        filteredClaims = claims
        
        // Reload the table view
        searchAll.reloadData()
    }
    func loadData() {
          // Load all data from the DataManager
          customers = DataManager.shared.getCustomers()
          policies = DataManager.shared.getPolicies()
          claims = DataManager.shared.getClaims()
      }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {

        loadData() // Load data based on the selected segment
        searchAll.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCustomers = customers
            filteredPolicies = policies
            filteredClaims = claims
        } else {
            switch searchSegmentedControl.selectedSegmentIndex {
            case 0: // Customers (Search by name)
                filteredCustomers = customers.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
            case 1: // Policies (Search by policy ID)
                filteredPolicies = policies.filter {
                    "\($0.id)".contains(searchText) // Filter by policy ID
                }
            case 2: // Claims (Search by claim ID or policy ID)
                filteredClaims = claims.filter {
                    "\($0.id)".contains(searchText) || // Filter by claim ID
                    "\($0.policyId)".contains(searchText) || // Filter by policy ID
                    $0.status.lowercased().contains(searchText.lowercased()) // Optionally filter by status
                }
            default:
                break
            }
        }
        
        // Refresh the table view to show filtered results
        searchAll.reloadData()
        
        // Check if there are no results for the selected segment
        if searchSegmentedControl.selectedSegmentIndex == 0 && filteredCustomers.isEmpty {
            // If no customers were found, show an alert
            showAlert(message: "No customers found for '\(searchText)'")
        } else if searchSegmentedControl.selectedSegmentIndex == 1 && filteredPolicies.isEmpty {
            // If no policies were found, show an alert
            showAlert(message: "No policies found for '\(searchText)'")
        } else if searchSegmentedControl.selectedSegmentIndex == 2 && filteredClaims.isEmpty {
            // If no claims were found, show an alert
            showAlert(message: "No claims found for '\(searchText)'")
        }
    }

    func showAlert(message: String) {
        // Create an alert
        let alert = UIAlertController(title: "No Results", message: message, preferredStyle: .alert)
        
        // Add a "OK" button to dismiss the alert
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    // MARK: - UITableViewDataSource Methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // or the number of sections you need
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch searchSegmentedControl.selectedSegmentIndex {
        case 0: // Customers
            return filteredCustomers.count
        case 1: // Policies
            return filteredPolicies.count
        case 2: // Claims
            return filteredClaims.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCells", for: indexPath)
        
        switch searchSegmentedControl.selectedSegmentIndex {
        case 0: // Customers
            let customer = filteredCustomers[indexPath.row]
            cell.textLabel?.text = "ID: \(customer.id) Name: \(customer.name)"
        case 1: // Policies
            let policy = filteredPolicies[indexPath.row]
            cell.textLabel?.text = "Policy ID: \(policy.id) Description: \(policy.policyType)"
        case 2: // Claims
            let claim = filteredClaims[indexPath.row]
            cell.textLabel?.text = "Claim ID: \(claim.id) Amount: \(claim.claimAmount)"
        default:
            break
        }

        return cell
    }}
