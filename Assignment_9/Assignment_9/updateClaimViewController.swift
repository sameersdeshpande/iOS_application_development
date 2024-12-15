//
//  updateClaimViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 11/3/24.
//

import UIKit

class updateClaimViewController: UIViewController {
    @IBOutlet weak var updateButtonTapped: UIButton!
    
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var amountClaimedTextField: UITextField!
    
     var selectedClaim: Claims?
     
     let claimStatuses = ["Pending", "Approved", "Rejected"]
    override func viewDidLoad() {
        super.viewDidLoad()
        amountClaimedTextField.keyboardType = .decimalPad
        statusPicker.delegate = self
          statusPicker.dataSource = self
        // Do any additional setup after loading the view.
        if let claim = selectedClaim {
            amountClaimedTextField.text = "\(claim.claimAmount)" // Display current claim amount
            
            // Set the picker to the current status
            if let index = claimStatuses.firstIndex(of: claim.status) {
                statusPicker.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let claim = selectedClaim else { return }
                
                // Validate input
                guard let amountText = amountClaimedTextField.text,
                      let amount = Double(amountText) else {
                    showMessage("Please enter a valid claim amount.")
                    return
                }
                
                let selectedStatus = claimStatuses[statusPicker.selectedRow(inComponent: 0)]
                
                // Perform the update
                DataManager.shared.updateClaim(
                    at: claim.id, // Use claim ID for updating
                    policyId: claim.policyId, // Assuming you still want to keep this for consistency
                    claimAmount: amount,
                    dateOfClaim: claim.dateOfClaim, // Not updating this
                    status: selectedStatus
                )
                
                showMessage("Claim updated successfully!")
        // Notify the previous view controller to reload data
        NotificationCenter.default.post(name: NSNotification.Name("ClaimsUpdated"), object: nil)

        navigationController?.popViewController(animated: true)
    }
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
extension updateClaimViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return claimStatuses.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return claimStatuses[row]
    }
}
