//
//  LoginViewController.swift
//  RhythmRise
//
//  Created by user249649 on 5/14/24.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {

    @IBOutlet weak var EmailErrorLabel: UILabel!
    @IBOutlet weak var PasswordErrorLabel: UILabel!
    
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resetErrorLabels()
        
        // getting access to the AppDelegate and storing a reference to the databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    @IBAction func onLogin(_ sender: Any) {
        resetErrorLabels()
        
        if(!isFieldsComplete()) {
            return
        }
        
        guard
            let email = EmailTextField.text,
            let password = PasswordTextField.text
        else { return }
        
        Task {
            do {
                
                try await databaseController?.login(email: email, password: password)
                self.performSegue(withIdentifier: "showHomePageSegue", sender: self)
                
            } catch let error as NSError {
                
                switch error.code {
                    
                    case AuthErrorCode.invalidCredential.rawValue:
                        EmailErrorLabel.text = "Invalid credentials"
                        PasswordErrorLabel.text = "Invalid credentials"
                        EmailErrorLabel.isHidden = false
                        PasswordErrorLabel.isHidden = false
                    
                    case AuthErrorCode.invalidEmail.rawValue:
                        EmailErrorLabel.text = "Invalid email format"
                        EmailErrorLabel.isHidden = false
                    
                    default:
                        displayMessage(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    // Reset error labels
    func resetErrorLabels() -> Void {
        EmailErrorLabel.isHidden = true
        PasswordErrorLabel.isHidden = true
    }
    
    
    // Check if any field is empty and show the corresponding error message
    func isFieldsComplete() -> Bool {
        var isComplete = true
        if EmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            EmailErrorLabel.text = "Email cannot be empty"
            EmailErrorLabel.isHidden = false
            isComplete = false
        }
        if PasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            PasswordErrorLabel.text = "Password cannot be empty"
            PasswordErrorLabel.isHidden = false
            isComplete = false
        }
        return isComplete
    }
    
    
    // Display error message
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }


}
