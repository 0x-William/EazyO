//
//  MenuTimeCell.swift
//  Eazyo
//
//  Created by SoftDev on 12/19/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class MenuTimeCell: UITableViewCell {
    
    @IBOutlet weak var weekDay: UILabel!
    @IBOutlet weak var time: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
