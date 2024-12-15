import SwiftUI

struct EditCustomerView: View {
    @State private var newName: String
    @State private var newAge: String
    @State private var newEmail: String
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingImagePicker = false
    @State private var selectedImageData: Data? = nil
    @Environment(\.dismiss) var dismiss
    private let dataManager = DataManager()
    var customer: Customer
    
    init(customer: Customer) {
        self.customer = customer
        _newName = State(initialValue: customer.name)
        _newAge = State(initialValue: "\(customer.age)")
        _newEmail = State(initialValue: customer.email)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Profile Picture")) {
                if let profilePictureUrl = customer.profilePictureUrl, !profilePictureUrl.isEmpty {
                    if isBase64String(profilePictureUrl) {
                        if let decodedImage = imageFromBase64(base64String: profilePictureUrl) {
                            Image(uiImage: decodedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                                .shadow(radius: 10)
                        }
                    } else {
                        AsyncImage(url: URL(string: profilePictureUrl)) { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                                .shadow(radius: 10)
                        } placeholder: {
                            ProgressView() // Show a loading spinner while the image is loading
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                } else {
                    Text("No Profile Picture")
                        .foregroundColor(.gray)
                }

                Button("Update Profile Picture") {
                    showingImagePicker.toggle()
                }
            }
            Section(header: Text("Customer Name")) {
                TextField("Name", text: $newName)
            }

            Section(header: Text("Age")) {
                TextField("Age", text: $newAge)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Email")) {
                TextField("Email", text: $newEmail)
                    .disabled(true)
                    .foregroundColor(.gray)
            }

            Button("Save Changes") {
                saveChanges()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
        }
        .navigationTitle("Edit Customer")
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Customer Updated"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "The customer has been successfully updated." {
                                    dismiss() // Dismiss the current view if it's a successful update
                                }
                }
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(isImagePickerPresented: $showingImagePicker, selectedImageData: $selectedImageData)
        }
    }

        func isBase64String(_ string: String) -> Bool {
             let base64Pattern = "^[A-Za-z0-9+/=]+$"
             let regex = try? NSRegularExpression(pattern: base64Pattern)
             let matches = regex?.matches(in: string, range: NSRange(location: 0, length: string.count))
             return matches?.count ?? 0 > 0
         }
        
        func imageFromBase64(base64String: String) -> UIImage? {
            if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
                return UIImage(data: data)
            }
            return nil
        }
        
        func saveChanges() {
            guard let age = Int(newAge), !newName.isEmpty else {
                alertMessage = "Please enter a valid age (must be a number)."
                showingAlert = true
                return
            }
            
            // Validate if name is not an integer (we want name to be a string, not a number)
            if let _ = Int(newName) {
                alertMessage = "Name is invalid. Please enter a valid name."
                showingAlert = true
                return
            }

            var updatedCustomer = customer
            updatedCustomer.name = newName
            updatedCustomer.age = age
            updatedCustomer.email = newEmail

            if let selectedImageData = selectedImageData {
                updatedCustomer.profilePictureUrl = encodeToBase64(imageData: selectedImageData)
            }
            dataManager.updateCustomer(customer: updatedCustomer)
            alertMessage = "The customer has been successfully updated."
            showingAlert = true
        }
    
        func encodeToBase64(imageData: Data) -> String {
            return imageData.base64EncodedString()
        }
    }

