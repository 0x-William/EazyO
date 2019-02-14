//
//  MenuItem.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/9/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import MBProgressHUD

class MenuItem: UIView {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var info: UILabel!
    @IBOutlet var price: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var loadingView: UIView!
    
    var hud: MBProgressHUD?
    
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> MenuItem {
        return UINib(nibName: "MenuItemView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MenuItem
    }
}
