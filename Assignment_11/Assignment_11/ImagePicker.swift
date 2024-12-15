//
//  ImagePicker.swift
//  Assignment_11
//
//  Created by Sameer Shashikant Deshpande on 11/20/24.
//


import SwiftUI
import UIKit

// ImagePicker to allow users to select an image from the photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isImagePickerPresented: Bool
    @Binding var selectedImageData: Data?

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var isImagePickerPresented: Bool
        @Binding var selectedImageData: Data?

        init(isImagePickerPresented: Binding<Bool>, selectedImageData: Binding<Data?>) {
            _isImagePickerPresented = isImagePickerPresented
            _selectedImageData = selectedImageData
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isImagePickerPresented = false
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    selectedImageData = imageData
                }
            }
            isImagePickerPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isImagePickerPresented: $isImagePickerPresented, selectedImageData: $selectedImageData)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = .photoLibrary
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
