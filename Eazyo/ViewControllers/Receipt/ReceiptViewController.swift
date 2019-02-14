//
//  ReceiptViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/23/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreLocation
import PassKit
import Braintree
import MBProgressHUD
import SWTableViewCell

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

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class ReceiptViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIWebViewDelegate, CLLocationManagerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, PKPaymentAuthorizationViewControllerDelegate, AddPaymentDelegate, SWTableViewCellDelegate, WebServiceDelegate {
    
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapWebView: UIWebView!
    @IBOutlet weak var roomServiceView: UIView!
    @IBOutlet weak var roomNumber: UITextField!
    @IBOutlet weak var pickupView: UIView!
    @IBOutlet weak var pickupImage: UIImageView!
    @IBOutlet weak var pickupPlaceholderImage: UIImageView!
    @IBOutlet weak var pickupTitle: UILabel!
    @IBOutlet weak var pickupDescription: UITextView!
    
    @IBOutlet weak var cartTable: UITableView!
    @IBOutlet weak var myOrderTable: UITableView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    
    @IBOutlet weak var reviewDiscount: UILabel!
    @IBOutlet weak var reviewSubTotal: UILabel!
    
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var taxLevel: UILabel!
    @IBOutlet weak var taxCost: UILabel!
    
    @IBOutlet weak var serviceLevel: UILabel!
    @IBOutlet weak var serviceCost: UILabel!
    
    @IBOutlet weak var secondaryChargeText: UILabel!
    @IBOutlet weak var secondaryCharge: UILabel!
    @IBOutlet weak var secondaryChargeView: UIView!
    
    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var tipButton: UIButton!
    @IBOutlet weak var tipCost: UILabel!
    @IBOutlet weak var tipView: UIView!
    
    @IBOutlet weak var totalCost: UILabel!
    
    @IBOutlet weak var applePayButtonBackground: UIView!
    
    @IBOutlet weak var hightlightViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondaryChargeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var orderButtonHeightConstraint: NSLayoutConstraint!
    
    var applePaySetupButton, applePayBuyButton: UIButton?
    
    var braintreeClient: BTAPIClient?
    var locationManager: CLLocationManager?
    var request: URLRequest?
    
    var authenticated = false
    var gotPosition: Bool = false
    var lat = 0.0
    var long = 0.0
    var bLoad = true
    
    var currentMap: String?
    let tipLevelDataSource = ReceiptManager.instance.tipValues
    var tipIndex = 3
    var tipPrice: Float = 0.0
    var totalPrice: Float = 0.0
    var applePayNonce = ""
    
    var loadingAnimator: MBProgressHUD?
    var navigationType: Int = 0
    var isLoggedIn: Bool?
    var payWithApple: Bool = false
    
    let userDefaults = UserDefaults.standard
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    var deliveryCellHeight: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateApplePayStatus), name:NSNotification.Name(rawValue: "updateApplePayStatus"), object: nil)
        
        if (ReceiptManager.instance.defaultTip == 0) {
            tipIndex = 3
        }
        else {
            for (index, tipValue) in ReceiptManager.instance.tipValues.enumerated() {
                if tipValue == ReceiptManager.instance.defaultTip {
                    tipIndex = index
                }
            }
        }
        
        tabBarController!.tabBar.isHidden = true
        
        if (!VendorManager.instance.suppressDiscount) {
            reviewDiscount.text = "(" + String(ReceiptManager.instance.discountPercent) + "% Discount applied)"
        }
        
        var bottomViewHeight: CGFloat = 141
        
        tipButton.isEnabled = ReceiptManager.instance.acceptTips
        tipView.isHidden = !ReceiptManager.instance.acceptTips
        if (ReceiptManager.instance.acceptTips == true) {
            tipViewHeightConstraint.constant = 20
            bottomViewHeight = 161
        }
        else {
            tipViewHeightConstraint.constant = 0
        }
        
        secondaryChargeView.isHidden = !VendorManager.instance.hasSecondaryServiceFee
        if (VendorManager.instance.hasSecondaryServiceFee) {
            secondaryChargeViewHeightConstraint.constant = 20
            bottomViewHeight = bottomViewHeight + 20
        }
        else {
            secondaryChargeViewHeightConstraint.constant = 0
        }
        
        bottomViewHeightConstraint.constant = bottomViewHeight
        
        if (ReceiptManager.instance.discountPercent != 0.0 && !VendorManager.instance.suppressDiscount) {
            discount.text = "(" + String(ReceiptManager.instance.discountPercent) + "% Discount applied)"
        }
        
        if (Util.checkApplePay() > 0) {
            applePaySetupButton = PKPaymentButton(type: PKPaymentButtonType.setUp, style: PKPaymentButtonStyle.black)
            applePaySetupButton!.addTarget(self, action: #selector(ReceiptViewController.onApplePaySetup), for: .touchUpInside)
            applePaySetupButton!.frame = CGRect(x: 0, y: 1, width: width, height: 56)
            applePayButtonBackground.addSubview(applePaySetupButton!)
            
            applePayBuyButton = PKPaymentButton(type: PKPaymentButtonType.buy, style: PKPaymentButtonStyle.black)
            applePayBuyButton!.addTarget(self, action: #selector(ReceiptViewController.onApplePayBuy), for: .touchUpInside)
            applePayBuyButton!.frame = CGRect(x: 0, y: 1, width: width, height: 56)
            applePayBuyButton!.isHidden = true
            applePayButtonBackground.addSubview(applePayBuyButton!)
        }
        
        tipLabel.text = " " + VendorManager.instance.tipLabel + " "
        tipLabel.layoutIfNeeded()
        
        if (VendorManager.instance.locationType == "delivery")
        {
            mapView.isHidden = false
            loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingAnimator!.mode = .text
            loadingAnimator!.labelText = "Loading..."
            
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.delegate = self
            locationManager?.startUpdatingLocation()
        }
        else if (VendorManager.instance.locationType == "room_service") {
            roomServiceView.isHidden = false
            
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 40))
            doneToolbar.barStyle = UIBarStyle.blackTranslucent
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(closeKeyboard))
            doneToolbar.items = [flexSpace, done]
            doneToolbar.sizeToFit()
            
            roomNumber.inputAccessoryView = doneToolbar
        }
        else {
            pickupView.isHidden = false
            let pickupInfo = VendorManager.instance.placeInfo
            if (pickupInfo == nil) {
                pickupPlaceholderImage.isHidden = false
            }
            else {
                if (pickupInfo!.imageURL == nil) {
                    pickupPlaceholderImage.isHidden = false
                }
                else {
                    Alamofire.request(pickupInfo!.imageURL!).responseImage { response in
                        if let image = response.result.value {
                            self.pickupImage.image = image
                        }
                    }
                }
                pickupTitle.text = pickupInfo!.name
                pickupDescription.text = pickupInfo!.description
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
        
        calculatePrice()
        if (WebService.instance.authToken == "") {
            isLoggedIn = false
            loginButtonHeightConstraint.constant = 46
            orderButtonHeightConstraint.constant = 0
        }
        else {
            isLoggedIn = true
            loginButtonHeightConstraint.constant = 0
            if (Util.checkApplePay() > 0 && CardManager.instance.getSelectedCardIndex() + 1 == CardManager.instance.getCardCount() + Util.checkApplePay()) {
                showApplePay(show: true)
            }
            else {
                showApplePay(show: false)
            }
        }
        
        if (ReceiptManager.instance.acceptTips == false) {
            loginButtonBottomConstraint.constant = 10
        }
        else {
            loginButtonBottomConstraint.constant = -10
        }
        
        loginButton.isHidden = isLoggedIn!
        cartTable.reloadData()
        myOrderTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
    
    @IBAction func onClose(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    //////////////////////////////
    
    //  CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        loadingAnimator!.hide(false)
        if (locations.count > 0) {
            if(!gotPosition) {
                locationManager!.stopUpdatingLocation()
                gotPosition = true
                
                var baseUrl = ""
                
                #if PRODUCTION
                    lat = locations.last!.coordinate.latitude
                    long = locations.last!.coordinate.longitude
                    baseUrl = "https://app.eazyoapp.com"
                #else
                    lat = 25.79627
                    long = -80.126216
                    baseUrl = "http://staging.eazyoapp.com"
                #endif
                
                let urlString = "\(baseUrl)/map/\(VendorManager.instance.vendorUuid)?lat=\(lat)&long=\(long)&confirm_location=true&os=ios"
                let url = URL(string: urlString)
                request = URLRequest(url: url!)
                mapWebView.loadRequest(request!)
            }
        }
        else {
            showLocationNotFoundMessage("Cannot track your location.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loadingAnimator!.hide(false)
        showLocationNotFoundMessage("Cannot track your location.")
    }
    
    func showLocationNotFoundMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            //            self.startLocationTracking()
        }
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    //////////////////////////////
    
    func onConfirmLocationWithUrl(path: String?) {
        if (path == nil) {
            Util.showAlertMessage("EazyO", message: "Cannot get location data.", parent: self)
            return
        }
        
        let locationData = path!.substring(from: path!.index(path!.startIndex, offsetBy: 10))
        print(locationData)
        let dataArray = locationData.components(separatedBy: "/")
        if (dataArray.count > 5) {
            let longitude = CGFloat((dataArray[1] as NSString).floatValue)
            let latitude = CGFloat((dataArray[3] as NSString).floatValue)
            let overlay = dataArray[5]
            VendorManager.instance.setUserMapData(latitude,
                                                  longitude: longitude, overlay: overlay)
            confirmButton.isEnabled = true
            moveToConfirmPage()
        }
        else {
            Util.showAlertMessage("EazyO", message: "Incorrect location data.", parent: self)
            return
        }
    }
    
    //////////////////////////////
    
    //  UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url
        let scheme = url?.scheme ?? ""
        if (scheme == "details") {
            onConfirmLocationWithUrl(path: url?.absoluteString)
            return true
        }
        
        #if PRODUCTION
            authenticated = true
        #endif
        
        if (!authenticated) {
            _ = NSURLConnection(request: request, delegate: self, startImmediately: true)
            return false
        }
        return true
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
    
    //////////////////////////////
    
    //  NSURLConnectionDelegate
    
    func connection(_ connection: NSURLConnection, didReceive challenge: URLAuthenticationChallenge) {
        if challenge.previousFailureCount == 0 {
            authenticated = true
            let credential = URLCredential(user: "eazyo", password: "L0ngb0ard", persistence: URLCredential.Persistence.forSession)
            challenge.sender?.use(credential, for: challenge)
        } else {
            challenge.sender?.cancel(challenge)
        }
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        mapWebView.loadRequest(request!)
    }
    
    func connectionShouldUseCredentialStorage(_ connection: NSURLConnection) -> Bool {
        return false
    }
    
    //////////////////////////////
    
    @IBAction func onPlaceOrder(_ sender: AnyObject) {
        payWithApple = false
        updateUser()
    }
    
    func updateUser() {
        var parameters = [String : Any]()
        parameters["phone_number"] = UserManager.instance.phoneNumber!
        
        loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
        loadingAnimator!.mode = .text
        loadingAnimator!.labelText = "Updating..."
        WebService.instance.delegate = self
        WebService.instance.updateUser(parameters)
    }
    
    func placeOrder(withApplePay: Bool) {
        if (VendorManager.instance.locationType == "delivery" && (ReceiptManager.instance.additionalInfo == nil || ReceiptManager.instance.additionalInfo!.trimmingCharacters(in: .whitespaces) == "")) {
            loadingAnimator?.hide(true)
            Util.showAlertMessage(APP_TITLE, message: "Description cannot be blank for the delivery orders.", parent: self)
            return
        }
        
        loadingAnimator!.labelText = "Placing order..."
        
        var parameters = [String : Any]()
        parameters["vendor_uuid"] = VendorManager.instance.vendorUuid
        parameters["location_uuid"] = VendorManager.instance.placeInfo!.uuid!
        parameters["notes"] = ReceiptManager.instance.additionalInfo
        
        if(VendorManager.instance.locationType == "delivery")
        {
            if (VendorManager.instance.mapOverlay != nil) {
                parameters["map_latitude"] = VendorManager.instance.mapLatitude.description
                parameters["map_longitude"] = VendorManager.instance.mapLongitude.description
                parameters["map_overlay_uuid"] = VendorManager.instance.mapOverlay!
            }
        }
        else if (VendorManager.instance.locationType == "room_service") {
            parameters["room_number"] = ReceiptManager.instance.roomNumber
        }
        
        if (withApplePay == true) {
            parameters["payment_type"] = "APPLE_PAY"
            parameters["payment_nonce"] = applePayNonce
        }
        else {
            if (CardManager.instance.getSelectedCardIndex() != -1) {
                if (UserManager.instance.isManager && CardManager.instance.getSelectedCardIndex() == CardManager.instance.getCardCount() + Util.checkApplePay()) {
                    parameters["payment_type"] = "MANAGER_COMP"
                }
                else if (CardManager.instance.getSelectedCardIndex() < CardManager.instance.getCardCount()) {
                    let defaultCard = CardManager.instance.getSelectedCard()
                    parameters["card_uuid"] = defaultCard["uuid"] as! String
                    parameters["payment_type"] = "CARD"
                }
                else {
                    
                }
            }
        }
        
        if (UserManager.instance.memberCode != nil) {
            parameters["code"] = UserManager.instance.memberCode as AnyObject?
        }
        
        var itemsArray: [[String : Any]] = []
        for i in 0...CartManager.instance.getCartItemCount() - 1 {
            var cartDictionary = [String : Any]()
            let cartItem = CartManager.instance.getItem(i)
            cartDictionary["uuid"] = cartItem!.data!["uuid"] as! String
            if (cartItem!.isPromotion) {
                cartDictionary["promo_uuid"] = cartItem!.promotionUuid
            }
            cartDictionary["quantity"] = cartItem!.count
            cartDictionary["notes"] = cartItem!.extraInfo
            
            if (cartItem!.selectedOptions.count > 0) {
                var options: [String] = []
                for option in cartItem!.selectedOptions {
                    options.append(option.data["uuid"] as! String)
                }
                cartDictionary["options"] = options
            }
            
            if (cartItem!.additionalSides.count > 0) {
                var sides: [String] = []
                for j in 0...cartItem!.additionalSides.count - 1 {
                    sides.append(cartItem!.additionalSides[j].data["uuid"] as! String)
                }
                cartDictionary["sides"] = sides
            }
            
            itemsArray.append(cartDictionary)
        }
        parameters["items"] = itemsArray
        if (ReceiptManager.instance.acceptTips == true) {
            parameters["tip_amount"] = tipPrice
        }
        else {
            parameters["tip_amount"] = 0
        }
        
        print(parameters)
        
        WebService.instance.delegate = self
        WebService.instance.placeOrder(parameters)
    }
    
    //////////////////////////////
    
    @IBAction func onLogin(_ sender: AnyObject) {
        navigationType = 1
        let accountSetupViewController = storyboard!.instantiateViewController(withIdentifier: "AccountSetupViewController") as! AccountSetupViewController
        accountSetupViewController.navigationType = 0
        navigationController!.pushViewController(accountSetupViewController, animated: true)
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        switch apiName {
        case "updateUser":
            UserManager.instance.setUserData(data as! [String : Any])
            placeOrder(withApplePay: payWithApple)
            break
            
        case "placeOrder":
            loadingAnimator!.hide(true)
            let dataObject = data as! [String : Any]
            _ = CartManager.instance.clearCart()
            
            let secondNavigationController = tabBarController!.viewControllers![1] as! UINavigationController
            let ordersViewController = secondNavigationController.viewControllers[0] as! OrdersViewController
            ordersViewController.hasOrder = true
            ordersViewController.lastOrder = dataObject
            tabBarController!.selectedIndex = 1
            
            navigationController!.popToRootViewController(animated: false)
            break
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "updateUser":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        case "placeOrder":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            if (navigationType == 1) {
                navigationType = 0
                return SlideAnimator(slideType: SLIDE_UP_PUSH)
            }
            return nil
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return SlideAnimator(slideType: SLIDE_DOWN_POP)
        }
        
        navigationType = 0
        
        return nil
    }
    
    //////////////////////////////
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    @IBAction func onReview(_ sender: UIButton) {
        moveToReviewPage()
    }
    
    @IBAction func onLocation(_ sender: UIButton) {
        moveToLocationPage()
    }
    
    @IBAction func onConfirm(_ sender: UIButton) {
        moveToConfirmPage()
    }
    
    //////////////////////////////
    
    @IBAction func onSetLocation(_ sender: UIButton) {
        moveToLocationPage()
    }
    
    @IBAction func onConfirmRoomNumber(_ sender: UIButton) {
        if (roomNumber.text == nil || roomNumber.text!.characters.count == 0) {
            Util.showAlertMessage("EazyO", message: "Please enter the room number.", parent: self)
        }
        else {
            ReceiptManager.instance.roomNumber = roomNumber.text!
            confirmButton.isEnabled = true
            moveToConfirmPage()
        }
    }
    
    @IBAction func onConfirmPIckup(_ sender: UIButton) {
        confirmButton.isEnabled = true
        moveToConfirmPage()
    }
    
    func moveToReviewPage() {
        hightlightViewLeadingConstraint.constant = 5
        view.layoutIfNeeded()
        reviewLabel.textColor = UIColor.white
        reviewLabel.font = UIFont(name: "OpenSans-Bold", size: 14)
        locationLabel.textColor = UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1)
        locationLabel.font = UIFont(name: "OpenSans-Semibold", size: 14)
        confirmLabel.textColor = UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1)
        confirmLabel.font = UIFont(name: "OpenSans-Semibold", size: 14)
        mainScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func moveToLocationPage() {
        hightlightViewLeadingConstraint.constant = width * 1 / 3 + 2
        view.layoutIfNeeded()
        reviewLabel.textColor = UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1)
        reviewLabel.font = UIFont(name: "OpenSans-Semibold", size: 14)
        locationLabel.textColor = UIColor.white
        locationLabel.font = UIFont(name: "OpenSans-Bold", size: 14)
        confirmLabel.textColor = UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1)
        confirmLabel.font = UIFont(name: "OpenSans-Semibold", size: 14)
        mainScrollView.setContentOffset(CGPoint(x: width, y: 0), animated: true)
    }
    
    func moveToConfirmPage() {
        hightlightViewLeadingConstraint.constant = width * 2 / 3
        view.layoutIfNeeded()
        reviewLabel.textColor = UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1)
        reviewLabel.font = UIFont(name: "OpenSans-Semibold", size: 14)
        locationLabel.textColor = UIColor(red: 41 / 255, green: 41 / 255, blue: 41 / 255, alpha: 1)
        locationLabel.font = UIFont(name: "OpenSans-Semibold", size: 14)
        confirmLabel.textColor = UIColor.white
        confirmLabel.font = UIFont(name: "OpenSans-Bold", size: 14)
        mainScrollView.setContentOffset(CGPoint(x: width * 2, y: 0), animated: true)
    }
    
    //////////////////////////////
    
    //  AddPaymentDelegate
    
    func onAddNewCard() {
        CardManager.instance.setSelectedCardIndex(CardManager.instance.getCardCount() - 1)
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 0) {
            return CartManager.instance.getCartItemCount()
        }
        else {
            if (isLoggedIn == true) {
                return 1 + 2 + 1 + 1
            }
            else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView.tag == 0) {
            return 50
        }
        else {
            if (indexPath.row == 1 || indexPath.row == 1 + 2) {
                return 26
            }
            else if (indexPath.row == 1 + 1) {
                if (VendorManager.instance.locationType == "delivery") {
                    return deliveryCellHeight
                }
                else {
                    return 50
                }
            }
            else if (indexPath.row == 1 + 3) {
                return 50
            }
            else {
                return 50
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.tag == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemCell
            
            let cartItem = CartManager.instance.getItem(indexPath.row)
            cell.count.text = String(cartItem!.count)
            cell.name.text = cartItem!.data!["name"] as? String
            
            var floatPrice: Float = 0.0
            if (!cartItem!.isPromotion) {
                var optionPrice: Float = 0.0
                for option in cartItem!.selectedOptions {
                    if(option.data != nil)
                    {
                        optionPrice = optionPrice + Float(option.data["price"] as! String)!
                    }
                }
                
                let priceInString = (cartItem!.data!["price"] as? String)
                floatPrice = (Float(priceInString!)! + optionPrice) * Float(cartItem!.count)
            }
            
            cell.price.text = "$" + Util.stringWithPlaceCount(floatPrice, placeCount: 2)
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            
            let rightUtilityButtons = NSMutableArray()
            let deleteString: NSMutableAttributedString = NSMutableAttributedString(string: "Remove")
            deleteString.addAttribute(NSFontAttributeName,
                                      value: UIFont(
                                        name: "OpenSans-Bold",
                                        size: 13.0)!,
                                      range: NSRange(
                                        location: 0,
                                        length: 6))
            deleteString.addAttribute(NSForegroundColorAttributeName,
                                      value:UIColor.white,
                                      range: NSRange(location: 0, length: 6))
            
            rightUtilityButtons.sw_addUtilityButton(with: UIColor(red: 208.0 / 255, green: 37.0 / 255, blue: 37.0 / 255, alpha: 1.0), attributedTitle: deleteString)
            cell.rightUtilityButtons = rightUtilityButtons as [AnyObject]
            cell.delegate = self
            
            return cell
        }
        else {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell", for: indexPath) as! CartItemCell
                
                cell.name.text = CartManager.instance.getSummary()
                cell.price.text = "$" + Util.stringWithPlaceCount(totalPrice, placeCount: 2)
                cell.selectionStyle = .none
                
                return cell
            }
            else if (indexPath.row == 1 || indexPath.row == 1 + 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleCell", for: indexPath) as! SectionTitleCell
                if (indexPath.row == CartManager.instance.getCartItemCount()) {
                    cell.optionTitle.text = "Contact Info"
                }
                else {
                    cell.optionTitle.text = "Payment"
                }
                cell.selectionStyle = .none
                return cell
            }
            else if (indexPath.row == 1 + 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! DeliveryCell
                
                let phoneNumber = UserManager.instance.phoneNumber
                if (phoneNumber == nil || phoneNumber == "") {
                    cell.phoneNumber.text = "Phone Number"
                    cell.phoneNumber.font =  UIFont(name: "OpenSans-SemiboldItalic", size: 16.0)
                    cell.phoneNumber.textColor = UIColor.eazyoSilverColor()
                }
                else {
                    cell.phoneNumber.text = phoneNumber
                    cell.phoneNumber.font =  UIFont(name: "OpenSans-Semibold", size: 16.0)
                    cell.phoneNumber.textColor = UIColor.eazyoOrangeColor()
                }
                
                if (VendorManager.instance.locationType == "delivery") {
                    cell.descriptionView.isHidden = false
                    let additionalInfo = ReceiptManager.instance.additionalInfo
                    if (additionalInfo == nil || additionalInfo == "") {
                        cell.info.text = "Describe yourself, help us find you easily"
                        cell.info.font =  UIFont(name: "OpenSans-SemiboldItalic", size: 16.0)
                        cell.info.textColor = UIColor.eazyoSilverColor()
                    }
                    else {
                        cell.info.text = additionalInfo
                        cell.info.font =  UIFont(name: "OpenSans-Semibold", size: 16.0)
                        cell.info.textColor = UIColor.eazyoOrangeColor()
                    }
                }
                else {
                    cell.descriptionView.isHidden = true
                }
                
                cell.layoutIfNeeded()
                cell.sizeToFit()
                
                deliveryCellHeight = cell.mainView.frame.size.height
                
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
                
                if (CardManager.instance.getSelectedCardIndex() == -1) {
                    cell.cardView.isHidden = true
                    cell.addCardView.isHidden = false
                }
                else {
                    cell.cardView.isHidden = false
                    cell.addCardView.isHidden = true
                    
                    if (CardManager.instance.getSelectedCardIndex() < CardManager.instance.getCardCount()) {
                        let defaultCard = CardManager.instance.getSelectedCard()
                        cell.paymentName.text = defaultCard["description"] as! String + " ..." + (defaultCard["last4"] as! String)
                    }
                    else if (CardManager.instance.getSelectedCardIndex() >= CardManager.instance.getCardCount() + Util.checkApplePay() + Util.boolToInt(bool: UserManager.instance.isManager)) {
                        CardManager.instance.setSelectedCardIndex(-1)
                        cell.cardView.isHidden = true
                        cell.addCardView.isHidden = false
                    }
                    else if (CardManager.instance.getSelectedCardIndex() + 1 == CardManager.instance.getCardCount() + Util.checkApplePay()) {
                        cell.paymentName.text = "Apple Pay"
                    }
                    else if (CardManager.instance.getSelectedCardIndex() + 1 == CardManager.instance.getCardCount() + Util.checkApplePay() + Util.boolToInt(bool: UserManager.instance.isManager)) {
                        cell.paymentName.text = "Manager Comp"
                    }
                }
                
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.tag == 0) {
            if (indexPath.row < CartManager.instance.getCartItemCount()) {
                let foodDetailViewController = storyboard!.instantiateViewController(withIdentifier: "FoodDetailViewController") as! FoodDetailViewController
                foodDetailViewController.navigationType = 1
                foodDetailViewController.oriItem = CartManager.instance.getItem(indexPath.row)
                foodDetailViewController.cartIndex = indexPath.row
                navigationController!.pushViewController(foodDetailViewController, animated: true)
            }
        }
        if (tableView.tag == 1) {
            if (indexPath.row == 0) {
                moveToReviewPage()
            }
        }
    }
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        if (index == 0) {
            _ = CartManager.instance.removeFromCartWithIndex(cell.tag)
            cartTable.deleteRows(at: [IndexPath(row: cell.tag, section: 0)], with: .fade)
            calculatePrice()
            if (CartManager.instance.getCartItemCount() == 0) {
                for (_, viewController) in (navigationController!.viewControllers.enumerated()) {
                    if (viewController.isKind(of: VenueMenuViewController.self)) {
                        let venueMenuViewController = viewController as! VenueMenuViewController
                        venueMenuViewController.isAddedItem = false
                        navigationController!.popToViewController(venueMenuViewController, animated: true)
                        break
                    }
                }
            }
            else {
                cartTable.reloadData()
                myOrderTable.reloadData()
            }
        }
    }
    
    //////////////////////////////
    
    // Calcuate the price
    
    func calculatePrice() {
        var discountPercent = ReceiptManager.instance.discountPercent
        if (VendorManager.instance.suppressDiscount) {
            discountPercent = 0
        }
        
        totalPrice = round(CartManager.instance.getTotalPrice() * (1 - discountPercent! / 100) * 100) / 100
        var servicePrice: Float = 0
        var servicePercentString = ""

        if(ReceiptManager.instance.serviceFeeType == "pct") {
            servicePrice = round(totalPrice * Float(ReceiptManager.instance.serviceFee)) / 100
            servicePercentString = String(format: " (%.0f%%)", ReceiptManager.instance.serviceFee)//" (\(ReceiptManager.instance.serviceFee)%)"
        }
        else if(ReceiptManager.instance.serviceFeeType == "tiered") {
            for tier in ReceiptManager.instance.serviceFeeTiers {
                if (totalPrice >= tier.minRange && (tier.maxRange == nil || totalPrice <= tier.maxRange)) {
                    servicePrice = tier.price
                    break
                }
            }
        }
        
        var taxPrice: Float = 0
        if (ReceiptManager.instance.taxServiceFee == true) {
            taxPrice = round(totalPrice * Float(ReceiptManager.instance.tax) + servicePrice * ReceiptManager.instance.baseTax) / 100
        }
        else {
            taxPrice = round(totalPrice * Float(ReceiptManager.instance.tax)) / 100
        }
        
        reviewSubTotal.text = "$" + String(format: "%.2f", totalPrice)
        
        var secondaryServiceFee: Float = 0
        if (VendorManager.instance.hasSecondaryServiceFee) {
            secondaryChargeText.text = VendorManager.instance.secondaryServiceFeeLabel
            if (VendorManager.instance.secondaryServiceFeeType.contains("pct")) {
                secondaryServiceFee = round(totalPrice * VendorManager.instance.secondaryServiceFee) / 100
                secondaryChargeText.text = VendorManager.instance.secondaryServiceFeeLabel + String(format: " (%.0f%%)", VendorManager.instance.secondaryServiceFee)
            }
            else {
                secondaryServiceFee = VendorManager.instance.secondaryServiceFee
            }
            secondaryCharge.text = "$" + String(format: "%.2f", secondaryServiceFee)
        }
        
        if (ReceiptManager.instance.acceptTips == true) {
            if (tipIndex == 3) {
                if (totalPrice == 0) {
                    tipText.text = "Tip (0%)"
                }
                else {
                    tipText.text = String(format: "Tip (%.0f%%)", round(tipPrice * 100 / totalPrice))
                }
                tipCost.text = "$" + String(format: "%.2f", tipPrice)
            }
            else {
                let tipLevel = tipLevelDataSource[tipIndex]
                tipText.text = "Tip (" + String(format: "%d", tipLevel) + "%)"
                tipPrice = round(totalPrice * Float(tipLevel)) / 100
                tipCost.text = "$" + String(format: "%.2f", tipPrice)
            }
        }
        
        subTotal.text = "$" + String(format: "%.2f", totalPrice)
        taxLevel.text = "Tax (" + String(format: "%.0f", ReceiptManager.instance.tax) + "%)"
        taxCost.text = "$" + String(format: "%.2f", taxPrice)
        
        serviceLevel.text = VendorManager.instance.serviceFeeLabel + servicePercentString
        serviceCost.text = "$" + String(format: "%.2f", servicePrice)
        totalCost.text = "$" + String(format: "%.2f", totalPrice + taxPrice + servicePrice + secondaryServiceFee + tipPrice)
    }
    
    //  Check Placeable
    
    func checkPlaceable() -> Bool {
        if(VendorManager.instance.locationType == "pickup" && CardManager.instance.getSelectedCardIndex() != -1 && (UserManager.instance.phoneNumber != nil && UserManager.instance.phoneNumber != "")) {
            return true
        }
        else if (VendorManager.instance.mapOverlay != nil && CardManager.instance.getSelectedCardIndex() != -1 && (UserManager.instance.phoneNumber != nil && UserManager.instance.phoneNumber != "")) {
            return true
        }
        else if (VendorManager.instance.locationType == "room_service" && ReceiptManager.instance.roomNumber != "" && CardManager.instance.getSelectedCardIndex() != -1 && (UserManager.instance.phoneNumber != nil && UserManager.instance.phoneNumber != "")) {
            return true
        }
        else {
            return false
        }
    }
    
    func enablePlaceButton(_ enable: Bool) {
        orderButtonHeightConstraint.constant = enable ? 56 : 0
        placeButton.isHidden = !enable
    }
    
    @IBAction func onSetPhoneNumber(_ sender: Any) {
        let phoneNumberViewController = storyboard!.instantiateViewController(withIdentifier: "PhoneNumberViewController") as! PhoneNumberViewController
        navigationController!.pushViewController(phoneNumberViewController, animated: true)
    }
    
    
    @IBAction func onDeliveryInfo(_ sender: AnyObject) {
        let deliveryInfoViewController = storyboard!.instantiateViewController(withIdentifier: "DeliveryInfoViewController") as! DeliveryInfoViewController
        navigationController!.pushViewController(deliveryInfoViewController, animated: true)
    }
    
    @IBAction func onPaymentSetting(_ sender: AnyObject) {
        if (CardManager.instance.getCardCount() == 0 && !UserManager.instance.isManager && Util.checkApplePay() < 1) {
            let addPaymentViewController = storyboard!.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
            addPaymentViewController.isNew = true
            addPaymentViewController.delegate = self
            navigationController!.pushViewController(addPaymentViewController, animated: true)
        }
        else {
            let paymentViewController = storyboard!.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
            paymentViewController.selectedPaymentIndex = CardManager.instance.getSelectedCardIndex()
            navigationController!.pushViewController(paymentViewController, animated: true)
        }
    }
    
    @IBAction func onTip(_ sender: AnyObject) {
        if (WebService.instance.authToken == "") {
            Util.showAlertMessage(APP_TITLE, message: "You need to login to adjust the tip.", parent: self)
            return
        }
        
        let tipSelectViewController = storyboard!.instantiateViewController(withIdentifier: "TipSelectViewController") as! TipSelectViewController
        tipSelectViewController.receiptViewController = self
        tipSelectViewController.currentTipIndex = tipIndex
        tipSelectViewController.tipAmount = tipPrice
        tipSelectViewController.totalPrice = totalPrice
        
        present(tipSelectViewController, animated: true, completion: nil)
    }
    
    func tipUpdate() {
        calculatePrice()
    }
    
    //////////////////////////////
    
    //  ApplePay
    
    func showApplePay(show: Bool) {
        if (show) {
            bottomViewBottomConstraint.constant = -56
            applePayButtonBackground!.isHidden = false
            orderButtonHeightConstraint.constant = 0
            placeButton.isHidden = true
            if (Util.checkApplePayWithCards()) {
                applePayBuyButton!.isHidden = false
            }
            else {
                applePayBuyButton!.isHidden = true
            }
        }
        else {
            bottomViewBottomConstraint.constant = 0
            applePayButtonBackground!.isHidden = true
            enablePlaceButton(checkPlaceable())
        }
    }
    
    func updateApplePayStatus() {
        if (WebService.instance.authToken != "") {
            if (Util.checkApplePay() > 0 && CardManager.instance.getSelectedCardIndex() + 1 == CardManager.instance.getCardCount() + Util.checkApplePay()) {
                showApplePay(show: true)
            }
            else {
                showApplePay(show: false)
            }
        }
    }
    
    func onApplePaySetup() {
        let library = PKPassLibrary()
        library.openPaymentSetup()
    }
    
    func onApplePayBuy() {
        applePayNonce = ""
        if (VendorManager.instance.locationType == "pickup" || (VendorManager.instance.mapOverlay != nil)) {
            if (UserManager.instance.phoneNumber == nil || UserManager.instance.phoneNumber == "") {
                Util.showAlertMessage("EazyO", message: "Set your phone number.", parent: self)
            }
            else {
                let paymentRequest = makePaymentRequest()
                if let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
                    as PKPaymentAuthorizationViewController? {
                    paymentAuthorizationViewController.delegate = self
                    present(paymentAuthorizationViewController, animated: true, completion: nil)
                }
                else {
                    print("Error: Payment request is invalid.")
                }
            }
        }
        else {
            Util.showAlertMessage("EazyO", message: "Select your location at first.", parent: self)
        }
    }
    
    func makePaymentRequest() -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = PAY_MERCHANT_ID
        paymentRequest.supportedNetworks = PAYMENT_NETWORKS
        paymentRequest.merchantCapabilities = PKMerchantCapability.capability3DS
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        
        var discountPercent = ReceiptManager.instance.discountPercent
        if (VendorManager.instance.suppressDiscount) {
            discountPercent = 0
        }
        
        totalPrice = round(CartManager.instance.getTotalPrice() * (1 - discountPercent! / 100) * 100) / 100
        var servicePrice: Float = 0
        
        if(ReceiptManager.instance.serviceFeeType == "pct") {
            servicePrice = round(totalPrice * Float(ReceiptManager.instance.serviceFee)) / 100
        }
        else if(ReceiptManager.instance.serviceFeeType == "tiered") {
            for tier in ReceiptManager.instance.serviceFeeTiers {
                if (totalPrice >= tier.minRange && (tier.maxRange == nil || totalPrice <= tier.maxRange)) {
                    servicePrice = tier.price
                    break
                }
            }
        }
        
        var taxPrice: Float = 0
        if (ReceiptManager.instance.taxServiceFee == true) {
            taxPrice = round(totalPrice * Float(ReceiptManager.instance.tax) + servicePrice * ReceiptManager.instance.baseTax) / 100
        }
        else {
            taxPrice = round(totalPrice * Float(ReceiptManager.instance.tax)) / 100
        }
        
        var paymentSummaryItems = [PKPaymentSummaryItem]()
        paymentSummaryItems.append(PKPaymentSummaryItem(label: "Subtotal", amount: NSDecimalNumber(value: totalPrice)))
        paymentSummaryItems.append(PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(value: taxPrice)))
        paymentSummaryItems.append(PKPaymentSummaryItem(label: VendorManager.instance.serviceFeeLabel, amount: NSDecimalNumber(value: servicePrice)))
        
        if (ReceiptManager.instance.acceptTips == true) {
            if (tipIndex < 3) {
                let tipLevel = tipLevelDataSource[tipIndex]
                tipPrice = round(totalPrice * Float(tipLevel)) / 100
            }
            paymentSummaryItems.append(PKPaymentSummaryItem(label: "Tip", amount: NSDecimalNumber(value: tipPrice)))
        }
        else {
            tipPrice = 0
        }
        paymentSummaryItems.append(PKPaymentSummaryItem(label: VendorManager.instance.vendorName, amount: NSDecimalNumber(value: totalPrice + taxPrice + servicePrice + tipPrice)))
        
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        
        return paymentRequest
    }
    
    //////////////////////////////
    
    //  PKPaymentAuthorizationViewControllerDelegate

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        braintreeClient = BTAPIClient(authorization: CardManager.instance.clientToken!)
        let applePayClient = BTApplePayClient(apiClient: braintreeClient!)
        applePayClient.tokenizeApplePay(payment) { (tokenizedApplePayPayment, error) in
            guard let tokenizedApplePayPayment = tokenizedApplePayPayment else {
                completion(PKPaymentAuthorizationStatus.failure)
                return
            }

            self.applePayNonce = tokenizedApplePayPayment.nonce
            completion(PKPaymentAuthorizationStatus.success)
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController)
    {
        dismiss(animated: true, completion: nil)
        if (applePayNonce != "") {
            payWithApple = true
            updateUser()
        }
    }
}
