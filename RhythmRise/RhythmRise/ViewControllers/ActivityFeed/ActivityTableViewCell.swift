//
//  ActivityTableViewCell.swift
//  RhythmRise
//
//  Created by Gabriel Low on 6/6/24.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var EquipmentLabel: UILabel!
    @IBOutlet weak var ActivityDescriptionLabel: UILabel!
    @IBOutlet weak var DurationLabel: UILabel!
    @IBOutlet weak var InstrumentLabel: UILabel!
    @IBOutlet weak var MetaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
