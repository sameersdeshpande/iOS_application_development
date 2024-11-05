import UIKit

class MainView: UIView, UITableViewDataSource, UITableViewDelegate {
    private var insuranceView: InsuranceView?
    private var customers: [Customer] = []
    private var customerIdCounter = 1
    private var selectedCustomerIndex: Int?
    var policies: [InsurancePolicy] = []
  
    private let nameTextField = UITextField()
    private let ageTextField = UITextField()
    private let emailTextField = UITextField()
    private var customerIdArray: [Int] = []
    private let customersTableView = UITableView()
    private let closeButton = UIButton(type: .system)
    
    private let buttonStackView = UIStackView()
    private let buyInsuranceButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        
        setupTextField(nameTextField, placeholder: "Enter Name")
        setupTextField(ageTextField, placeholder: "Enter Age", keyboardType: .numberPad)
        setupTextField(emailTextField, placeholder: "Enter Email")
        setupButtonStackView()
        buyInsuranceButton.setTitle("Buy Insurance", for: .normal)
        buyInsuranceButton.addTarget(self, action: #selector(buyInsurance), for: .touchUpInside)
        buyInsuranceButton.translatesAutoresizingMaskIntoConstraints = false
        setupTableView()
        setupCloseButton()
        
        // Add UI to the view
        addSubviews()
        
        // Set up constraints
        setupConstraints()
        
        customersTableView.isHidden = true
        insuranceView = InsuranceView()
    
             
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupButtonStackView() {
        buttonStackView.axis = .vertical
        buttonStackView.alignment = .fill
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let topRowStackView = createButtonRow(buttonTitles: ["Add Customer", "Update Customer"], actions: [#selector(addCustomer), #selector(updateCustomer)])
        let bottomRowStackView = createButtonRow(buttonTitles: ["Delete Customer", "View Customers"], actions: [#selector(deleteCustomer), #selector(viewCustomers)])
        
        buttonStackView.addArrangedSubview(topRowStackView)
        buttonStackView.addArrangedSubview(bottomRowStackView)
    }
    
    private func createButtonRow(buttonTitles: [String], actions: [Selector]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        for (title, action) in zip(buttonTitles, actions) {
            let button = createButton(title: title, action: action)
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }
    
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func setupTableView() {
        customersTableView.dataSource = self
        customersTableView.delegate = self
        customersTableView.translatesAutoresizingMaskIntoConstraints = false
        customersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CustomerCell")
    }
    
    private func setupCloseButton() {
        closeButton.setTitle("x", for: .normal)
        closeButton.addTarget(self, action: #selector(closeCustomers), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.isHidden = true
    }
    
    private func addSubviews() {
        addSubview(nameTextField)
        addSubview(ageTextField)
        addSubview(emailTextField)
        addSubview(buttonStackView)
        addSubview(buyInsuranceButton)
        addSubview(customersTableView)
        addSubview(closeButton)
       
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buyInsuranceButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            buyInsuranceButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            nameTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameTextField.topAnchor.constraint(equalTo: buyInsuranceButton.bottomAnchor, constant: 20),
            nameTextField.widthAnchor.constraint(equalToConstant: 300),
            
            ageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            ageTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            ageTextField.widthAnchor.constraint(equalToConstant: 300),
            
            emailTextField.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 10),
            emailTextField.centerXAnchor.constraint(equalTo: centerXAnchor),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            
            buttonStackView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonStackView.widthAnchor.constraint(equalToConstant: 300),
            
            customersTableView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20),
            customersTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            customersTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            customersTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: customersTableView.topAnchor, constant: -10),
            closeButton.trailingAnchor.constraint(equalTo: customersTableView.trailingAnchor, constant: -10)
        ])
    }
 //MARK: ADDING CUSTOMER
    @objc private func addCustomer() {
        guard let name = nameTextField.text, !name.isEmpty,
              let ageString = ageTextField.text, let age = Int(ageString), age > 0,
              let email = emailTextField.text, !email.isEmpty else {
              showAlert(message: "Please fill in all fields correctly.")
            return
        }
        let newCustomer = Customer(id: customerIdCounter, name: name, age: age, email: email)
        customers.append(newCustomer)
        customerIdArray.append(customerIdCounter)
        customerIdCounter += 1
        showAlert(message: "Customer added successfully!")
        clearFields()
        customersTableView.reloadData()
    }

    //MARK: UPDATING CUSTOMER
    @objc private func updateCustomer() {
        let name = nameTextField.text ?? ""
        let ageString = ageTextField.text ?? ""
        
        guard !name.isEmpty || !ageString.isEmpty else {
            showAlert(message: "Please fill in either the name or age field.")
            return
        }
        var age: Int?
        if !ageString.isEmpty {
            guard let parsedAge = Int(ageString), parsedAge > 0 else {
                showAlert(message: "Please enter a valid age.")
                return
            }
            age = parsedAge
        }

        if let index = selectedCustomerIndex {
            // Update only the provided fields
            if !name.isEmpty {
                customers[index].name = name
            }
            if let validAge = age {
                customers[index].age = validAge
            }
            showAlert(message: "Customer updated successfully!")
            clearFields()
            customersTableView.reloadData()
            selectedCustomerIndex = nil
        } else {
            showAlert(message: "Please select a customer to update.")
        }
    }

//MARK: Deleting customer
    @objc private func deleteCustomer() {
        guard let index = selectedCustomerIndex else {
            showAlert(message: "Please select a customer to delete.")
            return
        }
        let customerIdToDelete = customers[index].id
        print("Attempting to delete customer with ID: \(customerIdToDelete)")
        let hasAssociatedPolicies = policies.contains { $0.customerId == customerIdToDelete }
        if hasAssociatedPolicies {
            showAlert(message: "Cannot delete customer with associated insurance policies.")
            return
        }
        customers.remove(at: index)
        showAlert(message: "Customer deleted successfully!")
        clearFields()
        customersTableView.reloadData()
        selectedCustomerIndex = nil
    }


//MARK: View Customer
    @objc private func viewCustomers() {
        customersTableView.isHidden = false
        closeButton.isHidden = false
        customersTableView.reloadData()
    }
    
    @objc private func closeCustomers() {
        customersTableView.isHidden = true
        closeButton.isHidden = true
    }
    //MARK: Insurance Panel
    @objc private func buyInsurance() {
        let insuranceView = InsuranceView(frame: UIScreen.main.bounds) // Cover the entire screen
        insuranceView.loadCustomer(customers)
        insuranceView.loadCustomers(customerIdArray)
        insuranceView.loadPolicies(policies)
        insuranceView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(insuranceView)

        NSLayoutConstraint.activate([
            insuranceView.topAnchor.constraint(equalTo: topAnchor),
            insuranceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            insuranceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            insuranceView.trailingAnchor.constraint(equalTo: trailingAnchor)
            
        ])
   
    }
    func loadCustomers(_ newCustomers: [Customer]) {
          self.customers = newCustomers
           // Print the loaded customers or update your UI
          customersTableView.reloadData() // Reload the table view if necessary
      }
    func loadPolicies(_ newPolicies: [InsurancePolicy]) {
            self.policies = newPolicies
        printPolicies()
        }
    private func printPolicies() {
           print("LCurrent Policies: \(policies.map { $0.description })")
       }
    
    // UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        let customer = customers[indexPath.row]
        cell.textLabel?.text = "\(customer.id): \(customer.name), Age: \(customer.age), Email: \(customer.email)"
        return cell
    }
    
    // UITableViewDelegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCustomerIndex = indexPath.row
        let selectedCustomer = customers[indexPath.row]
        nameTextField.text = selectedCustomer.name
        ageTextField.text = String(selectedCustomer.age)
        emailTextField.text = selectedCustomer.email
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present alert from a parent view controller if available
        if let parentVC = self.parentViewController() {
            parentVC.present(alert, animated: true)
        }
    }
  
    private func clearFields() {
        nameTextField.text = ""
        ageTextField.text = ""
        emailTextField.text = ""
    }
    
    // Helper method to find the parent view controller
    private func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

