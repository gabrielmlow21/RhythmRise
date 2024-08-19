//
//  AllEquipmentsTableViewCell.swift
//  RhythmRise
//
//  Created by Gabriel Low on 5/28/24.
//

import UIKit

class AllEquipmentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var PlaytimeLabel: UILabel!
    @IBOutlet weak var InstrumentLabel: UILabel!
    @IBOutlet weak var ModelLabel: UILabel!
    @IBOutlet weak var NoEquipmentsIndicator: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
