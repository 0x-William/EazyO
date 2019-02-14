//
//  LocationCell.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/5/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD

class LocationCell: UITableViewCell {
    @IBOutlet var nearbyVenues: UIView!
    @IBOutlet var locationImage: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var address: UILabel!
    
    var hud: MBProgressHUD?
    
    @IBOutlet var nearbyVenuesHeightConstraint: NSLayoutConstraint!
    @IBOutlet var locationViewTopConstraint: NSLayoutConstraint!
}
