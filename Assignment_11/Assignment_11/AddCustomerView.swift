import SwiftUI

struct AddCustomerView: View {
    @Binding var customers: [Customer]
    @Binding var nextId: Int
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var email: String = ""
    @State private var profilePictureUrl: String = "" // This will store the base64 string
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImageData: Data? = nil
    
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Customer Details")) {
                    HStack {
                        // If an image is selected, display it on the left side of the HStack
                        if let selectedImageData, let image = UIImage(data: selectedImageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50) // Set the size of the image
                                .clipShape(Circle()) // Make it circular
                                .overlay(Circle().stroke(Color.white, lineWidth: 1)) // Optional border around the image
                                .shadow(radius: 5) // Optional shadow for better visual effect
                        }
                        Spacer()
                        Button("Select Profile Picture") {
                            isImagePickerPresented.toggle()
                        }
                        .padding(.leading)
                        .font(.system(size: 14))
                    }
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Button("Save") {
                    // Validate the input fields
                    if let validAge = Int(age), !name.isEmpty, !email.isEmpty {
                        // Check if name contains only alphabetic characters
                        if name.range(of: "^[A-Za-z ]+$", options: .regularExpression) == nil {
                            // Invalid name (non-alphabetical characters)
                            showAlertWith(title: "Invalid Name", message: "Please enter a valid name with alphabetic characters only.")
                            return
                        }

                        // Check if the age is within the valid range
                        if validAge < 1 || validAge > 100 {
                            // Invalid age
                            showAlertWith(title: "Invalid Age", message: "Age should be between 1 and 100.")
                            return
                        }

                        // Check if the email is valid
                        if !isValidEmail(email) {
                            // Invalid email
                            showAlertWith(title: "Invalid Email", message: "Please enter a valid email address.")
                            return
                        }

                        // Check if the email already exists in the database using the doesEmailExist method
                        let dataManager = DataManager()
                        if dataManager.doesEmailExist(email: email) {
                            // Email already exists in the database
                            showAlertWith(title: "Email Already Registered", message: "This email address is already registered. Please use a different email.")
                            return
                        }

                        // Proceed to save the customer if validation passes
                        let base64ImageString = selectedImageData?.base64EncodedString() ?? ""
                        let nextId = dataManager.getNextCustomerId()
                        let newCustomer = Customer(customerId: nextId, name: name, age: validAge, email: email, profilePictureUrl: base64ImageString)
                        customers.append(newCustomer)
                        
                        // Save the new customer in the database
                        dataManager.addCustomer(customer: newCustomer)
                        
                        // Dismiss the view after successful save
                        dismiss()
                    } else {
                        // If fields are empty or age is invalid
                        showAlertWith(title: "Invalid Information", message: "Please provide valid information.")
                    }
                }


                .frame(maxWidth: .infinity, alignment: .center) // Center-align the button
                .padding() // Add padding around the button to make it look better
                .background(Color.blue) // Set the background to blue
                .foregroundColor(.white) // Set the text color to white
                .cornerRadius(8) // Make the button rounded
                .buttonStyle(PlainButtonStyle())
//                .disabled(name.isEmpty || age.isEmpty || email.isEmpty) // Disable if fields are empty
            }
            .navigationTitle("Add Customer")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss() // Dismiss the AddCustomerView without saving
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(isImagePickerPresented: $isImagePickerPresented, selectedImageData: $selectedImageData)
        }
    }
    
    // Helper function to show alerts
    func showAlertWith(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    // Helper function to validate email
    func isValidEmail(_ email: String) -> Bool {
        // Check for email format (must contain '@' and '.com')
        return email.contains("@") && email.lowercased().hasSuffix(".com")
    }
}
