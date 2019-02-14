//
//  FoodInfoCell.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/13/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class FoodInfoCell: UITableViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var info: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
