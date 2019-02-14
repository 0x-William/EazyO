//
//  VenueMenuViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/7/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD
import Alamofire
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class VenueMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, WebServiceDelegate, iCarouselDataSource, iCarouselDelegate {

    @IBOutlet weak var averageWaitTime: UILabel!
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var cartItemCount: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var cartScreen: UIView!
    @IBOutlet weak var bigCartCount: UILabel!
    @IBOutlet weak var emptyMenuScreen: UIView!
    
    var loadingAnimator: MBProgressHUD?
    
    var parameters = [String : Any]()
    
    var isAddedItem: Bool = false
    
    var venueInfo: [String : Any]?
    var venueName = "Venue"
    var menuData: [String : Any]?
    var categories: [[String : Any]]?
    var featuredItems: [[String : Any]]?
    
    var featuredImages: [UIImage]?
    var imageFlags: [Bool]?
    var mapData: [[String : Any]]?
    var loadedMapCount: Int = 0
    var timer: Timer?
    let width = UIScreen.main.bounds.width
    var navigationType: Int = 0
    var currentCarouselIndex: Int = 0
    
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        isAddedItem = false
        if (venueInfo != nil) {
            venueName = venueInfo!["name"] as? String ?? "Venue"
            venueTitle.text = venueName
            
            ReceiptManager.instance.serviceFeeType = venueInfo!["service_fee_type"] as? String
            if (ReceiptManager.instance.serviceFeeType == "tiered") {
                let tiers = venueInfo!["service_fee_tiers"] as? [AnyObject]
                if (tiers != nil && tiers?.count > 0) {
                    for tier in tiers! {
                        let minRange = tier["min_range"] as! Float
                        let maxRange = tier["max_range"] as? Float
                        let price = (tier["price"] as! NSString).floatValue
                        ReceiptManager.instance.serviceFeeTiers.append(ServiceFeeTier(min: minRange, max: maxRange, p: price))
                    }
                }
            }
            
            featuredImages = [UIImage]()
            imageFlags = [Bool]()
        }
        
        let membership_type = venueInfo!["membership_type"] as! String
        VendorManager.instance.isPrivate = membership_type == "private_club" ? true : false
        print(VendorManager.instance.isPrivate)
        
        userDefaults.set(false, forKey: "hideMapTip")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController!.tabBar.isHidden = false
        navigationController!.delegate = self
        let orderedItemCount = CartManager.instance.getOrderedItemCount()
        updateCartCount(orderedItemCount)
        
        let checkCart = userDefaults.bool(forKey: "checkCart")
        
        if (!checkCart && isAddedItem && CartManager.instance.getCartItemCount() != 0) {
            cartScreen.alpha = 1.0
        }
        else {
            cartScreen.alpha = 0.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (VendorManager.instance.isMenuLoaded == false) {
            featuredImages!.removeAll()
            imageFlags!.removeAll()
            
            loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
            loadingAnimator!.mode = .text
            loadingAnimator!.labelText = "Loading Menu..."
            
            parameters["location_uuid"] = VendorManager.instance.placeInfo!.uuid!
            
            WebService.instance.delegate = self
            WebService.instance.getMenu(parameters)
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
    
    @IBAction func onLocation(_ sender: AnyObject) {
        //check cart to make sure its empty
        if(CartManager.instance.getCartItemCount() == 0)
        {
            self.goBackToLocations()
        }
        else {
            //if not, then prompt user to agree to wipe cart
            Util.showAlertMessageWithCancel(APP_TITLE, message: "This action will empty your current cart, are you sure?", parent: self) {
                _ = CartManager.instance.clearCart()
                self.goBackToLocations()
            }
        }
    }
    
    func goBackToLocations(){
        self.tabBarController!.navigationController!.popViewController(animated: true)
        ReceiptManager.instance.clearReceiptData()
    }
    
    @IBAction func onCart(_ sender: AnyObject) {
        if (CartManager.instance.getCartItemCount() == 0) {
            Util.showAlertMessage(APP_TITLE, message: "Your cart is empty now.", parent: self)
            return
        }
        
        userDefaults.set(true, forKey: "checkCart")
        navigationType = 1
        let receiptViewController = storyboard!.instantiateViewController(withIdentifier: "ReceiptViewController") as! ReceiptViewController
        navigationController!.pushViewController(receiptViewController, animated: true)
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return nil
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        switch apiName {
        case "getMenu":
            let dataObject = data as! [String : Any]
            menuData = dataObject
            VendorManager.instance.menu = menuData
            categories = menuData!["categories"] as? [[String : Any]]
            featuredItems = menuData!["featured_items"] as? [[String : Any]]
            VendorManager.instance.isMenuLoaded = true
            
            let isOpen = menuData!["is_open"] as! Bool
            if (isOpen == false) {
                self.loadingAnimator!.hide(true)
                emptyMenuScreen.isHidden = false
                averageWaitTime.text = "Currently Unavailable"
            }
            else {
                let waitTime = venueInfo!["wait_time"] as! Int
                var waitText = "Food wait: \(waitTime) Min"
                if (waitTime > 1) {
                    waitText = waitText + "s"
                }
                waitText = waitText + "   Drinks: ASAP"
                
                let attributedString = NSMutableAttributedString(string: waitText)
                let range = NSRange(location: 11, length: waitText.characters.count - 24)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Bold", size: 10)!, range: range)
                let drinkBoldRange = NSRange(location: waitText.characters.count - 4, length: 4)
                attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "OpenSans-Bold", size: 10)!, range: drinkBoldRange)
                
                
                averageWaitTime.attributedText = attributedString
                
                emptyMenuScreen.isHidden = true
                
                if (featuredItems != nil) {
                    featuredImages!.removeAll()
                    imageFlags!.removeAll()
                    for _ in featuredItems! {
                        featuredImages!.append(UIImage())
                        imageFlags!.append(false)
                    }
                    if (featuredImages!.count > 1) {
                        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(VenueMenuViewController.scrollFeatureItem), userInfo: nil, repeats: true)        
                    }
                }
                menuTableView.reloadData()
                loadingAnimator!.hide(true)
                showDiscountAlert()
                
                let promotions = menuData!["promotions"] as? [[String : Any]]
                if (promotions != nil && promotions!.count > 0) {
                    print("You have promotions!")
                    let promotionViewController = storyboard!.instantiateViewController(withIdentifier: "PromotionViewController") as! PromotionViewController
                    promotionViewController.modalPresentationStyle = .overCurrentContext
                    promotionViewController.promotionData = promotions
                    tabBarController!.present(promotionViewController, animated: false, completion: nil)
                    
                    let foodItemData = promotions![0]["item"] as! [String : Any]
                    let categoryName = CartManager.instance.getCategoryName(uuid: foodItemData["uuid"] as! String)
                    let promotionItem = CartItem(itemData: foodItemData, categoryName: categoryName, itemImage: UIImage())
                    promotionItem.isPromotion = true
                    promotionItem.promotionUuid = promotions![0]["uuid"] as! String
                    updateCartCount(CartManager.instance.addToCart(promotionItem))
                }
            }
            mainView.isHidden = false
            break
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "getMenu":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    func showDiscountAlert() {
        if (ReceiptManager.instance.discountPercent != 0.0 && !VendorManager.instance.suppressDiscount) {
            let discountMessage = "Welcome to \(venueName), your \(ReceiptManager.instance.discountPercent!)% discount is applied to all orders."
            Util.showAlertMessage(APP_TITLE, message: discountMessage, parent: self)
        }
    }
    
    func checkSum() -> Int {
        loadedMapCount = loadedMapCount + 1
        return loadedMapCount
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 0) {
            if (menuData == nil) {
                return 0
            }
            
            return 1 + Int(ceil((Float)(categories!.count) / 2))
        }
        else {
            return VendorManager.instance.hoursOfOperation.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView.tag == 0) {
            if (indexPath.row == 0) {
                return 328.0
            }
            else {
                return 60.0
            }
        }
        else {
            return 28.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.tag == 0) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
                cell.itemCount = featuredItems!.count
                if (cell.itemCount < 2) {
                    cell.featureCarouselView.isScrollEnabled = false
                }
                cell.makeIndicatorUI(currentCarouselIndex)
                cell.selectionStyle = .none
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
                cell.firstCategoryName.text = categories![(indexPath.row - 1) * 2]["name"] as? String
                cell.firstButton.tag = (indexPath.row - 1) * 2
                
                if (indexPath.row * 2 - 1 < categories!.count) {
                    cell.secondCategoryName.text = categories![indexPath.row * 2 - 1]["name"] as? String
                    cell.secondButton.tag = indexPath.row * 2 - 1
                    cell.secondCategoryView.isHidden = false
                }
                else {
                    cell.secondCategoryView.isHidden = true
                }
                cell.selectionStyle = .none
                
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTimeCell", for: indexPath) as! MenuTimeCell
            cell.selectionStyle = .none
            let weekDay = VendorManager.instance.weekDays[indexPath.row]
            cell.weekDay.text = weekDay
            cell.time.text = VendorManager.instance.hoursOfOperation[weekDay]
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = UIColor.white
            }
            else {
                cell.backgroundColor = UIColor.init(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 240.0 / 255.0, alpha: 0.5)
            }
            
            return cell
        }
    }
    
    @IBAction func onCategoryItem(_ sender: AnyObject) {
        navigationType = 0
        let button = sender as! UIButton
        let index = button.tag
        let categoryMenuViewController = storyboard!.instantiateViewController(withIdentifier: "CategoryMenuViewController") as! CategoryMenuViewController
        categoryMenuViewController.categoryData = categories![index]
        navigationController!.pushViewController(categoryMenuViewController, animated: true)
    }
    
    //////////////////////////////
    
    //  iCarouselDelegate
    
    func numberOfItems(in carousel: iCarousel) -> Int
    {
        return featuredItems!.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView
    {
        var itemView: MenuItem
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            itemView = MenuItem.instanceFromNib() as MenuItem
//            itemView.hud = MBProgressHUD.showHUDAddedTo(itemView.loadingView, animated: true)
//            itemView.hud?.yOffset = -23.0
//            itemView.hud?.color = UIColor.clearColor()
//            itemView.hud?.activityIndicatorColor = UIColor.eazyoOrangeColor()
//            itemView.hud?.mode = .AnnularDeterminate
            itemView.frame = CGRect(x: 0, y: 0, width: width - 18, height: 288)
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view as! MenuItem
        }
        
        itemView.name.text = featuredItems![index]["name"] as? String
        itemView.info.text = featuredItems![index]["description"] as? String
        let price = featuredItems![index]["price"] as? String
        let floatPrice = Float(price!)
        itemView.price.text = "$" + Util.stringWithPlaceCount(floatPrice!, placeCount: 2)
        
        if (featuredImages![index].size.height == 0) {
            if let imageUrl = featuredItems![index]["image_url"] as? String {
//                itemView.hud?.show(false)
                itemView.loadingView.isHidden = false
                itemView.image.image = nil
                if (imageFlags![index] == false) {
                    imageFlags![index] = true
                    Alamofire.request(imageUrl)
//                        .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//                            DispatchQueue.main.async {
//                                let progress = Float(totalBytesRead) / Float(totalBytesExpectedToRead)
//                                itemView.hud?.progress = progress
//                                print(progress)
//                            }
//                        }
                        .responseImage { response in
                            if let image = response.result.value {
                                itemView.image.image = image
                                self.featuredImages![index] = image
                            }
//                            itemView.hud?.hide(false)
                            itemView.loadingView.isHidden = true
                    }
                }
            }
            else {
                itemView.hud?.hide(false)
                itemView.loadingView.isHidden = true
                itemView.image.image = featuredImages![index]
            }
        }
        else {
            itemView.image.image = featuredImages![index]
            itemView.hud?.hide(false)
            itemView.loadingView.isHidden = true
        }
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .spacing)
        {
            return value * 1.027
        }
        if (option == .wrap) {
            return 1.0
        }
        
        return value
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        currentCarouselIndex = carousel.currentItemIndex
        menuTableView.reloadData()
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        navigationType = 1
        let foodDetailViewController = storyboard!.instantiateViewController(withIdentifier: "FoodDetailViewController") as! FoodDetailViewController
        let featureItem = featuredItems![index]
        let categoryName = CartManager.instance.getCategoryName(uuid: featureItem["uuid"] as! String)
        foodDetailViewController.oriItem = CartItem(itemData: featureItem, categoryName: categoryName, itemImage: featuredImages![index])
        navigationController!.pushViewController(foodDetailViewController, animated: true)
    }
    
    //////////////////////////////
    
    func scrollFeatureItem() {
        let menuCell = menuTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MenuCell
        if (menuCell != nil) {
            menuCell!.scrollToNextView()
        }
    }
    
    //////////////////////////////
    
    @IBAction func onContinueOrdering(_ sender: AnyObject) {
        userDefaults.set(true, forKey: "checkCart")
        cartScreen.alpha = 1.0
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            self.cartScreen.alpha = 0.0
            }, completion: {(completed: Bool) -> Void in
                self.cartScreen.alpha = 0.0
        })
        isAddedItem = false
    }
    
    func updateCartCount(_ count: Int) {
        if (count == 0) {
            cartItemCount.text = ""
            bigCartCount.text = ""
        }
        else {
            cartItemCount.text = String(count)
            bigCartCount.text = String(count)
        }
        subTotal.text = "$" + String(format: "%.2f", CartManager.instance.totalPrice)
    }
    
    //////////////////////////////
}
