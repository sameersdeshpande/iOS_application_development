//
//  PolicyDetailView.swift
//  Assignment_10
//
//  Created by Sameer Shashikant Deshpande on 11/15/24.
//

import SwiftUI
struct PolicyDetailView: View {
    let policy: Policy
    
    var body: some View {
        VStack {
            // Display Policy Type and Premium
            Text("Policy Type: \(policy.policyType ?? "Unknown")").font(.title)
            Text("Associated Customer ID: \(policy.customerId)")
            // Use optional binding to unwrap premiumAmount
            if let premiumAmount = policy.premiumAmount {
                Text("Premium: $\(String(format: "%.2f", premiumAmount))").font(.subheadline)
            } else {
                Text("Premium: Not available").font(.subheadline)
            }
            
            // Display Start Date and End Date
            if let startDate = policy.startDate, let endDate = policy.endDate {
                Text("Start Date: \(startDate, style: .date)").font(.subheadline)
                Text("End Date: \(endDate, style: .date)").font(.subheadline)
            } else {
                Text("Dates: Not available").font(.subheadline)
            }
            
          
           
            Spacer()
        }
        .padding()
        .navigationTitle(policy.policyType ?? "Unknown")
        .navigationBarItems(trailing: NavigationLink(destination: EditPolicyView(policy: policy)) {
                 Text("Edit")
                     .foregroundColor(.blue)
             })
    }
}
