//
//  updateCustomerViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 11/3/24.
//

import Foundation
import UIKit

class updateCustomerViewController: UIViewController {

    @IBOutlet weak var updateCustomerTapped: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var customer: Customer?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let customer = customer {
             nameTextField.text = customer.name
             ageTextField.text = "\(customer.age)"
             emailTextField.text = customer.email
         }
    }


    @IBAction func updateCustomerTapped(_ sender: Any) {
        guard let customer = customer,
                  let name = nameTextField.text, !name.isEmpty,
                  let ageString = ageTextField.text, let age = Int(ageString), age > 0 else {
                showMessage("Please fill in all fields correctly.")
                return
            }

            // Call the DataManager to update the customer
        DataManager.shared.updateCustomer(at: Int64(customer.id), name: name, age: age) // No need to update email

            // Go back to the previous screen or show a success message
            navigationController?.popViewController(animated: true)
            showMessage("Customer updated successfully!")
    }
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
