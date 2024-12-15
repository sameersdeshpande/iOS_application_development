//
//  PoliciesView.swift
//  Assignment_10
//
//  Created by Sameer Shashikant Deshpande on 11/15/24.
//
import SwiftUI

struct PoliciesView: View {
    @State private var policies: [Policy] = []
    @State private var searchText = ""
    private let dataManager = DataManager()
    @State private var showingAlert = false
     @State private var alertMessage = ""
    // Filter policies based on the search text
    var filteredPolicies: [Policy] {
        policies.filter {
            searchText.isEmpty || ($0.policyType?.lowercased().contains(searchText.lowercased()) ?? false)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .onSubmit {
                                         
                                           if searchText.isEmpty || filteredPolicies.isEmpty {
                                               alertMessage = "No Policies found matching your search."
                                               showingAlert = true
                                           }
                                       }
                
                // Policy List
                List {
                    ForEach(filteredPolicies) { policy in
                        NavigationLink(destination: PolicyDetailView(policy: policy)) {
                            HStack {
                                // Policy Type (use policyType instead of type)
                                Text(policy.policyType ?? "Unknown")
                                    .font(.headline)
                                Spacer()
                                // Premium Amount
                                Text("$\(String(format: "%.2f", policy.premiumAmount ?? 0))")
                                // Policy Icon
                                policyIcon(for: policy.policyType)
                            }
                        }
                    }
                    .onDelete(perform: deletePolicy) // Apply onDelete to ForEach
                }
                .refreshable {
                    
                    await refreshData()
                }
                .onAppear {
                    
                    fetchPoliciesFromDB()
                    
                }
                // Show alert if no customers are found
                          .alert(isPresented: $showingAlert) {
                              Alert(
                                  title: Text("Search Result"),
                                  message: Text(alertMessage),
                                  dismissButton: .default(Text("OK"))
                              )
                          }
                      }
            
            .navigationTitle("Policies")
            .navigationBarItems(trailing: NavigationLink(destination: AddPolicyView(policies: $policies)) {
                Image(systemName: "plus")
                    .font(.system(size: 18))
                
            })
        }
    }
    private func refreshData() async {
        await fetchPolicies()  // Fetch from API
        fetchPoliciesFromDB()  // Fetch from DB
    }
    
    private func fetchPolicies() async {
        let startTime = Date()
        MockAPI.fetchPolicies { result in
            switch result {
            case .success(let policies):
                // Assign the fetched policies
                print("Fetched Policies: \(policies)") // Debugging line
            case .failure(let error):
                print("Failed to fetch policies: \(error)")
            }
        }
    }
    
    private  func fetchPoliciesFromDB() {
        let dbPolicies = dataManager.fetchPolicies()
        self.policies = dbPolicies
        let highestId = dbPolicies.map { $0.id }.max() ?? 0
        
    }
    
    private func policyIcon(for type: String?) -> some View {
        let icon: String
        if let policyType = type?.lowercased() {
            switch policyType {
            case "home":
                icon = "house.fill"
            case "auto":
                icon = "car.fill"
            case "health":
                icon = "heart.fill"
            default:
                icon = "questionmark.circle.fill"
            }
        } else {
            // Default case when `type` is nil
            icon = "questionmark.circle.fill"
        }
        return Image(systemName: icon).foregroundColor(.gray)
    }
    
    private func deletePolicy(at offsets: IndexSet) {
        let policiesToDelete = offsets.map { policies[$0] }
        for policy in policiesToDelete {
            if let endDate = policy.endDate, endDate > Date() {
               
                alertMessage = "Cannot delete policy with a future end date."
                showingAlert = true
                return
            } else {
                
                dataManager.deletePolicy(policy: policy)
            }
        }
        policies.remove(atOffsets: offsets)
    }

}
