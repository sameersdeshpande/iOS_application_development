import SwiftUI

struct AddPolicyView: View {
    @Binding var policies: [Policy]
    @State private var selectedCustomer: Customer? = nil
    @State private var policyType: String = ""
    @State private var premiumAmount: String = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var availableCustomers: [Customer] = []
    @State private var showingAlert = false // State variable for alert visibility
    @State private var alertMessage = "" // State variable for alert message
    @State private var alertTitle = "" // State variable for alert title
    
    private let dataManager = DataManager()
    
    @Environment(\.dismiss) var dismiss
    
    init(policies: Binding<[Policy]>) {
        self._policies = policies
    }
    
    var body: some View {
        Form {
            Section(header: Text("Customer")) {
                Picker("Select Customer", selection: $selectedCustomer) {
                    Text("Select Customer").tag(nil as Customer?)
                    ForEach(availableCustomers, id: \.customerId) { customer in
                        Text(customer.name).tag(customer as Customer?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section(header: Text("Policy Type")) {
                TextField("Enter Policy Type", text: $policyType)
                    .textFieldStyle(PlainTextFieldStyle())
            }

            Section(header: Text("Premium Amount")) {
                TextField("Enter Premium Amount", text: $premiumAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
            }

            Section(header: Text("Start Date")) {
                DatePicker("Select Start Date", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .onChange(of: startDate) { newValue in
                        // Ensure the endDate is not earlier than the startDate
                        if endDate < newValue {
                            endDate = newValue
                        }
                    }
            }

            Section(header: Text("End Date")) {
                DatePicker("Select End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .disabled(endDate < startDate)
            }

            Button("Add Policy") {
                addPolicy()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(selectedCustomer == nil || policyType.isEmpty || premiumAmount.isEmpty)
        }
        .navigationTitle("Add Policy")
        .navigationBarItems(trailing: Button("Cancel") {
            dismiss()
        })
        .onAppear {
            availableCustomers = dataManager.fetchCustomers()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func addPolicy() {
        // Validate the input fields before proceeding
        guard let customer = selectedCustomer else {
            showAlert(title: "Error", message: "Please select a customer.")
            return
        }
        
        guard !policyType.isEmpty else {
            showAlert(title: "Error", message: "Please enter a policy type.")
            return
        }
        
        // Ensure policyType contains only alphabetic characters (letters)
        guard policyType.range(of: "^[a-zA-Z]+$", options: .regularExpression) != nil else {
            showAlert(title: "Error", message: "Policy type can only contain alphabetic characters.")
            return
        }
        
        // Validate premium amount - ensure it's a valid decimal number
        guard let premium = Double(premiumAmount), premium > 0 else {
            showAlert(title: "Error", message: "Please enter a valid premium amount.")
            return
        }
        
        // Fetch the next policy ID by getting the highest policyId from the database
        let nextPolicyId = dataManager.getNextPolicyId()

        let newPolicy = Policy(
            id: nextPolicyId,
            customerId: customer.customerId,
            policyType: policyType,
            premiumAmount: premium,
            startDate: startDate,
            endDate: endDate
        )
        
        // Add the new policy to the database
        dataManager.addPolicy(policy: newPolicy)
        
        // Optionally, append the new policy to the local policies array to reflect the update in the UI
        policies.append(newPolicy)
        
        // Set the success alert message and show the alert
        alertTitle = "Success"
        alertMessage = "The policy for \(customer.name) has been successfully added."
        showingAlert = true
        
        // Clear the input fields after the policy has been added successfully
        clearFields()
    }

    private func clearFields() {
        // Clear all fields after the alert is dismissed
        selectedCustomer = nil
        policyType = ""
        premiumAmount = ""
        startDate = Date()
        endDate = Date()
    }
    
    private func showAlert(title: String, message: String) {
        // Show an alert with a custom title and message
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}
