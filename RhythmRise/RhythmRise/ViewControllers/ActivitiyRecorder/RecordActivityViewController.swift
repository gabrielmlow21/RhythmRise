//
//  RecordActivityViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/29/24.
//

import UIKit

class RecordActivityViewController: UIViewController, EquipmentSelectionDelegate {
    
    @IBOutlet weak var EquipmentButton: UIButton!
    @IBOutlet weak var StoppedIndicatorView: UIView!
    @IBOutlet weak var ActivityDescriptionTextField: UITextField!
    @IBOutlet weak var SaveButton: UIBarButtonItem!
    @IBOutlet weak var StopwatchLabel: UILabel!
    @IBOutlet weak var ControlButton: UIButton!
    
    var EquipmentButtonPlaceholder: String = "Press to Select"
    
    var selectedEquipment: Equipment?
    
    weak var databaseController: DatabaseProtocol?
    
    // to save stopwatch states
    var isStarted: Bool = false
    var isRunning: Bool = false

    var stopwatch: Timer?
    var startTime: Date?
    var elapsedTime: TimeInterval = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        EquipmentButton.setTitle(EquipmentButtonPlaceholder, for: .normal)
                
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        SaveButton.isEnabled = false
        StoppedIndicatorView.isHidden = true
    }
    
    
    func equipmentSelected(_ equipment: Equipment) {
        selectedEquipment = equipment
        EquipmentButton.setTitle(equipment.brand + " " + equipment.model, for: .normal)
    }

    
    @IBAction func onControlPress(_ sender: Any) {
        // initial press
        if (!isStarted) {
            isStarted = true
            isRunning = true
            startStopwatch()
            ControlButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            // pause
            if (isRunning) {
                isRunning = false
                StoppedIndicatorView.isHidden = false
                pauseStopwatch()
                ControlButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                SaveButton.isEnabled = true
            }
            // resume
            else {
                isRunning = true
                StoppedIndicatorView.isHidden = true
                resumeStopwatch()
                ControlButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                SaveButton.isEnabled = false
            }
        }
    }
    
    
    func startStopwatch() {
        startTime = Date()
        stopwatch = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateStopwatch), userInfo: nil, repeats: true)
    }
    
    @objc func updateStopwatch() {
        let currentTime = Date()
        let totalTime = currentTime.timeIntervalSince(startTime!) + elapsedTime
        let hours = Int(totalTime) / 3600
        let minutes = Int(totalTime) / 60 % 60
        let seconds = Int(totalTime) % 60
        StopwatchLabel.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func pauseStopwatch() {
        elapsedTime += Date().timeIntervalSince(startTime!)
        stopwatch?.invalidate()
        stopwatch = nil
    }

    func resumeStopwatch() {
        if stopwatch == nil {
            startStopwatch()
        }
    }
    
    
    @IBAction func onSelectEquipment(_ sender: Any) {
        self.performSegue(withIdentifier: "showEquipmentsSegue", sender: self)
    }
    
    
    @IBAction func onSaveActivity(_ sender: Any) {
        if selectedEquipment == nil {
            displayMessage(title: "No Equipment Selected", message: "Select an equipment before saving")
        } else {
            databaseController?.saveActivity(elapsedTime: elapsedTime, equipment: selectedEquipment!, description: ActivityDescriptionTextField.text, completion: { success in
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.displayMessage(title: "Error", message: "Failed to add activity")
                }
            })
        }
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
