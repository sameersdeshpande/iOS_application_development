import SwiftUI

struct CustomersView: View {
    
    
    @State private var customers: [Customer] = []
    @State private var searchText = ""
    @State private var showingAddCustomerView = false
    @State private var nextId: Int = 1
    @State private var isFetchingAPI = false
    @State private var refreshFlag: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var filteredCustomers: [Customer] {
        return customers.filter {
            searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .onSubmit {
                        
                        if searchText.isEmpty || filteredCustomers.isEmpty {
                            alertMessage = "No customers found matching your search."
                            showingAlert = true
                        }
                    }
                
                // Customer List
                List {
                    ForEach(filteredCustomers) { customer in
                        NavigationLink(destination: CustomerDetailView(customer: $customers[customers.firstIndex(where: { $0.id == customer.id })!])) {
                            HStack {
                                
                                
                                
                                if let profilePictureUrl = customer.profilePictureUrl {
                                    if let decodedImage = decodeBase64ToImage(profilePictureUrl) {
                                        Image(uiImage: decodedImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                            .shadow(radius: 5)
                                    } else if let url = URL(string: profilePictureUrl) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                .shadow(radius: 5)
                                        } placeholder: {
                                            Circle().fill(Color.white).frame(width: 50, height: 50)
                                        }
                                    } else {
                                        Circle().fill(Color.blue).frame(width: 50, height: 50)
                                    }
                                } else {
                                    Circle().fill(Color.white).frame(width: 50, height: 50)
                                }
                                
                                
                                
                                Text(customer.name)
                                Spacer()
                                Text("\(customer.age) years old")
                            }
                        }
                    }
                    .onDelete(perform: deleteCustomer)
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await refreshData()  // Refresh data from API and DB
                }
                .onAppear {
                    resetData()
                    fetchCustomersFromDB()  // Load customers when the view appears
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Search Result"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                .onChange(of: refreshFlag) { _ in
                    fetchCustomersFromDB()  // Trigger fetch on state change (when data is updated)
                }
            }
            .navigationTitle("Customers")
            .navigationBarItems(trailing: Button(action: {
                showingAddCustomerView = true
            }) {
                Image(systemName: "plus")
                    .imageScale(.large)
            })
            .sheet(isPresented: $showingAddCustomerView) {
                AddCustomerView(customers: $customers, nextId: $nextId) // Add new customer
            }
        }
    }
    private func resetData() {
        // Clear the customers array and reset any other states you need
        self.customers = []
        self.searchText = ""
    }
    private func refreshData() async {
        await fetchCustomers()  // Fetch from API
        fetchCustomersFromDB()  // Fetch from DB after API call
    }
    
    private func fetchCustomers() async {
        let startTime = Date()
        MockAPI.fetchCustomers { result in
            switch result {
            case .success(let apiCustomers):
                print("Fetched Customers: \(apiCustomers)") // Log the fetched customers for debugging
            case .failure(let error):
                print("Failed to fetch customers from API: \(error)")
            }
        }
    }
    
    private func fetchCustomersFromDB() {
        let dataManager = DataManager()
        let dbCustomers = dataManager.fetchCustomers()
        
        self.customers = dbCustomers // This triggers a UI update
        // Update the nextId based on the max id in the database
        let highestId = dbCustomers.map { $0.id }.max() ?? 0
        self.nextId = highestId + 1
        refreshFlag.toggle()
    }
    
    private func deleteCustomer(at offsets: IndexSet) {
        offsets.forEach { index in
            let customer = filteredCustomers[index]
            let dataManager = DataManager()
            dataManager.deleteCustomer(customer)
            if let index = customers.firstIndex(where: { $0.id == customer.id }) {
                customers.remove(at: index)  // Remove from the customers list
            }
        }
    }
    
    func decodeBase64ToImage(_ base64String: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }
}
