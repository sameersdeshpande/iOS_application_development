//
//  EditPolicyView.swift
//  Assignment_11
//
//  Created by Sameer Shashikant Deshpande on 11/25/24.
//
import Foundation
import SwiftUI
struct EditPolicyView: View {
    @State var policy: Policy 
    private let dataManager = DataManager()
    @State private var policyType: String
    @State private var premiumAmount: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    
    init(policy: Policy) {
        _policy = State(initialValue: policy)
        _policyType = State(initialValue: policy.policyType ?? "")
        _premiumAmount = State(initialValue: String(format: "%.2f", policy.premiumAmount ?? 0.0))
        _startDate = State(initialValue: policy.startDate ?? Date())
        _endDate = State(initialValue: policy.endDate ?? Date())
    }
    
    var body: some View {
        Form {
            Section(header: Text("Policy Type")) {
                TextField("Policy Type", text: $policyType)
            }
            
            Section(header: Text("Premium Amount")) {
                TextField("Premium Amount", text: $premiumAmount)
                    .keyboardType(.decimalPad)
            }
            
            Section(header: Text("Start Date")) {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }
            
            Section(header: Text("End Date")) {
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
            }
            
            Button("Save Changes") {
                // Save the updated policy
                if let premium = Double(premiumAmount) {
                    policy.policyType = policyType
                    policy.premiumAmount = premium
                    policy.startDate = startDate
                    policy.endDate = endDate
                    
                    dataManager.updatePolicy(policy: policy)
                    alertMessage = "The policy has been successfully updated."
                    showingAlert = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(policyType.isEmpty || premiumAmount.isEmpty)
        }
        .navigationTitle("Edit Policy")
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Policy Updated"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "The policy has been successfully updated." {
                                    dismiss() // Dismiss the current view if it's a successful update
                                }
                }
            )
        }
    }
}

