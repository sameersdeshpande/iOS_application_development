//
//  updateCustomerViewController.swift
//  Assignment_7
//
//  Created by Sameer Shashikant Deshpande on 11/3/24.
//

import Foundation
import UIKit

class updateCustomerViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var updateScrollView: UIScrollView!
    @IBOutlet weak var updateImageButton: UIButton!
    @IBOutlet weak var updateImage: UIImageView!
    @IBOutlet weak var updateCustomerTapped: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    var customer: Customer?
    override func viewDidLoad() {
        super.viewDidLoad()
        ageTextField.keyboardType = .numberPad
        if let customer = customer {
             nameTextField.text = customer.name
             ageTextField.text = "\(customer.age)"
             emailTextField.text = customer.email
            loadProfileImage(from: customer.profilePictureUrl)
        }
    }
      // MARK: - Profile Image Handling
      func loadProfileImage(from urlString: String?) {
          if let profilePictureUrl = urlString {
              if let imageData = Data(base64Encoded: profilePictureUrl) {
                  updateImage.image = UIImage(data: imageData)
              } else if let imageUrl = URL(string: profilePictureUrl), imageUrl.scheme?.hasPrefix("http") == true {
                  NetworkManager.shared.fetchImage(from: profilePictureUrl) { [weak self] image, error in
                      guard let self = self else { return }
                      DispatchQueue.main.async {
                          if let image = image {
                              self.updateImage.image = image
                          } else {
                              self.updateImage.image = UIImage(named: "defaultProfilePic")
                          }
                      }
                  }
              } else {
                  updateImage.image = UIImage(named: "defaultProfilePic")
              }
          } else {
              updateImage.image = UIImage(named: "defaultProfilePic")
          }
      }

    @IBAction func updateImageTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self  // Set delegate to handle image selection
            imagePickerController.sourceType = .photoLibrary  // Default to photo library

            // Check if the camera is available and offer the option to use it
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                // Present an action sheet with the option to choose between camera or photo library
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
                // If camera is not available, show only the photo library
                self.present(imagePickerController, animated: true, completion: nil)
            }
    }
    
    @IBAction func updateCustomerTapped(_ sender: Any) {
        guard let customer = customer,
              let name = nameTextField.text, !name.isEmpty,
              let ageString = ageTextField.text, let age = Int(ageString), age > 0 else {
            showMessage("Please fill in all fields correctly.")
            return
        }
        
        // If the profile picture was updated, use the base64 string
        var profilePictureUrl: String? = customer.profilePictureUrl
        if let newProfilePicture = updateImage.image {
            profilePictureUrl = convertImageToBase64String(image: newProfilePicture)
        }
        
        // Call the DataManager to update the customer, including the profile picture
        DataManager.shared.updateCustomer(at: Int64(customer.id), name: name, age: age, profilePictureUrl: profilePictureUrl)
        
        // Pass the updated customer data back to the previous screen
        if let navigationController = navigationController,
           let previousViewController = navigationController.viewControllers.first(where: { $0 is CustomerViewController }) as? CustomerViewController {
            previousViewController.updateCustomerData(customer: customer) // Pass updated customer back
        }
        
        // Go back to the previous screen or show a success message
        navigationController?.popViewController(animated: true)
        showMessage("Customer updated successfully!")}
        func showMessage(_ message: String) {
             let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "OK", style: .default))
             present(alert, animated: true)
         }
         
         func convertImageToBase64String(image: UIImage) -> String? {
             if let imageData = image.jpegData(compressionQuality: 1.0) {
                 return imageData.base64EncodedString()
             }
             return nil
         }

func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let selectedImage = info[.originalImage] as? UIImage {
        updateImage.image = selectedImage
        if let base64Image = convertImageToBase64String(image: selectedImage) {
            customer?.profilePictureUrl = base64Image
        }
    }
    dismiss(animated: true, completion: nil)
}
func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    // Simply dismiss the image picker
    dismiss(animated: true, completion: nil)
}

}

