//
//  updatePolicyViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 11/3/24.
//


import UIKit

class updatePolicyViewController: UIViewController {

    @IBOutlet weak var updatePolicyButton: UIButton!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var premiumAmountTextField: UITextField!
    @IBOutlet weak var policyTypeTextField: UITextField!
    
    
    var policy: Policy?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Populate the fields with the existing policy data
        if let policy = policy {
            policyTypeTextField.text = policy.policyType
            premiumAmountTextField.text = "\(policy.premiumAmount)"
            
            // Set the end date picker to the existing end date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Ensure this matches your date format
            if let endDate = dateFormatter.date(from: policy.endDate) {
                endDatePicker.date = endDate
            }
        }
    }


    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let existingPolicy = policy else { return }
        // Get the updated values from the UI
        let policyType = policyTypeTextField.text ?? existingPolicy.policyType
        let premiumAmount = Double(premiumAmountTextField.text ?? "") ?? existingPolicy.premiumAmount
        let endDate = DateFormatter.localizedString(from: endDatePicker.date, dateStyle: .short, timeStyle: .none)
        // Call the DataManager to update the policy
        DataManager.shared.updatePolicy(at: existingPolicy.id,
                                          customerId: existingPolicy.customerId,
                                          policyType: policyType,
                                          premiumAmount: premiumAmount,
                                          startDate: existingPolicy.startDate, // Keep start date unchanged
                                          endDate: endDate)

        // Show success message
        showMessage("Policy updated successfully!")

        // Go back to the previous screen
        navigationController?.popViewController(animated: true)
    }
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

