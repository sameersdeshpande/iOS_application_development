import UIKit

class InsuranceView: UIView, UITableViewDataSource, UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
   
    private var mainView: MainView!
    var policies: [InsurancePolicy] = []
    var customers: [Customer] = []

    private var policyIdCounter = 1
    private var selectedPolicyIndex: Int?
    private let customerPickerView = UIPickerView()
    private var customerIds: [Int] = [0] 
    private var selectedCustomerId: Int?
    private let policyTypeTextField = UITextField()
    
    private let premiumAmountTextField = UITextField()
    private let startDateTextField = UITextField()
    private let endDateTextField = UITextField()
    private let customerIdTextField = UITextField()
    private let addPolicyButton = UIButton(type: .system)
    private let updatePolicyButton = UIButton(type: .system)
    private let deletePolicyButton = UIButton(type: .system)
    private let viewPoliciesButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system) // Back button
    private let policiesTableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        customerPickerView.dataSource = self
        customerPickerView.delegate = self
        setupTextField(policyTypeTextField, placeholder: "Enter Policy Type")
        setupTextField(premiumAmountTextField, placeholder: "Enter Premium Amount", keyboardType: .decimalPad)
        setupTextField(startDateTextField, placeholder: "Enter Start Date (yyyy-MM-dd)")
        setupTextField(endDateTextField, placeholder: "Enter End Date (yyyy-MM-dd)")
        setupTextField(customerIdTextField, placeholder: "Enter Customer ID", keyboardType: .numberPad)
        customerIdTextField.inputView = customerPickerView
        addPolicyButton.setTitle("Add Policy", for: .normal)
        updatePolicyButton.setTitle("Update Policy", for: .normal)
        deletePolicyButton.setTitle("Delete Policy", for: .normal)
        viewPoliciesButton.setTitle("View Policies", for: .normal)
        
        addPolicyButton.addTarget(self, action: #selector(addPolicy), for: .touchUpInside)
        updatePolicyButton.addTarget(self, action: #selector(updatePolicy), for: .touchUpInside)
        deletePolicyButton.addTarget(self, action: #selector(deletePolicy), for: .touchUpInside)
        viewPoliciesButton.addTarget(self, action: #selector(viewPolicies), for: .touchUpInside)

        closeButton.setTitle("✖️", for: .normal)
        closeButton.addTarget(self, action: #selector(closePolicyList), for: .touchUpInside)

        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backToMainView), for: .touchUpInside)
        
        policiesTableView.dataSource = self
        policiesTableView.delegate = self
        policiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PolicyCell")
        
        addSubviews()
        setupConstraints()
    }
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews() {
        addSubview(policyTypeTextField)
        addSubview(premiumAmountTextField)
        addSubview(startDateTextField)
        addSubview(endDateTextField)
        addSubview(customerIdTextField)
        addSubview(addPolicyButton)
        addSubview(updatePolicyButton)
        addSubview(deletePolicyButton)
        addSubview(viewPoliciesButton)
        addSubview(closeButton)
        addSubview(backButton)
        addSubview(policiesTableView)
    }
    //MARK: SETUP CONSTRAINTS
    private func setupConstraints() {
        customerIdTextField.translatesAutoresizingMaskIntoConstraints = false
        policyTypeTextField.translatesAutoresizingMaskIntoConstraints = false
        premiumAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        startDateTextField.translatesAutoresizingMaskIntoConstraints = false
        endDateTextField.translatesAutoresizingMaskIntoConstraints = false
        addPolicyButton.translatesAutoresizingMaskIntoConstraints = false
        updatePolicyButton.translatesAutoresizingMaskIntoConstraints = false
        deletePolicyButton.translatesAutoresizingMaskIntoConstraints = false
        viewPoliciesButton.translatesAutoresizingMaskIntoConstraints = false
        policiesTableView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false // For back button

        NSLayoutConstraint.activate([
            policyTypeTextField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            policyTypeTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            policyTypeTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            premiumAmountTextField.topAnchor.constraint(equalTo: policyTypeTextField.bottomAnchor, constant: 10),
            premiumAmountTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            premiumAmountTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            startDateTextField.topAnchor.constraint(equalTo: premiumAmountTextField.bottomAnchor, constant: 10),
            startDateTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            startDateTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            endDateTextField.topAnchor.constraint(equalTo: startDateTextField.bottomAnchor, constant: 10),
            endDateTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            endDateTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            customerIdTextField.topAnchor.constraint(equalTo: endDateTextField.bottomAnchor, constant: 10),
            customerIdTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            customerIdTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
        
                        
            addPolicyButton.topAnchor.constraint(equalTo: customerIdTextField.bottomAnchor, constant: 20),
            addPolicyButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            updatePolicyButton.topAnchor.constraint(equalTo: customerIdTextField.bottomAnchor, constant: 20),
            updatePolicyButton.leadingAnchor.constraint(equalTo: addPolicyButton.trailingAnchor, constant: 10),
            
            deletePolicyButton.topAnchor.constraint(equalTo: customerIdTextField.bottomAnchor, constant: 20),
            deletePolicyButton.leadingAnchor.constraint(equalTo: updatePolicyButton.trailingAnchor, constant: 10),
            
            viewPoliciesButton.topAnchor.constraint(equalTo: addPolicyButton.bottomAnchor, constant: 20),
            viewPoliciesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            policiesTableView.topAnchor.constraint(equalTo: viewPoliciesButton.bottomAnchor, constant: 20),
            policiesTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            policiesTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            policiesTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),

            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -20),

        ])
        policiesTableView.isHidden = true
        closeButton.isHidden = true
    }
    //MARK: ADD POLICY
    @objc private func addPolicy() {
        guard let policyType = policyTypeTextField.text, !policyType.isEmpty,
              let premiumString = premiumAmountTextField.text, let premium = Double(premiumString),
              let startDateString = startDateTextField.text, let startDate = Date.from(startDateString),
              let endDateString = endDateTextField.text, let endDate = Date.from(endDateString) else {
            showAlert(message: "Please fill in all fields correctly.")
            return
        }

        // Handle Customer ID
        guard let customerIdString = customerIdTextField.text else {
            showAlert(message: "Please select a Customer ID.")
            return
        }
        let customerId: Int
        if customerIdString == "None" {
            customerId = 0
        } else {
            guard let id = Int(customerIdString) else {
                showAlert(message: "Invalid Customer ID.")
                return
            }
            customerId = id
        }

        // Create new policy
        let newPolicy = InsurancePolicy(id: policyIdCounter, customerId: customerId, policyType: policyType, premiumAmount: premium, startDate: startDate, endDate: endDate)
        policies.append(newPolicy)
        print("Current policies: \(policies.map { $0.description })")
        policyIdCounter += 1
        policiesTableView.reloadData()
        clearFields()
    }
