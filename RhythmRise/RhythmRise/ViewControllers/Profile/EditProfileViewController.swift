//
//  EditProfileViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/27/24.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()  // instance of image picker
    
    var bio: String?
    var location: String?
    var profilePictureURL: String?
    
    @IBOutlet weak var EditPictureButton: UIButton!
    @IBOutlet weak var SaveButton: UIBarButtonItem!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var BioTextField: UITextField!
    @IBOutlet weak var LocationTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting access to the AppDelegate and storing a reference to the databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        LocationTextField.text = location
        BioTextField.text = bio
        
        imagePicker.delegate = self
        
        // Check if the user has a profile picture URL and it's not empty
        if let profilePicture = profilePictureURL, !profilePicture.isEmpty {
            // Attempt to create a URL object from the profile picture string
            if let url = URL(string: profilePicture) {
                // Create an asynchronous data task to fetch the image data
                URLSession.shared.dataTask(with: url) { data, response, error in
                    // Check if data was received successfully
                    if let data = data {
                        // Update the UI on the main thread
                        DispatchQueue.main.async {
                            // Set the profile picture image with the received data
                            self.profilePicture.image = UIImage(data: data)
                        }
                    }
                }.resume() // Start the data task
            }
        } else {
            // Log a message if the profile picture URL is empty or nil
            print("Profile picture URL is empty or nil")
        }
    }
    
    
    @IBAction func onPressSave(_ sender: Any) {
        databaseController?.updateUserBioAndLocation(bio: BioTextField.text!, location: LocationTextField.text!) { success in
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.displayMessage(title: "Error", message: "Update failed")
            }
        }
    }
    
    
    @IBAction func editPicture(_ sender: Any) {
        // Create an action sheet
       let actionSheet = UIAlertController(title: "Upload Picture", message: "Choose an option", preferredStyle: .actionSheet)
       
       // Add a camera action
       actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action:UIAlertAction) in
           if UIImagePickerController.isSourceTypeAvailable(.camera) {
               self.imagePicker.sourceType = .camera
               self.present(self.imagePicker, animated: true, completion: nil)
           } else {
               self.displayMessage(title: "Error", message: "Camera not available")
           }
       }))
       
       // Add a photo library action
       actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
           self.imagePicker.sourceType = .photoLibrary
           self.present(self.imagePicker, animated: true, completion: nil)
       }))
       
       // Add a saved photos album action
       actionSheet.addAction(UIAlertAction(title: "Saved Photos Album", style: .default, handler: { (action:UIAlertAction) in
           self.imagePicker.sourceType = .savedPhotosAlbum
           self.present(self.imagePicker, animated: true, completion: nil)
       }))
       
       // Add a cancel action
       actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
       
       // Present the action sheet
       self.present(actionSheet, animated: true, completion: nil)
    }
    
    // This delegate method is called when the user picks an image. It gets the picked image from the info dictionary and prints it.
    // once image is picked, it will be uploaded and used immediately (same system as Instagram)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        SaveButton.isEnabled = false
        EditPictureButton.setTitle("Uplading image...", for: .normal)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            databaseController?.updateUserImage(newImage: pickedImage) { success in
                if success {
                    self.SaveButton.isEnabled = true
                    self.EditPictureButton.setTitle("Edit picture", for: .normal)
                    self.profilePicture.image = pickedImage  // show image on profile to indicate success
                } else {
                    self.displayMessage(title: "Error", message: "Failed to upload image")
                }
            }
        }
        
        // Dismiss the image picker.
        dismiss(animated: true, completion: nil)
    }

    // This delegate method is called when the user cancels picking an image. It simply dismisses the image picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Display error message
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
        
  
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "returnProfileSegue" {
//            let destination = segue.destination as! ProfileViewController
//            destination.refreshData()
//        }
//    }
}
