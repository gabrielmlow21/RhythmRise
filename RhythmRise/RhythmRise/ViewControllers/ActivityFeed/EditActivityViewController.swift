//
//  EditActivityViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 6/7/24.
//

import UIKit

class EditActivityViewController: UIViewController, EquipmentSelectionDelegate {
    
    var selectedActivity: Activity?

    @IBOutlet weak var SelectEquipmentButton: UIButton!
    @IBOutlet weak var ActivityDescriptionTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .equipment
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        SelectEquipmentButton.setTitle("\(selectedActivity?.equipment?.brand ?? "") \(selectedActivity?.equipment?.model ?? "")", for: .normal)
        ActivityDescriptionTextField.text = selectedActivity?.activity_description
    }
    
    @IBAction func selectEquipment(_ sender: Any) {
        self.performSegue(withIdentifier: "showEquipmentsSegue", sender: self)
    }
    
    func equipmentSelected(_ equipment: Equipment) {
        selectedActivity?.equipment = equipment
        SelectEquipmentButton.setTitle(equipment.brand + " " + equipment.model, for: .normal)
    }
    
    @IBAction func deleteActivity(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Activity", message: "Are you sure you want to delete this activity?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
            databaseController?.removeActivity(activity: selectedActivity!, completion:  { success in
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.displayMessage(title: "Error", message: "Failed to delete activity")
                }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func updateActivity(_ sender: Any) {
        databaseController?.updateActivity(updatedActivity: selectedActivity!, completion: { success in
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.displayMessage(title: "Error", message: "Failed to update activity")
            }
        })
    }
    
    // Display error message
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEquipmentsSegue" {
            let destination = segue.destination as! SelectEquipmentTableViewController
            destination.delegate = self
        }
    }
}
