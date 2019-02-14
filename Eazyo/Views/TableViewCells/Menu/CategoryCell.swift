//
//  CategoryCell.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/8/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet var firstCategoryName: UILabel!
    @IBOutlet var secondCategoryName: UILabel!
    @IBOutlet var secondCategoryView: UIView!
    @IBOutlet var firstButton: UIButton!
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
