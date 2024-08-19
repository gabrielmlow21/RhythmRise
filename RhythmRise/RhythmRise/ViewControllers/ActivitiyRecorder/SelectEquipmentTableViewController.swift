//
//  SelectEquipmentTableViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/29/24.
//

import UIKit

protocol EquipmentSelectionDelegate: AnyObject {
    func equipmentSelected(_ equipment: Equipment)
}


class SelectEquipmentTableViewController: UITableViewController, DatabaseListener {

    var allEquipments: [Equipment] = []
    
    weak var delegate: EquipmentSelectionDelegate?
    
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .equipment
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    @IBAction func addEquipment(_ sender: Any) {
        self.performSegue(withIdentifier: "addEquipmentSegue", sender: self)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEquipments.count == 0 ? 1 : allEquipments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_EQUIPMENT", for: indexPath) as! SelectEquipmentTableViewCell
        
        if (allEquipments.count == 0) {
            cell.EquipmentLabel.isHidden = true
            cell.InstrumentLabel.isHidden = true
            cell.NoEquipmentsIndicator.isHidden = false
            return cell
        }
        
        let equipment = allEquipments[indexPath.row]
        
        cell.EquipmentLabel.text = equipment.brand + " " + equipment.model
        cell.InstrumentLabel.text = equipment.instrument

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let equipment = allEquipments[indexPath.row]
        delegate?.equipmentSelected(equipment)
        self.navigationController?.popViewController(animated: true)
    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
