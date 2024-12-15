import SwiftUI

struct CustomerDetailView: View {
    @State private var isEditing = false
    @State private var name: String
    @State private var age: Int
    @State private var profilePictureUrl: String
    @State private var newProfilePicture: UIImage?
    @State private var showingEditCustomerView = false
    @Binding var customer: Customer // Use Binding to modify the customer directly
    
    init(customer: Binding<Customer>) {
        _customer = customer
        _name = State(initialValue: customer.wrappedValue.name)
        _age = State(initialValue: customer.wrappedValue.age)
        _profilePictureUrl = State(initialValue: customer.wrappedValue.profilePictureUrl ?? "")
    }
    
    func isBase64Encoded(_ string: String) -> Bool {
        let regex = "[A-Za-z0-9+/=]+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: string)
    }
    
    func imageFromBase64(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    var body: some View {
        VStack {
            // Display Profile Picture
            if let profilePictureUrl = customer.profilePictureUrl {
                if isBase64Encoded(profilePictureUrl) {
                    // If the profilePictureUrl is base64 encoded, decode it
                    if let image = imageFromBase64(base64String: profilePictureUrl) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())  // Clipping to make it circular
                            .overlay(Circle().stroke(Color.gray, lineWidth: 4))  // Optional: Border around the circle
                            .shadow(radius: 10)  // Optional: Shadow for better visual effect
                    }
                } else if let url = URL(string: profilePictureUrl) {
                    // If it's a URL, load the image as before
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())  // Clipping to make it circular
                            .overlay(Circle().stroke(Color.gray, lineWidth: 4))  // Optional: Border around the circle
                            .shadow(radius: 10)  // Optional: Shadow for better visual effect
                    } placeholder: {
                        Circle().fill(Color.gray).frame(width: 200, height: 200) // Placeholder when loading image
                    }
                } else {
                    // Fallback if the URL is invalid or if both are invalid
                    Circle().fill(Color.gray).frame(width: 200, height: 200)
                }
            } else {
                // If profilePictureUrl is nil, show default placeholder
                Circle().fill(Color.gray).frame(width: 200, height: 200)
            }
            
            // Display Name and Age
            Text(customer.name).font(.title).bold() // Make name bold
            Text("\(customer.age) years old").font(.subheadline).foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
        .navigationTitle(customer.name)
        .navigationBarItems(trailing: Button(action: {
            if isEditing {
                isEditing = false // Reset editing state when Done is pressed
            } else {
                isEditing = true
                showingEditCustomerView = true
            }
        }) {
            Text(isEditing ? "" : "Edit")
                .bold()
        })
        .sheet(isPresented: $showingEditCustomerView) {
            EditCustomerView(customer: customer) // Pass the binding to the EditCustomerView
        }
    }
}
