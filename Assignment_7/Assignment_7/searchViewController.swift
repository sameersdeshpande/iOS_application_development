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
            // Reset filters
            filteredClaims = claims
        } else {
            switch searchSegmentedControl.selectedSegmentIndex {
            case 0: // Customers
                filteredCustomers = customers.filter {
                    $0.name.lowercased().contains(searchText.lowercased())
                }
            case 1: // Policies
                filteredPolicies = policies.filter {
                    "\($0.id)".contains(searchText) // Use the correct policy property
                }
            case 2: // Claims
                filteredClaims = claims.filter {
                    "\($0.id)".contains(searchText) || // Filter by claim ID
                    "\($0.policyId)".contains(searchText) || // Filter by policy ID
                    $0.status.lowercased().contains(searchText.lowercased()) // Optionally filter by status
                }
            default:
                break
            }
        }
        searchAll.reloadData() // Refresh the table view
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
