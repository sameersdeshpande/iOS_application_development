import UIKit

class PaymentsViewController: UIViewController {

    @IBOutlet weak var paymentViewButton: UIButton!
    @IBOutlet weak var paymentUpdateButton: UIButton!
    @IBOutlet weak var paymentDeleteButton: UIButton!
    @IBOutlet weak var paymentMethodTextField: UITextField!
    @IBOutlet weak var listPaymentsTableView: UITableView!


    @IBOutlet weak var paymentStatusPicker: UIPickerView!
    @IBOutlet weak var paymentDatePicker: UIDatePicker!
    @IBOutlet weak var paymentAmountTextField: UITextField!
    @IBOutlet weak var policyIdPickerView: UIPickerView!
    @IBOutlet weak var paymentRecordButton: UIButton!
    var selectedPayment: Payment? // For updating and deleting
    let paymentStatuses = ["Pending", "Processed", "Failed"]
    var policies: [Policy] = [] // Store policies here
    var payments: [Payment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        paymentAmountTextField.keyboardType = .decimalPad
        paymentStatusPicker.delegate = self
        paymentStatusPicker.dataSource = self
        policyIdPickerView.delegate = self
        policyIdPickerView.dataSource = self
        listPaymentsTableView.delegate = self
        listPaymentsTableView.dataSource = self
        paymentUpdateButton.isEnabled = false
        paymentDeleteButton.isEnabled = false
        loadPolicies()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPaymentList() // Call your method to refresh the list
    }
    func refreshPaymentList() {
        payments = DataManager.shared.getPayments() // Fetch updated payments from the DataManager
        listPaymentsTableView.reloadData() // Reload the table view
    }

    
    private func loadPolicies() {
        policies = DataManager.shared.getPolicies()
        policyIdPickerView.reloadAllComponents() // Refresh the picker view
    }

    @IBAction func paymentViewButton(_ sender: Any) {

        let payments = DataManager.shared.getPayments()
        listPaymentsTableView.isHidden.toggle()
                listPaymentsTableView.reloadData()
                updateButtonStates()
    }
    private func updateButtonStates() {
        paymentDeleteButton.isEnabled = selectedPayment != nil
        paymentUpdateButton.isEnabled = selectedPayment != nil
    }
    
    @IBAction func paymentDeleteButton(_ sender: Any) {
        guard let selectedPayment = selectedPayment else { return }
        if selectedPayment.status == "Processed" {
            showAlert(message: "You cannot delete a payment that has been processed.")
            return
        }
        if let index = DataManager.shared.getPayments().firstIndex(where: { $0.id == selectedPayment.id }) {
            DataManager.shared.removePayment(at: index)
            paymentViewButton(sender) // Refresh the table view
            self.selectedPayment = nil // Reset selection
            showMessage("Payment deleted successfully!")
        } else {
            showAlert(message: "Payment not found.")
        }
    }
    // Helper function to show an alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func paymentUpdateButton(_ sender: Any) {
        guard let selectedPayment = selectedPayment else { return }
        performSegue(withIdentifier: "toUpdatePayments", sender: self)

        paymentRecordButton.isEnabled = true
        paymentUpdateButton.isEnabled = false
        paymentDeleteButton.isEnabled = false

        self.selectedPayment = nil
        resetFields()
        paymentViewButton(sender)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdatePayments" {
            if let destinationVC = segue.destination as? updatePaymentViewController {
                destinationVC.selectedPayment = selectedPayment // Pass the selected payment object
            }
        }
    }

    
//MARK: Record Payment
    @IBAction func paymentRecordButton(_ sender: Any) {
        
        // Ensure the payment amount is valid
        guard let amountText = paymentAmountTextField.text,
              let amount = Double(amountText) else {
            showMessage("Please enter a valid payment amount.")
            return
        }

        // Get the selected policy ID
        let selectedPolicyId = policies[policyIdPickerView.selectedRow(inComponent: 0)].id
        
        // Format the date from the date picker
        let paymentDate = dateFormatter.string(from: paymentDatePicker.date)

        // Get the selected payment method
        guard let paymentMethod = paymentMethodTextField.text, !paymentMethod.isEmpty else {
            showMessage("Please enter a valid payment method.")
            return
        }

        // Get the selected payment status
        let selectedStatus = paymentStatuses[paymentStatusPicker.selectedRow(inComponent: 0)]

        // Add the payment to the DataManager
        DataManager.shared.addPayment(policyId: selectedPolicyId, paymentAmount: amount, paymentDate: paymentDate, paymentMethod: paymentMethod, status: selectedStatus)

        // Refresh the payments list
        paymentViewButton(sender)

        // Show success message
        showMessage("Payment recorded successfully!")

        // Reset the input fields
        resetFields()
    }

    // Helper function to reset the input fields
    private func resetFields() {
        paymentAmountTextField.text = ""
        paymentMethodTextField.text = ""
        paymentDatePicker.setDate(Date(), animated: true) // Reset date picker to current date
        policyIdPickerView.selectRow(0, inComponent: 0, animated: true) // Reset to first policy
        paymentStatusPicker.selectRow(0, inComponent: 0, animated: true) // Reset to first status
    }


    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


 

    // DateFormatter for formatting the date from UIDatePicker
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Adjust to your desired format
        return formatter
    }
}

// MARK: - UIPickerViewDelegate and UIPickerViewDataSource
extension PaymentsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == paymentStatusPicker {
            return paymentStatuses.count
        } else if pickerView == policyIdPickerView {
            return policies.count // Return the number of policies
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == paymentStatusPicker {
            return paymentStatuses[row]
        } else if pickerView == policyIdPickerView {
            return "\(policies[row].id)" // Display policy ID
        }
        return nil
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension PaymentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.getPayments().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath)
        let payment = DataManager.shared.getPayments()[indexPath.row]
        cell.textLabel?.text = "\(payment.paymentMethod): \(payment.paymentAmount) - \(payment.status)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Retrieve the selected payment
        selectedPayment = DataManager.shared.getPayments()[indexPath.row]
        
        // Update the payment amount and method text fields
        paymentAmountTextField.text = "\(selectedPayment?.paymentAmount ?? 0)"
        paymentMethodTextField.text = selectedPayment?.paymentMethod

        // Set the date on the date picker
        if let paymentDate = selectedPayment?.paymentDate,
           let date = dateFormatter.date(from: paymentDate) {
            paymentDatePicker.setDate(date, animated: true) // Set the date on the picker
        }

        // Set selected index for policy ID picker
        if let policyIndex = policies.firstIndex(where: { $0.id == selectedPayment?.policyId }) {
            policyIdPickerView.selectRow(policyIndex, inComponent: 0, animated: true)
        }

        // Optionally set the payment status picker if needed
        if let statusIndex = paymentStatuses.firstIndex(of: selectedPayment?.status ?? "") {
            paymentStatusPicker.selectRow(statusIndex, inComponent: 0, animated: true)
        }

        // Enable update and delete buttons, disable record button
        paymentUpdateButton.isEnabled = true
        paymentDeleteButton.isEnabled = true
        paymentRecordButton.isEnabled = false
    }

}
