//
//  ActiveOrderDetailViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/6/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD
import Alamofire
import AlamofireImage
import MRProgress

class OrderDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, WebServiceDelegate {
    
    @IBOutlet weak var categoryInfo: UILabel!
    @IBOutlet weak var progressBar: UIImageView!
    @IBOutlet weak var itemImageProgressBar: MRActivityIndicatorView!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var extraInfo: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var chargeType: UILabel!
    
    @IBOutlet var states: [UILabel]!
    
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var taxPercent: UILabel!
    @IBOutlet weak var taxPrice: UILabel!
    @IBOutlet weak var servicePercent: UILabel!
    @IBOutlet weak var servicePrice: UILabel!
    @IBOutlet weak var tip: UILabel!
    @IBOutlet weak var tipPrice: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var deliveredButton: UIButton!
    
    var loadingAnimator : MBProgressHUD?
    
    let progressImageNameDictionary = ["new" : "InitProgressBar",
                                       "received" : "HalfProgressBar",
                                       "ready" : "FullProgressBar",
                                       "completed" : "FullProgressBar"]
    
    var orderDetail: [String : Any]?
    var items: [[String : Any]]?
    var orderedItemImage: UIImage?
    var width: CGFloat?
    
    var locationType:String?
    var locationName:String?
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        items = orderDetail!["items"] as? [[String : Any]]
        locationType = orderDetail!["location_type"] as? String
        locationName = orderDetail!["location_name"] as? String
        if (locationName == nil) {
            locationName = ""
        }
        let vendorName = orderDetail!["vendor_name"] as? String
        
        if (vendorName != nil) {
            location.text = vendorName! + " - "
        }
        
        if(locationType != nil && locationType! == "pickup")
        {
            states[2].text = "Come get it!"
            deliveredButton.setTitle("Picked Up", for: UIControlState())
            location.text = location.text! + locationName!
            
        } else {
            var mapName = (orderDetail!["map"] as! [String : Any])["name"] as? String
            if (mapName == nil) {
                mapName = ""
            }
            location.text = location.text! + mapName!
        }
        
        width = UIScreen.main.bounds.width
        tabBarController!.tabBar.isHidden = true
        
        if (orderedItemImage != nil) {
            itemImage.image = orderedItemImage
        }
        else {
            itemImageProgressBar.isHidden = false
            itemImageProgressBar!.tintColor = UIColor.eazyoBlackColor()
            itemImageProgressBar!.startAnimating()
            
            let orderedItemImageUrl = orderDetail!["confirmation_icon_url"] as? String
            if (orderedItemImageUrl != nil) {
                Alamofire.request(orderedItemImageUrl!)
                    .responseImage { response in
                        self.itemImageProgressBar.isHidden = true
                        self.itemImageProgressBar!.stopAnimating()
                        if let image = response.result.value {
                            self.itemImage.image = image
                        }
                }
            }
        }
        
        categoryInfo.text = orderDetail!["item_summary"] as? String
        let status = (orderDetail!["status"] as! [String : Any])["name"] as? String
        progressBar.image = UIImage(named: progressImageNameDictionary[status!]!)
        
        if (status == "ready" || status == "completed") {
            if (status == "ready") {
                deliveredButton.isHidden = false
            }
            states[1].textColor = UIColor.eazyoBlackColor()
            states[2].textColor = UIColor.eazyoBlackColor()
        }
        else if(status == "received") {
            states[1].textColor = UIColor.eazyoBlackColor()
        }
        
        orderId.text = "#" + (orderDetail!["confirmation_code"] as? String)!
        name.text = (orderDetail!["user"] as! [String : Any])["name"] as? String
        extraInfo.text = orderDetail!["notes"] as? String
        
        chargeType.text = orderDetail!["charge_type"] as? String
        
        subTotal.text = "$" + (orderDetail!["base_amount"] as? String)!
        
        let discountPct = orderDetail!["discount_pct"] as? Float
        if (discountPct != nil && discountPct != 0) {
            discount.text = "(\(discountPct!)% Discount applied)"
        }
        
        taxPercent.text = "(" + String(orderDetail!["sales_tax_percentage"] as! Int) + "%)"
        taxPrice.text = "$" + (orderDetail!["sales_tax"] as? String)!
        
        let serviceFeeType = (orderDetail!["service_fee_type"] as? String)!
        if (serviceFeeType == "pct") {
            servicePercent.text = "(" + String(orderDetail!["service_fee_percentage"] as! Int) + "%)"
        }
        else {
            servicePercent.text = ""
        }
        servicePrice.text = "$" + (orderDetail!["service_fee"] as? String)!
        total.text = "$" + (orderDetail!["total_charge"] as? String)!
        
        let tipAmount = orderDetail!["tip_amount"] as! String
        
        if Float(tipAmount) == 0.0 {
            tip.isHidden = true
            tipPrice.isHidden = true
        }
        else {
            tip.isHidden = false
            tipPrice.isHidden = false
            tipPrice.text = "$" + tipAmount
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////////
    
    //  NavigationBar
    
    @IBAction func onClose(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            return nil
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return SlideAnimator(slideType: SLIDE_DOWN_POP)
        }
        
        return nil
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        loadingAnimator!.hide(true)
        
        switch apiName {
        case "completeOrder":
            navigationController!.popViewController(animated: true)
            break
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "completeOrder":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var extraInfo = items![indexPath.row]["notes"] as? String
        if (extraInfo == nil) {
            extraInfo = ""
        }
        return 37 + Util.heightForView(extraInfo!, font: UIFont(name: "OpenSans", size: 13.0)!, width: width! - 101)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderItemCell
        let count = items![indexPath.row]["quantity"] as! Int
        cell.foodNameCount.text = String(count) + "  " + (items![indexPath.row]["name"] as? String)!
        let priceInString = items![indexPath.row]["total_cost"] as? String
        let floatPrice = Float(priceInString!)
        cell.price.text = "$" + Util.stringWithPlaceCount(floatPrice!, placeCount: 2)
        cell.extraInfo.text = items![indexPath.row]["notes"] as? String
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //////////////////////////////
    
    @IBAction func onDelivered(_ sender: AnyObject) {
        loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingAnimator!.mode = .indeterminate
        loadingAnimator!.labelText = "Completing Order..."
        WebService.instance.delegate = self
        let parameters = ["order_uuid" : orderDetail!["uuid"] as! String]
        WebService.instance.completeOrder(parameters)
    }
    
}
