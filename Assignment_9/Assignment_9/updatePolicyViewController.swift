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
        premiumAmountTextField.keyboardType = .decimalPad
        super.viewDidLoad()
        if let policy = policy {
            policyTypeTextField.text = policy.policyType
            premiumAmountTextField.text = "\(policy.premiumAmount)"
            
            // Set the end date picker to the existing end date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" // Ensure this matches your date format in Policy
            

            // Parse the end date
            if let endDate = dateFormatter.date(from: policy.endDate) {
                endDatePicker.date = endDate
            }
            
    
        }
    }

    @IBAction func updateButtonTapped(_ sender: Any) {
        guard let existingPolicy = policy else {
                    print("No policy found to update")
                    return
                }

                // Get the updated values from the UI
                let policyType = policyTypeTextField.text ?? existingPolicy.policyType
                let premiumAmount = Double(premiumAmountTextField.text ?? "") ?? existingPolicy.premiumAmount
                
                // Get the updated end date and convert it back to a string
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd" // Matching the expected format for your backend or API
                dateFormatter.timeZone = TimeZone(identifier: "UTC")  // Explicitly set UTC to prevent DST issues
                
                let endDateString = dateFormatter.string(from: endDatePicker.date)
                
                print("Formatted endDate to send: \(endDateString)")  // Log the formatted end date
                
                // Call the DataManager to update the policy
                DataManager.shared.updatePolicy(at: existingPolicy.id,
                                                  customerId: existingPolicy.customerId,
                                                  policyType: policyType,
                                                  premiumAmount: premiumAmount,
                                                  startDate: existingPolicy.startDate, // Keep start date unchanged
                                                  endDate: endDateString)  // Pass the formatted end date

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

