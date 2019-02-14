//
//  OrdersViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/23/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireImage
import MRProgress

class OrdersViewController: UIViewController, UITabBarControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, WebServiceDelegate {

    @IBOutlet weak var cartItemCount: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var activeOrdersTable: UITableView!
    @IBOutlet weak var orderHistoryTable: UITableView!
    @IBOutlet weak var hasOrderView: UIView!
    @IBOutlet weak var orderIcon: UIImageView!
    @IBOutlet weak var orderCode: UILabel!
    @IBOutlet weak var downArrow: UIImageView!
    @IBOutlet weak var emptyScreen: UIView!
    
    @IBOutlet weak var orderIndicatorXConstraint: NSLayoutConstraint!
    
    let colorDictionary: [String : UIColor] = ["new" : UIColor.eazyoNewOrderItemColor(),
                                               "received" : UIColor.eazyoReceivedOrderItemColor(),
                                               "ready" : UIColor.eazyoReadyOrderItemColor(),
                                               "completed" : UIColor.clear]
    let statusDictionary: [String : String] = ["new" : "  Ordered  ",
                                               "received" : "  In Progress  ",
                                               "ready" : "  On It's Way  ",
                                               "completed" : "  Delivered  "]
    var now: Date?
    let dateFormatter = DateFormatter()
    var timer: Timer?
    
    var loadingAnimator : MBProgressHUD?
    var progressView: MRActivityIndicatorView?
    
    var activeOrderData, orderHistoryData: [[String : Any]]?
    var hasOrder: Bool = false
    var lastOrder: [String : Any]?
    