//MARK: Update Policy
    @objc private func updatePolicy() {
        guard let index = selectedPolicyIndex else {
            showAlert(message: "No policy selected for update.")
            return
        }

        let existingPolicy = policies[index]

        var policyType = existingPolicy.policyType
        var premium: Double? = existingPolicy.premiumAmount
        var endDate = existingPolicy.endDate
        var customerId = existingPolicy.customerId

        guard let customerIdString = customerIdTextField.text else {
            showAlert(message: "Please select a Customer ID.")
            return
        }

        if customerIdString == "None" {
            customerId = 0
        } else {
            guard let newCustomerId = Int(customerIdString) else {
                showAlert(message: "Invalid Customer ID.")
                return
            }
            customerId = newCustomerId
        }

        if let newPolicyType = policyTypeTextField.text, !newPolicyType.isEmpty {
            policyType = newPolicyType
        }
        if let premiumString = premiumAmountTextField.text, !premiumString.isEmpty {
            guard let parsedPremium = Double(premiumString) else {
                showAlert(message: "Please enter a valid premium amount.")
                return
            }
            premium = parsedPremium
        }
        if let newEndDateString = endDateTextField.text, !newEndDateString.isEmpty {
            guard let parsedEndDate = Date.from(newEndDateString) else {
                showAlert(message: "Please enter a valid end date (yyyy-MM-dd).")
                return
            }
            endDate = parsedEndDate
        }
        // Update the selected policy
        policies[index] = InsurancePolicy(
            id: existingPolicy.id,
            customerId: customerId,
            policyType: policyType,
            premiumAmount: premium ?? existingPolicy.premiumAmount,
            startDate: existingPolicy.startDate,
            endDate: endDate
        )
        policiesTableView.reloadData()
        clearFields()
        selectedPolicyIndex = nil
    }
//MARK: Delete Policy
    @objc private func deletePolicy() {
        guard let index = selectedPolicyIndex else {
            showAlert(message: "No policy selected for deletion.")
            return
        }
        let selectedCustomerId = customerIdTextField.text == "None" ? 0 : Int(customerIdTextField.text ?? "") ?? -1
        let policy = policies[index]
        if selectedCustomerId != 0 && policy.endDate > Date() {
            showAlert(message: "Cannot delete policy with a valid customer ID or if the end date has not passed.")
            return
        }
        policies.remove(at: index)
        policiesTableView.reloadData()
        clearFields()
        selectedPolicyIndex = nil
    }
    @objc private func viewPolicies() {
        policiesTableView.isHidden = false
        closeButton.isHidden = false
        policiesTableView.reloadData()
    }
    
    @objc private func closePolicyList() {
        policiesTableView.isHidden = true
        closeButton.isHidden = true
    }
    //MARK: Back to Main
    @objc private func backToMainView() {
        let mainView = MainView(frame: UIScreen.main.bounds) // Full screen
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.loadPolicies(policies)
        mainView.loadCustomers(customers)
          if let currentView = self.superview {
              currentView.addSubview(mainView)
          }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // Single column
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customerIds.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customerIds[row] == 0 ? "None" : String(customerIds[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        customerIdTextField.text = customerIds[row] == 0 ? "None" : String(customerIds[row])
    }
    func loadPolicies(_ newPolicies: [InsurancePolicy]) {
            self.policies = newPolicies
       
        }
    func loadCustomers(_ customerIds: [Int]) {
        self.customerIds = [0] + customers.map { $0.id }
        updateCustomerIdTextField()

    }
    func loadCustomer(_ customers: [Customer]) {
          self.customers = customers
      }

    private func updateCustomerIdTextField() {
        customerIdTextField.reloadInputViews()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PolicyCell", for: indexPath)
        let policy = policies[indexPath.row]
        cell.textLabel?.text = "\(policy.policyType) - \(policy.premiumAmount) \(policy.endDate)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPolicyIndex = indexPath.row
        let policy = policies[indexPath.row]
        policyTypeTextField.text = policy.policyType
        premiumAmountTextField.text = String(policy.premiumAmount)
        startDateTextField.text = policy.startDate.toString()
        endDateTextField.text = policy.endDate.toString()
        customerIdTextField.text = String(policy.customerId)
    }


    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let vc = parentViewController {
            vc.present(alert, animated: true)
        }
    }

    private func clearFields() {
        policyTypeTextField.text = ""
        premiumAmountTextField.text = ""
        startDateTextField.text = ""
        endDateTextField.text = ""
        customerIdTextField.text = ""
        
    }

    private var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            responder = nextResponder
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

// Date extension for formatting
extension Date {
    static func from(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}

