//
//  PlaceTypeCell.swift
//  Eazyo
//
//  Created by Admin on 11/1/17.
//  Copyright © 2017 SoftDev0420. All rights reserved.
//

import UIKit

class PlaceTypeCell: UITableViewCell {

    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var type: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
