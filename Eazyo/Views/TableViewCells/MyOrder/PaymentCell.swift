//
//  PaymentCell.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/24/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {

    @IBOutlet var cardView: UIView!
    @IBOutlet var addCardView: UIView!
    @IBOutlet var paymentTypeImage: UIImageView!
    @IBOutlet var paymentName: UILabel!
    
    @IBOutlet var cardImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet var paymentNameLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
