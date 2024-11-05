import UIKit

class ClaimsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var policyStatusPicker: UIPickerView!
    @IBOutlet weak var viewButtonClaim: UIButton!
    @IBOutlet weak var addClaimButton: UIButton!
    @IBOutlet weak var claimDatePicker: UIDatePicker!
    @IBOutlet weak var listClaimsTableView: UITableView!
    @IBOutlet weak var deleteClaimButton: UIButton!
    @IBOutlet weak var updateClaimButton: UIButton!
    @IBOutlet weak var amountClaimedTextField: UITextField!
    @IBOutlet weak var policyIDPicker: UIPickerView!
    var claims: [Claims] = []
    @IBOutlet weak var searchClaimsBar: UISearchBar!
    var selectedClaimIndex: Int?
    let statusOptions = ["Pending", "Approved", "Rejected"]
    var filteredClaims: [Claims] = [] // Add a property to hold filtered claims
    var isSearching = false // Track if we are searching
    override func viewDidLoad() {
        super.viewDidLoad()
        loadClaims()
        listClaimsTableView.dataSource = self
        listClaimsTableView.delegate = self
        listClaimsTableView.isHidden = true
        policyIDPicker.dataSource = self
        policyIDPicker.delegate = self
        policyStatusPicker.dataSource = self // Set up status picker
        policyStatusPicker.delegate = self // Set up status picker
        loadPolicies()
        searchClaimsBar.delegate = self
        updateButtonStates()
        NotificationCenter.default.addObserver(self, selector: #selector(loadClaims), name: NSNotification.Name("ClaimsUpdated"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadClaims() // Your method to refresh the claims list
        listClaimsTableView.reloadData()
    }

    func loadPolicies() {
        policyIDPicker.reloadAllComponents()
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // One component for policy IDs and status
    }
    @objc func loadClaims() {
        claims = DataManager.shared.getClaims() // Assuming getClaims fetches claims from your data source
        listClaimsTableView.reloadData() // Reload your table view to reflect the new data
    }
    deinit {
        NotificationCenter.default.removeObserver(self) // Clean up observer
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == policyIDPicker {
            return DataManager.shared.getPolicies().count // Number of policies
        } else {
            return statusOptions.count // Number of status options
        }
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == policyIDPicker {
            let policy = DataManager.shared.getPolicies()[row]
            return "\(policy.id)" // Show policy ID
        } else {
            return statusOptions[row] // Show status option
        }
    }

    @IBAction func addClaimTapped(_ sender: Any) {
        guard let claimAmountString = amountClaimedTextField.text,
              let claimAmount = Double(claimAmountString) else {
            showMessage("Please enter a valid claim amount.")
            return
        }

        let policyId = DataManager.shared.getPolicies()[policyIDPicker.selectedRow(inComponent: 0)].id // Get selected policy ID
        let claimDate = DateFormatter.localizedString(from: claimDatePicker.date, dateStyle: .short, timeStyle: .none)

        DataManager.shared.addClaim(policyId: policyId, claimAmount: claimAmount, dateOfClaim: claimDate, status: "Pending")

        resetForm()
        listClaimsTableView.reloadData()
        showMessage("Claim added successfully!")
    }

    @IBAction func updateClaimTapped(_ sender: Any) {
        guard let index = selectedClaimIndex else { return }
     
        let selectedClaim = isSearching ? filteredClaims[index] : claims[index]
         
         performSegue(withIdentifier: "toUpdateClaims", sender: selectedClaim)
  
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateClaims" {
            if let destinationVC = segue.destination as? updateClaimViewController,
               let claim = sender as? Claims {
                destinationVC.selectedClaim = claim
            }
        }
    }

    @IBAction func deleteClaimTapped(_ sender: Any) {
        guard let index = selectedClaimIndex else { return }
        let claim = DataManager.shared.getClaims()[index]

        // Ensure that approved claims cannot be deleted
        if claim.status == "Approved" {
            showMessage("Approved claims cannot be deleted.")
            return
        }
        DataManager.shared.removeClaim(at: index)
        resetForm()
        listClaimsTableView.reloadData()
        showMessage("Claim deleted successfully!")
    }

    @IBAction func viewClaimTapped(_ sender: Any) {
        listClaimsTableView.isHidden.toggle()
        listClaimsTableView.reloadData()
        updateButtonStates()
    }

    func resetForm() {
        amountClaimedTextField.text = ""
        selectedClaimIndex = nil
        policyIDPicker.selectRow(0, inComponent: 0, animated: false)
        claimDatePicker.date = Date()
        policyStatusPicker.selectRow(0, inComponent: 0, animated: false)
        isSearching = false // Reset search state
        filteredClaims.removeAll() // Clear any filtered results
        listClaimsTableView.reloadData() // Reload data to show all claims
        updateButtonStates()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredClaims = DataManager.shared.getClaims() // Show all claims
        } else {
            isSearching = true
            if let searchID = Int(searchText) {
                filteredClaims = DataManager.shared.getClaims().filter { $0.id == searchID } // Filter by claim ID
                
                // Check if no claims were found
                if filteredClaims.isEmpty {
                    showMessage("No claim found with ID '\(searchID)'.")
                }
            } else {
                filteredClaims = [] // Clear filtered results if input is not a valid number
            }
        }
        listClaimsTableView.reloadData()
    }


    func updateButtonStates() {
        let hasSelectedClaim = selectedClaimIndex != nil
        updateClaimButton.isEnabled = hasSelectedClaim
        deleteClaimButton.isEnabled = hasSelectedClaim
        addClaimButton.isEnabled = !hasSelectedClaim // Disable addClaimButton if a claim is selected
    }

    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredClaims.count : DataManager.shared.getClaims().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClaimCell", for: indexPath)
        let claim = isSearching ? filteredClaims[indexPath.row] : DataManager.shared.getClaims()[indexPath.row]
        cell.textLabel?.text = "ID: \(claim.id) - Amount: \(claim.claimAmount) - Status: \(claim.status)"
        return cell
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedClaimIndex = indexPath.row
        let claim = DataManager.shared.getClaims()[selectedClaimIndex!]
        amountClaimedTextField.text = "\(claim.claimAmount)"
        
        // Set the status picker to the current status of the claim
        if let statusIndex = statusOptions.firstIndex(of: claim.status) {
            policyStatusPicker.selectRow(statusIndex, inComponent: 0, animated: true)
        }
        
        updateButtonStates()
    }
}
