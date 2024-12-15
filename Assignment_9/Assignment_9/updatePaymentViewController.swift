//
//  updatePaymentViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 11/3/24.
//

import UIKit

class updatePaymentViewController: UIViewController {

    @IBOutlet weak var paymentStatusPicker: UIPickerView!
    @IBOutlet weak var updatePaymentButton: UIButton!
    @IBOutlet weak var paymentMethodTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    var selectedPayment: Payment?
    
    let paymentStatuses = ["Pending", "Processed", "Failed"]
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField.keyboardType = .decimalPad
        // Do any additional setup after loading the view.
        // Populate fields with selected payment details
        paymentStatusPicker.delegate = self
        paymentStatusPicker.dataSource = self
        if let payment = selectedPayment {
            amountTextField.text = "\(payment.paymentAmount)" // Display amount
            paymentMethodTextField.text = payment.paymentMethod // Display method
            
            // Set the picker to the current status
            if let index = paymentStatuses.firstIndex(of: payment.status) {
                    paymentStatusPicker.selectRow(index, inComponent: 0, animated: false)
                }
        }
    }


    @IBAction func updatePaymentTapped(_ sender: Any) {
        guard let selectedPayment = selectedPayment else { return }

                // Validate input
                guard let amountText = amountTextField.text,
                      let amount = Double(amountText) else {
                    showMessage("Please enter a valid payment amount.")
                    return
                }
                
                guard let method = paymentMethodTextField.text, !method.isEmpty else {
                    showMessage("Please enter a valid payment method.")
                    return
                }
                
                let selectedStatus = paymentStatuses[paymentStatusPicker.selectedRow(inComponent: 0)]

                // Perform the update
                DataManager.shared.updatePayment(
                    at: selectedPayment.id, // Ensure this ID matches the payment ID in your database
                    policyId: selectedPayment.policyId,
                    paymentAmount: amount,
                    paymentDate: selectedPayment.paymentDate, // Update if necessary
                    paymentMethod: method,
                    status: selectedStatus
                )
                
                showMessage("Payment updated successfully!")
                navigationController?.popViewController(animated: true)
    }
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
extension updatePaymentViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return paymentStatuses.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return paymentStatuses[row]
    }
}

