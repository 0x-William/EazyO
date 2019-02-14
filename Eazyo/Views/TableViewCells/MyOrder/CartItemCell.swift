//
//  CartItemCell.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/23/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import SWTableViewCell

class CartItemCell: SWTableViewCell {

    @IBOutlet var count: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
