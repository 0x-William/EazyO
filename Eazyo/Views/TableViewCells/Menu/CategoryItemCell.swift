//
//  CategoryItemCell.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/12/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class CategoryItemCell: UITableViewCell {

    @IBOutlet var firstItemImage: UIImageView!
    @IBOutlet var firstItemName: UILabel!
    @IBOutlet var firstItemPrice: UILabel!
    @IBOutlet var firstButton: UIButton!
    
    @IBOutlet var secondItemView: UIView!
    @IBOutlet var secondItemImage: UIImageView!
    @IBOutlet var secondItemName: UILabel!
    @IBOutlet var secondItemPrice: UILabel!
    @IBOutlet var secondButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
