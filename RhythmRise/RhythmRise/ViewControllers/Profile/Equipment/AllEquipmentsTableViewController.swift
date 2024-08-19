//
//  AllEquipmentsTableViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/28/24.
//

import UIKit

class AllEquipmentsTableViewController: UITableViewController, DatabaseListener {
    
    var allEquipments: [Equipment] = []
    
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .equipment

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
        allEquipments = equipments
        tableView.reloadData()
    }
    
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {
        // do nothing
    }


    @IBAction func onPressAddEquipment(_ sender: Any) {
        self.performSegue(withIdentifier: "addEquipmentSegue", sender: self)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEquipments.count == 0 ? 1 : allEquipments.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_EQUIPMENT", for: indexPath) as! AllEquipmentsTableViewCell
        
        if (allEquipments.count == 0) {
            cell.ModelLabel.isHidden = true
            cell.InstrumentLabel.isHidden = true
            cell.NoEquipmentsIndicator.isHidden = false
            return cell
        }
        
        let equipment = allEquipments[indexPath.row]
        
        cell.ModelLabel.text = equipment.brand + " " + equipment.model
        cell.InstrumentLabel.text = equipment.instrument
        cell.PlaytimeLabel.text = String(format: "%.1f", round(Double(equipment.seconds_used) * 10) / 10 ) + " hrs"

        return cell
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let equipment = allEquipments[indexPath.row]
            let alert = UIAlertController(title: "Delete Equipment", message: "Are you sure you want to delete \(equipment.brand) \(equipment.model)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.databaseController?.removeEquipment(equipment: self.allEquipments[indexPath.row])
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }


    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
