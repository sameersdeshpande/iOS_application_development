//
//  CustomerViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 10/22/24.
//

import Foundation
import UIKit

class CustomerViewController: UIViewController, UIImagePickerControllerDelegate,UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate,UINavigationControllerDelegate{
    // Method to update customer data
    func updateCustomerData(customer: Customer) {
        // Update the local customer data with the updated customer
        if let index = customers.firstIndex(where: { $0.id == customer.id }) {
            customers[index] = customer
            filteredCustomers[index] = customer

            // Reload the image if needed
            if let profilePictureUrl = customer.profilePictureUrl,
               let imageData = Data(base64Encoded: profilePictureUrl) {
                customerImage.image = UIImage(data: imageData)
            }

            // Optionally, reload the table view if you are displaying the customer in a table
            customerstableView.reloadData()
        }
    }
    @IBOutlet weak var searchCustomer: UISearchBar!
    @IBOutlet weak var customerstableView: UITableView!
    @IBOutlet weak var buttonDeleteCustomer: UIButton!
    @IBOutlet weak var buttonUpdateCustomer: UIButton!
    @IBOutlet weak var buttonViewCustomer: UIButton!
    @IBOutlet weak var buttonAddCustomer: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var selectedCustomerIndex: Int?
    var customers: [Customer] = [] // Assuming Customer is your model
    var filteredCustomers: [Customer] = []
    var isSearching: Bool = false

    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var customerImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        customerstableView.dataSource = self
        customerstableView.delegate = self
        customerstableView.isHidden = true
        customerstableView.reloadData()
        customerstableView.isScrollEnabled = true
        ageTextField.keyboardType = .numberPad
        searchCustomer.delegate = self

