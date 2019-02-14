//
//  PromotionViewController.swift
//  Eazyo
//
//  Created by SoftDev on 3/2/17.
//  Copyright © 2017 SoftDev0420. All rights reserved.
//

import UIKit
import Alamofire

class PromotionViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var textTopConstraint: NSLayoutConstraint!
    
    var promotionData: [[String : Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mainView.layer.cornerRadius = 3.0
        
        let firstItem = promotionData![0]
        
        itemDescription.text = firstItem["description"] as? String ?? ""
        
        if let imageUrl = firstItem["image_url"] as? String {
            Alamofire.request(imageUrl)
                .responseImage { response in
                    if let image = response.result.value {
                        self.itemImage.image = image
                    }
            }
        }
        
        textTopConstraint.constant = -200
        itemDescription.alpha = 0
        mainView.alpha = 0
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textTopConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.itemDescription.alpha = 1
            self.mainView.alpha = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onContinue(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
}
