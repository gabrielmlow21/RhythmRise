//
//  AddEquipmentViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/28/24.
//

import UIKit

class AddEquipmentViewController: UIViewController, InstrumentSelectionDelegate {
    
    @IBOutlet weak var BrandTextField: UITextField!
    @IBOutlet weak var ModelTextField: UITextField!
    @IBOutlet weak var InstrumentButton: UIButton!
    
    var InstrumentButtonPlaceholder: String = "Press to Select"
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InstrumentButton.setTitle(InstrumentButtonPlaceholder, for: .normal)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    func instrumentSelected(_ instrument: String) {
        InstrumentButton.setTitle(instrument, for: .normal)
    }
    
    

    @IBAction func onSave(_ sender: Any) {
        if (isFieldsComplete()) {
            databaseController?.saveEquipment(instrument: InstrumentButton.currentTitle!, brand: BrandTextField.text!, model: ModelTextField.text!, completion: { success in
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.displayMessage(title: "Error", message: "Failed to add equipment")
                }
            })
        } else {
            self.displayMessage(title: "Error", message: "Incomplete Fields")
        }
    }
    
    
    @IBAction func onPressInstrument(_ sender: Any) {
        self.performSegue(withIdentifier: "allInstrumentsSegue", sender: self)
    }
    
    
    // Check if any field is empty and show the corresponding error message
    func isFieldsComplete() -> Bool {
        var isComplete = true
        if BrandTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            isComplete = false
        }
        if ModelTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            isComplete = false
        }
        if InstrumentButton.currentTitle == InstrumentButtonPlaceholder {
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allInstrumentsSegue",
           let destination = segue.destination as? AllInstrumentsTableViewController {
            destination.delegate = self
        }
    }
}
