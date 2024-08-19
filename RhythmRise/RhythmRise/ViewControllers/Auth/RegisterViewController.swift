//
//  RegisterViewController.swift
//  RhythmRise
//
//  Created by user249649 on 5/14/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    
    @IBOutlet weak var UsernameErrorLabel: UILabel!
    @IBOutlet weak var EmailErrorLabel: UILabel!
    @IBOutlet weak var ConfirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var PasswordErrorLabel: UILabel!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        resetErrorLabels()
        
        // getting access to the AppDelegate and storing a reference to the databaseController
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // show keyboard
        EmailTextField.becomeFirstResponder()

    }


    @IBAction func onSignUp(_ sender: Any) {
        
        resetErrorLabels()
        
        if(!isConfirmPasswordValid() || !isFieldsComplete()) {
            return
        }
        
        guard
            let email = EmailTextField.text,
            let password = PasswordTextField.text,
            let username = UsernameTextField.text
        else { return }
        
        Task {
            do {
                
                try await databaseController?.createAccount(email: email, password: password, username: username)
                self.performSegue(withIdentifier: "showHomePageSegue", sender: self)
                
            } catch let error as NSError {
                
                switch error.code {
                    
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        
                        EmailErrorLabel.text = "This email is already in use"
                        EmailErrorLabel.isHidden = false
                    
                    case AuthErrorCode.weakPassword.rawValue:
                        
                        PasswordErrorLabel.text = "Your password is too weak"
                        PasswordErrorLabel.isHidden = false
                    
                    case AuthErrorCode.invalidEmail.rawValue:
                        
                        EmailErrorLabel.text = "Your email is invalid"
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
        UsernameErrorLabel.isHidden = true
        PasswordErrorLabel.isHidden = true
        ConfirmPasswordErrorLabel.isHidden = true
    }
    
    
    // Check if any field is empty and show the corresponding error message
    func isFieldsComplete() -> Bool {
        var isComplete: Bool = true
        if EmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            EmailErrorLabel.text = "Email cannot be empty"
            EmailErrorLabel.isHidden = false
            isComplete = false
        }
        if UsernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            UsernameErrorLabel.text = "Username cannot be empty"
            UsernameErrorLabel.isHidden = false
            isComplete = false
        }
        if PasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            PasswordErrorLabel.text = "Password cannot be empty"
            PasswordErrorLabel.isHidden = false
            isComplete = false
        }
        if ConfirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            ConfirmPasswordErrorLabel.text = "Confirm password cannot be empty"
            ConfirmPasswordErrorLabel.isHidden = false
            isComplete = false
        }
        return isComplete
    }
    
    
    func isConfirmPasswordValid() -> Bool {
        if PasswordTextField.text != ConfirmPasswordTextField.text {
            ConfirmPasswordErrorLabel.text = "Passwords do not match"
            ConfirmPasswordErrorLabel.isHidden = false
            return false
        }
        return true
    }
    
    
    // Display error message
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
