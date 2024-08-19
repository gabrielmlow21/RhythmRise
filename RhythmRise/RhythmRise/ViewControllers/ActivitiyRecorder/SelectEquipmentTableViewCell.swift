//
//  SelectEquipmentTableViewCell.swift
//  RhythmRise
//
//  Created by user249649 on 5/30/24.
//

import UIKit

class SelectEquipmentTableViewCell: UITableViewCell {

    @IBOutlet weak var InstrumentLabel: UILabel!
    @IBOutlet weak var NoEquipmentsIndicator: UILabel!
    @IBOutlet weak var EquipmentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
