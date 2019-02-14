//
//  CategoryListItemCell.swift
//  Eazyo
//
//  Created by SoftDev on 12/15/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class CategoryListItemCell: UITableViewCell {

    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
