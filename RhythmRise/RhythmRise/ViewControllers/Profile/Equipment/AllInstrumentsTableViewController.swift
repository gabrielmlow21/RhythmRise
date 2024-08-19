//
//  AllInstrumentsTableViewController.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/28/24.
//

import UIKit


protocol InstrumentSelectionDelegate: AnyObject {
    func instrumentSelected(_ instrument: String)
}


class AllInstrumentsTableViewController: UITableViewController {
    
    weak var delegate: InstrumentSelectionDelegate?

    var allInstruments: [String] = ["Piano", "Guitar", "Violin", "Drums", "Saxophone", "Flute", "Cello", "Trumpet", "Clarinet", "Harmonica"]

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allInstruments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_INSTRUMENT", for: indexPath) as! InstrumentTableViewCell
        
        let instrument = allInstruments[indexPath.row]
        
        cell.InstrumentLabel.text = instrument

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let instrument = allInstruments[indexPath.row]
        delegate?.instrumentSelected(instrument)
        self.dismiss(animated: true, completion: nil)
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
