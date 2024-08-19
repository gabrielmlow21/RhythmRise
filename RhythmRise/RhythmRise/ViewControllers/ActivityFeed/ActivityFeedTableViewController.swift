//
//  ActivityFeedTableViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 6/6/24.
//

import UIKit

class ActivityFeedTableViewController: UITableViewController, DatabaseListener {
    
    var userActivities: [Activity] = []
    var selectedActivity: Activity?
    
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .activities

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onUserDetailsChange(change: DatabaseChange, user: User) {
        // do nothing
    }
    
    func onEquipmentsChange(change: DatabaseChange, equipments: [Equipment]) {
        // do nothing
    }
    
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {
        userActivities = activities
        tableView.reloadData()
    }

    @IBAction func addActivity(_ sender: Any) {
        self.performSegue(withIdentifier: "recordActivitySegue", sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userActivities.count == 0 ? 1 : userActivities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return no activities cell indicator
        if userActivities.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "CELL_NO_ACTIVITIES", for: indexPath) as! NoActivitiesIndicatorTableViewCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_ACTIVITY", for: indexPath) as! ActivityTableViewCell
        let activity = userActivities[indexPath.row]
        cell.DurationLabel.text = convertSecondsToString(seconds: activity.elapsed_time!)
        cell.InstrumentLabel.text = activity.equipment?.instrument
        cell.MetaLabel.text = "\(convertTimeIntervalToDateTime(timestamp: activity.timestamp!))"
        cell.EquipmentLabel.text = "\(activity.equipment?.brand ?? "") \(activity.equipment?.model ?? "")"
        cell.ActivityDescriptionLabel.text = activity.activity_description
        cell.selectionStyle = .none  // make cell unpressable
        return cell
    }
    
    // displays the datetime in string
    func convertTimeIntervalToDateTime(timestamp: Double) -> String {
        // Create a Date instance from the timestamp
        let date = Date(timeIntervalSince1970: timestamp)

        // Create a DateFormatter
        let dateFormatter = DateFormatter()

        // Set the date format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        // Convert the Date to a String
        return dateFormatter.string(from: date)
    }
    
    
    // converts seconds to xxh xxm xxs format
    func convertSecondsToString(seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let seconds = Int(seconds) % 60

        var timeString = ""

        if hours > 0 {
            timeString += "\(hours)h "
        }
        if minutes > 0 || hours > 0 {
            timeString += "\(minutes)m "
        }
        timeString += "\(seconds)s"

        return timeString
    }
    

    // swipe right to left to open edit page
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [self] (action, view, completionHandler) in
            selectedActivity = userActivities[indexPath.row]
            performSegue(withIdentifier: "editActivitySegue", sender: self)
            completionHandler(true)
        }
        editAction.backgroundColor = UIColor(red: 24.0/255.0, green: 5.0/255.0, blue: 130.0/255.0, alpha: 1.0)
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editActivitySegue" {
            let destination = segue.destination as! EditActivityViewController
            destination.selectedActivity = selectedActivity
        }
    }
}
