//
//  MenuCell.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/8/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet var featureCarouselView: iCarousel!
    @IBOutlet weak var indicatorView: UIView!
    var itemCount: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func scrollToNextView() {
        featureCarouselView.scroll(byNumberOfItems: 1, duration: 0.5)
    }
    
    func makeIndicatorUI(_ position: Int) {
        for bar in indicatorView.subviews {
            bar.removeFromSuperview()
        }
        
        if (itemCount > 0) {
            for i in 0 ... itemCount - 1 {
                let bar = UIView(frame: CGRect(x: i * 30, y: 0, width: 26, height: 3))
                bar.layer.cornerRadius = 2.0
                bar.clipsToBounds = true
                if (i == position) {
                    bar.backgroundColor = UIColor.eazyoOrangeColor()
                }
                else {
                    bar.backgroundColor = UIColor.eazyoGreyColor().withAlphaComponent(0.6)
                }
                indicatorView.addSubview(bar)
            }
        }
    }
}