    let userDefaults = UserDefaults.standard
    var screenHeight: CGFloat?
    var screenWidth: CGFloat?
    var orderedItemImages: [UIImage]?
    var imageFlags: [Bool]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         NotificationCenter.default.addObserver(self, selector: #selector(OrdersViewController.loadActiveOrders), name:NSNotification.Name(rawValue: "showNotifiedOrder"), object: nil)
        tabBarController!.delegate = self
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
        
        orderedItemImages = [UIImage]()
        imageFlags = [Bool]()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        now = Date()
        updateCartCount(CartManager.instance.getOrderedItemCount())
        tabBarController!.tabBar.isHidden = false
        tabBarController!.delegate = self
        navigationController!.delegate = self
        
        if (WebService.instance.authToken == "") {
            emptyScreen.isHidden = false
        }
        else {
            emptyScreen.isHidden = true
            
            let checkOrder = userDefaults.bool(forKey: "checkOrder")
            
            if (hasOrder) {
                let confirmationCode = lastOrder!["confirmation_code"] as! String
                let orderIconUrl = lastOrder!["confirmation_icon_url"] as? String

                orderCode.text = "#" + confirmationCode
                onActiveOrders(activeButton)
                if (orderIconUrl == nil) {
                    orderIcon.image = UIImage(named: "OrderedItem")
                }
                else {
                    let orderIconHeight = (screenHeight! - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT) * 0.267 * 0.432
                    progressView = MRActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: orderIconHeight, height: orderIconHeight))
                    progressView!.tintColor = UIColor.eazyoBlackColor()
                    progressView!.startAnimating()
                    orderIcon!.addSubview(progressView!)
                    
                    Alamofire.request(orderIconUrl!)
                        .responseImage { response in
                            self.progressView!.isHidden = true
                            self.progressView!.stopAnimating()
                            if let image = response.result.value {
                                self.orderIcon.image = image
                            }
                            else {
                                self.orderIcon.image = UIImage(named: "OrderedItem")
                            }
                    }
                }
                hasOrderView.isHidden = false
                
                if (checkOrder == true) {
                    downArrow.isHidden = true
                }
                else {
                    downArrow.isHidden = false
                }
            }
            else {
                hasOrderView.isHidden = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (WebService.instance.authToken != "") {
            loadActiveOrders()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //////////////////////////////
    
    //  NavigationBar
    
    @IBAction func onCart(_ sender: AnyObject) {
        if (CartManager.instance.getCartItemCount() == 0) {
            Util.showAlertMessage(APP_TITLE, message: "Your cart is empty now.", parent: self)
            return
        }
        
        userDefaults.set(true, forKey: "checkCart")
        let receiptViewController = storyboard!.instantiateViewController(withIdentifier: "ReceiptViewController") as! ReceiptViewController
        navigationController!.pushViewController(receiptViewController, animated: true)
    }
    
    //////////////////////////////
    
    @IBAction func onAccountSetup(_ sender: AnyObject) {
        let accountSetupViewController = storyboard!.instantiateViewController(withIdentifier: "AccountSetupViewController") as! AccountSetupViewController
        accountSetupViewController.navigationType = 1
        navigationController!.pushViewController(accountSetupViewController, animated: true)
    }

    //////////////////////////////
    
    func updateCartCount(_ count: Int) {
        if (count == 0) {
            cartItemCount.text = ""
        }
        else {
            cartItemCount.text = String(count)
        }
        subTotal.text = "$" + String(format: "%.2f", CartManager.instance.totalPrice)
    }
    
    @IBAction func onActiveOrders(_ sender: AnyObject) {
        activeButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 13.0)
        activeButton.setTitleColor(UIColor.eazyoBlackColor(), for: UIControlState())
        historyButton.titleLabel?.font = UIFont(name: "OpenSans", size: 13.0)
        historyButton.setTitleColor(UIColor.eazyoOrangeColor(), for: UIControlState())
        activeOrdersTable.isHidden = false
        orderHistoryTable.isHidden = true
        
        orderIndicatorXConstraint.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
            }, completion: {(completed: Bool) -> Void in
                
        })
    }
    
    @IBAction func onHistoryOrders(_ sender: AnyObject) {
        activeButton.titleLabel?.font = UIFont(name: "OpenSans", size: 13.0)
        activeButton.setTitleColor(UIColor.eazyoOrangeColor(), for: UIControlState())
        historyButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 13.0)
        historyButton.setTitleColor(UIColor.eazyoBlackColor(), for: UIControlState())
        activeOrdersTable.isHidden = true
        orderHistoryTable.isHidden = false
        
        orderIndicatorXConstraint.constant = 57
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
            }, completion: {(completed: Bool) -> Void in
                
        })
    }
    
    @IBAction func onCheckOrderStatus(_ sender: AnyObject) {
        orderIcon.image = nil
        orderCode.text = ""
        userDefaults.set(true, forKey: "checkOrder")
        hasOrderView.isHidden = true
        hasOrder = false
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            return SlideAnimator(slideType: SLIDE_UP_PUSH)
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return nil
        }
        
        return nil
    }
    
    //////////////////////////////
    
    func loadActiveOrders() {
        loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        loadingAnimator!.mode = .indeterminate
        loadingAnimator!.labelText = "Loading..."
        WebService.instance.delegate = self
        WebService.instance.getActiveOrders()
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        switch apiName {
        case "getActiveOrders":
            activeOrderData = data as? [[String : Any]]
            activeOrdersTable.reloadData()
            let activeOrderCount = activeOrderData!.count
            let tabBarItem = tabBarController!.tabBar.items![1]
            
            if (activeOrderCount > 0) {
                tabBarItem.setCustomBadgeValue(String(describing: activeOrderCount), with: UIFont(name: "OpenSans-Semibold", size: 11), andFontColor: UIColor.white, andBackgroundColor: UIColor.eazyoBlackColor())
                orderedItemImages!.removeAll()
                imageFlags!.removeAll()
                for _ in 1...activeOrderCount {
                    orderedItemImages!.append(UIImage())
                    imageFlags!.append(false)
                }
                
                let hasNotification = userDefaults.bool(forKey: "hasNotification")
                if (hasNotification) {
                    let orderUuid = userDefaults.string(forKey: "orderUuid")
                    for activeOrder in activeOrderData!{
                        if (orderUuid == activeOrder["uuid"] as? String) {
                            loadingAnimator!.hide(true)
                            let orderDetailViewController = storyboard!.instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
                            orderDetailViewController.orderDetail = activeOrder
                            navigationController!.pushViewController(orderDetailViewController, animated: true)
                        }
                    }
                    
                    userDefaults.setValue("", forKey: "orderUuid")
                    userDefaults.set(false, forKey: "hasNotification")
                }
            }
            else {
                tabBarItem.badgeValue = nil
            }
            
            WebService.instance.getOrderHistory()
            break
        case "getOrderHistory":
            loadingAnimator!.hide(true)
            orderHistoryData = data as? [[String : Any]]
            orderHistoryTable.reloadData()
            
            if (hasOrder && lastOrder != nil) {
                let transactionNotes = lastOrder!["transaction_notes"] as? String
                if (transactionNotes != nil && transactionNotes != "") {
                    Util.showAlertMessage("EazyO", message: transactionNotes!, parent: self)
                }
                hasOrder = false
            }
            
            let hasNotification = userDefaults.bool(forKey: "hasNotification")
            if (hasNotification) {
                let orderUuid = userDefaults.string(forKey: "orderUuid")
                for deliveredOrder in orderHistoryData! {
                    if (orderUuid == deliveredOrder["uuid"] as? String) {
                        let orderDetailViewController = storyboard!.instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
                        orderDetailViewController.orderDetail = deliveredOrder
                        navigationController!.pushViewController(orderDetailViewController, animated: true)
                    }
                }
            }
            userDefaults.set(false, forKey: "hasNotification")
            break
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "getActiveOrders":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
        case "getOrderHistory":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if (tabBarController.selectedIndex == 1) {
            
        }
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 0) {
            if (activeOrderData != nil) {
                return (activeOrderData?.count)!
            }
        }
        else {
            if (orderHistoryData != nil) {
                return (orderHistoryData?.count)!
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var order: [String : Any]
        if (tableView.tag == 0) {
            order = activeOrderData![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveOrderCell", for: indexPath) as! ActiveOrderCell
            let status = (order["status"] as! [String : Any])["name"] as! String
            cell.backgroundImage.backgroundColor = colorDictionary[status]
            
            let orderedItemImageUrl = order["confirmation_icon_url"] as? String
            if (orderedItemImages![indexPath.row].size.height == 0) {
                if (orderedItemImageUrl != nil) {
                    if (imageFlags![indexPath.row] == false) {
                        imageFlags![indexPath.row] = true
                        Alamofire.request(orderedItemImageUrl!)
                            .responseImage { response in
                                if let image = response.result.value {
                                    cell.itemImage.image = image
                                    self.orderedItemImages![indexPath.row] = image
                                    self.activeOrdersTable.reloadData()
                                }
                        }
                    }
                }
            }
            else {
                cell.itemImage.image = orderedItemImages![indexPath.row]
            }
            
            cell.categoryInfo.text = order["item_summary"] as? String
            cell.status.backgroundColor = colorDictionary[status]
            cell.status.text = statusDictionary[status]
            
            cell.selectionStyle = .none
            return cell
        }
        else {
            order = orderHistoryData![indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell", for: indexPath) as! OrderHistoryCell
            cell.categoryInfo.text = order["item_summary"] as? String
            
            let dateInFormat = dateFormatter.date(from: order["order_time"] as! String)
            cell.status.text = timeText(now!.timeIntervalSince(dateInFormat!))
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderDetailViewController = storyboard!.instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
        if (tableView.tag == 0) {
            orderDetailViewController.orderDetail = activeOrderData![indexPath.row]
            orderDetailViewController.orderedItemImage = orderedItemImages![indexPath.row]
        }
        else {
            orderDetailViewController.orderDetail = orderHistoryData![indexPath.row]
        }
        navigationController!.pushViewController(orderDetailViewController, animated: true)
    }
    
    //////////////////////////////
    
    func timeText(_ interval: TimeInterval) -> String {
        if (interval >= 8 * 24 * 60 * 60) {
            return "1+ Weeks ago"
        }
        else if (interval >= 7 * 24 * 60 * 60) {
            return "1 Week ago"
        }
        else if (interval >= 2 * 24 * 60 * 60) {
            return String(Int(interval / (24 * 60 * 60))) + " Days ago"
        }
        else if (interval >= 1 * 24 * 60 * 60) {
            return "1 Day ago"
        }
        else if (interval >= 2 * 60 * 60) {
            return String(Int(interval / (60 * 60))) + " Hours ago"
        }
        else if (interval >= 1 * 60 * 60) {
            return "1 Hour ago"
        }
        else if (interval >= 2 * 60) {
            return String(Int(interval / 60)) + " Minutes ago"
        }
        else if (interval >= 60) {
            return "1 Minute ago"
        }
        else if (interval >= 2) {
            return String(Int(interval)) + " Seconds ago"
        }
        else {
            return "1 Second ago"
        }
    }
    
    //////////////////////////////
}