        customers = DataManager.shared.getCustomers()
        customerImage.image = UIImage(named: "defaultProfilePic")
        filteredCustomers = customers
        fetchAndUpdateCustomers()
        updateButtonStates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customers = DataManager.shared.getCustomers() // Refresh customer list
        customerstableView.reloadData()      // Reload the table view
    }

    func fetchAndUpdateCustomers() {
        NetworkManager.shared.fetchAndStoreCustomers { [weak self] success, message in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success {
                    self.customers = DataManager.shared.getCustomers()
                    self.filteredCustomers = self.customers
                    self.customerstableView.reloadData()
                } else {
                    self.showMessage(message ?? "Failed to fetch customers from API.")
                }
            }
        }
    }

    @IBAction func imageUploadTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
           imagePickerController.delegate = self
           imagePickerController.sourceType = .photoLibrary
           
           if UIImagePickerController.isSourceTypeAvailable(.camera) {
               let alertController = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .actionSheet)
               
               let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                   imagePickerController.sourceType = .photoLibrary
                   self.present(imagePickerController, animated: true, completion: nil)
               }
               
               let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                   imagePickerController.sourceType = .camera
                   self.present(imagePickerController, animated: true, completion: nil)
               }
               
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
               
               alertController.addAction(photoLibraryAction)
               alertController.addAction(cameraAction)
               alertController.addAction(cancelAction)
               
               present(alertController, animated: true, completion: nil)
               
           } else {
               self.present(imagePickerController, animated: true, completion: nil)
           }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            customerImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func convertImageToBase64String(image: UIImage) -> String? {
           if let imageData = image.jpegData(compressionQuality: 1.0) {  // Use .pngData() if you want PNG format
               return imageData.base64EncodedString()
           }
           return nil
       }
    @IBAction func addCustomerTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let ageString = ageTextField.text, let age = Int(ageString), age > 0,
              let email = emailTextField.text, !email.isEmpty else {
            showMessage("Please fill in all fields correctly.")
            return
        }
        guard let image = customerImage.image,
              let base64Image = convertImageToBase64String(image: image) else {
            showMessage("Please select a profile picture.")
            return
        }

        DataManager.shared.addCustomer(name: name, age: age, email: email, profileImage: base64Image)
        
        customers = DataManager.shared.getCustomers() // Refresh customer list
        resetForm()
        customerstableView.reloadData()
        showMessage("Customer added successfully!")
    }
    func decodeBase64ToImage(base64String: String) -> UIImage? {
        if let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }

    @IBAction func viewCustomersTapped(_ sender: UIButton) {
        if customerstableView.isHidden {
            self.customerstableView.isHidden = false
            self.customerstableView.reloadData()
        } else {
            self.customerstableView.isHidden = true
        }
        self.updateButtonStates()
    }


    @IBAction func updateCustomerTapped(_ sender: UIButton) {
        guard let index = selectedCustomerIndex else {
            showMessage("No customer selected for update.")
            return
        }
        performSegue(withIdentifier: "toUpdateCustomer", sender: self)
    }

    @IBAction func deleteCustomerTapped(_ sender: UIButton) {
        guard let index = selectedCustomerIndex else { return }
        let customer = DataManager.shared.getCustomers()[index]
        let associatedPolicies = DataManager.shared.getPolicies().filter { $0.customerId == customer.id }
        if !associatedPolicies.isEmpty {
            showMessage("This customer has associated policies and cannot be deleted.")
            return
        }
        DataManager.shared.removeCustomer(id: customer.id)
        customers = DataManager.shared.getCustomers()
        resetForm()
        customerstableView.reloadData()
        showMessage("Customer deleted successfully!")
    }


    func resetForm() {
        nameTextField.text = ""
        ageTextField.text = ""
        emailTextField.text = ""
        selectedCustomerIndex = nil
        updateButtonStates()
    }

    func updateButtonStates() {
        let hasSelectedCustomer = selectedCustomerIndex != nil
        buttonUpdateCustomer.isEnabled = hasSelectedCustomer
        buttonDeleteCustomer.isEnabled = hasSelectedCustomer
    }

    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredCustomers = customers
        } else {
            isSearching = true
            filteredCustomers = customers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            
            if filteredCustomers.isEmpty{
                showMessage("No customer found")
            }
        }
        customerstableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredCustomers = customers
        customerstableView.reloadData()
        searchBar.resignFirstResponder()
    }
    // MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredCustomers.count : customers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        let customer = isSearching ? filteredCustomers[indexPath.row] : customers[indexPath.row]
        cell.textLabel?.text = "ID: \(customer.id)  Name: \(customer.name) Age: \(customer.age) Email: \(customer.email)"
    
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUpdateCustomer" {
            if let destinationVC = segue.destination as? updateCustomerViewController {
                if let index = selectedCustomerIndex {
                    let selectedCustomer = customers[index]
                    destinationVC.customer = selectedCustomer // Pass the selected customer
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCustomerIndex = indexPath.row

        let customer = customers[selectedCustomerIndex!]
        nameTextField.text = customer.name
        ageTextField.text = "\(customer.age)"
        emailTextField.text = customer.email
        if let profileImageUrlString = customer.profilePictureUrl, !profileImageUrlString.isEmpty {
            // Try to create a URL from the string
            if let imageUrl = URL(string: profileImageUrlString), imageUrl.scheme?.hasPrefix("http") == true {
                // Fetch image from URL (API)
                NetworkManager.shared.fetchImage(from: profileImageUrlString) { [weak self] image, error in
                    // Safely unwrap `self` inside the closure
                    guard let self = self else { return }

                    if let error = error {
                        print("Error fetching image from URL: \(error.localizedDescription)")
                        // Handle error, maybe show a default image
                        DispatchQueue.main.async {
                            self.customerImage.image = UIImage(named: "defaultProfilePic")  // Set default image if error occurs
                        }
                    } else if let image = image {
                        DispatchQueue.main.async {
                            // Successfully fetched image from URL, update UIImageView
                            self.customerImage.image = image
                        }
                    }
                }
            } else {
                if let profileImageBase64 = customer.profilePictureUrl, !profileImageBase64.isEmpty {
                    if let profileImage = decodeBase64ToImage(base64String: profileImageBase64) {
                        DispatchQueue.main.async {
                            // Set the decoded image in the UIImageView
                            self.customerImage.image = profileImage
                        }
                    } else {
                        // Handle the case where base64 is invalid
                        DispatchQueue.main.async {
                            self.customerImage.image = UIImage(named: "defaultProfilePic")  // Set default image if base64 decoding fails
                        }
                    }
                } else {
                    // If the URL and base64 are empty, set the default image
                    DispatchQueue.main.async {
                        self.customerImage.image = UIImage(named: "defaultProfilePic")
                    }
                }
            }
        } else {
            // No URL and no base64, set default image
            DispatchQueue.main.async {
                self.customerImage.image = UIImage(named: "defaultProfilePic")
            }
        }
        updateButtonStates()
    }

}
