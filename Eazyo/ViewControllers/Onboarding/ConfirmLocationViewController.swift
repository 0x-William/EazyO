//
//  ConfirmLocationViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/1/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import CoreLocation
import MBProgressHUD
import Alamofire
import AlamofireImage

class ConfirmLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UINavigationControllerDelegate, WebServiceDelegate {

    @IBOutlet weak var locationsTableView: UITableView!
    
    var locationManager: CLLocationManager?
    var loadingAnimator: MBProgressHUD?
    
    var vendorImages = [UIImage]()
    var vendorsResponse: [[String : Any]]?
    var gotPosition: Bool = false
    var navigationType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        
        vendorsResponse = []
        locationsTableView.reloadData()
        
        startLocationTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.isNavigationBarHidden = true
        navigationController!.delegate = self
        
        ReceiptManager.instance.discountPercent = 0.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            if (navigationType == 0) {
                return SlideAnimator(slideType: SLIDE_DOWN_PUSH)
            }
            else {
                return SlideAnimator(slideType: SLIDE_UP_PUSH)
            }
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return SlideAnimator(slideType: SLIDE_DOWN_POP)
        }
        
        return nil
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        loadingAnimator!.hide(false)
        switch apiName {
        case "getVendors":
            vendorsResponse = data as? [[String : Any]]
            vendorImages.removeAll()
            if (vendorsResponse != nil) {
                if (vendorsResponse!.count > 0) {
                    for _ in 0...vendorsResponse!.count - 1 {
                        vendorImages.append(UIImage())
                    }
                    locationsTableView.reloadData()
                }
                else {
                    showLocationNotFoundMessage("No available vendors now.")
                }
            }
            else {
                showLocationNotFoundMessage("Server response error.")
            }
            break
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(false)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "getVendors":
            showLocationNotFoundMessage(alertMessage)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count > 0) {
            if(!gotPosition) {
                locationManager!.stopUpdatingLocation()
                gotPosition = true
                var parameters = [String : Any]()
            
                #if PRODUCTION
                    parameters["latitude"] = locations.last!.coordinate.latitude
                    parameters["longitude"] = locations.last!.coordinate.longitude
                #else
                    parameters["latitude"] = 0
                    parameters["longitude"] = 0
                    parameters["distance"] = 10000
                #endif
                
                loadingAnimator!.labelText = "Loading Vendors..."
                WebService.instance.delegate = self
                WebService.instance.getVendors(parameters)
            }
        }
        else {
            loadingAnimator!.hide(false)
            showLocationNotFoundMessage("Cannot track your location.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loadingAnimator!.hide(false)
        showLocationNotFoundMessage("Cannot track your location.")
    }
    
    //////////////////////////////
    
    func startLocationTracking() {
        gotPosition = false
        loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingAnimator!.mode = .text
        loadingAnimator!.labelText = "Loading..."
        
        locationManager?.startUpdatingLocation()
    }
    
    func showLocationNotFoundMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.startLocationTracking()
        }
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendorImages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1) {
            return 259.0
        }
        else {
            return 219.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.selectionStyle = .none
        
        if (indexPath.row != 1) {
            cell.nearbyVenuesHeightConstraint.constant = 0.0
            cell.locationViewTopConstraint.constant = 0.0
            cell.nearbyVenues.isHidden = true
        }
        else {
            cell.nearbyVenuesHeightConstraint.constant = 39.0
            cell.locationViewTopConstraint.constant = 39.0
            cell.nearbyVenues.isHidden = false
        }
        
        if (vendorImages[indexPath.row].size.height == 0) {
            if let imageUrl = vendorsResponse![indexPath.row]["logo_url"] as? String {
                Alamofire.request(imageUrl)
                    .responseImage { response in
                        if let image = response.result.value {
                            self.vendorImages[indexPath.row] = image
                            cell.locationImage.image = image
                        }
                }
            }
        }
        else {
            cell.locationImage.image = vendorImages[indexPath.row]
        }
        
        cell.name.text = vendorsResponse![indexPath.row]["name"] as? String
        cell.address.text = vendorsResponse![indexPath.row]["full_address"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let deliveryPlaceViewController = storyboard!.instantiateViewController(withIdentifier: "DeliveryPlaceViewController") as! DeliveryPlaceViewController
//        navigationController!.pushViewController(deliveryPlaceViewController, animated: true)
//        
//        return
//        
        let vendorInfo = vendorsResponse![indexPath.row]
        let vendorUuid = vendorInfo["uuid"] as! String
        let membershipType = vendorInfo["membership_type"] as? String
        
        VendorManager.instance.vendor = vendorInfo
        VendorManager.instance.vendorUuid = vendorUuid
        VendorManager.instance.vendorName = vendorInfo["name"] as? String ?? "Vendor"
//        VendorManager.instance.locationType = vendorInfo["location_type"] as! String
//        VendorManager.instance.locationName = vendorInfo["location_name"] as? String ?? ""
        VendorManager.instance.hasMaps = vendorInfo["has_maps"] as? Bool ?? false
        VendorManager.instance.serviceFeeLabel = vendorInfo["service_fee_label"] as? String ?? "Service Fee"
        VendorManager.instance.tipLabel = vendorInfo["tip_label"] as? String ?? "Additional Tip"
        VendorManager.instance.hoursOfOperation = vendorInfo["hours_of_operation"] as! [String : String]
        
        VendorManager.instance.hasSecondaryServiceFee = vendorInfo["has_secondary_service_fee"] as? Bool ?? false
        VendorManager.instance.secondaryServiceFeeLabel = vendorInfo["secondary_service_fee_label"] as? String ?? "Secondary Fee"
        VendorManager.instance.secondaryServiceFee = vendorInfo["secondary_service_fee"] as? Float ?? 0
        VendorManager.instance.secondaryServiceFeeType = vendorInfo["secondary_service_fee_type"] as? String ?? ""
        
        ReceiptManager.instance.tipValues.removeAll()
        ReceiptManager.instance.tipValues = vendorInfo["tip_pct_values"] as? [Int] ?? [0, 15, 18, 20]
        ReceiptManager.instance.tipValues.remove(at: 0)
        ReceiptManager.instance.defaultTip = vendorInfo["tip_pct_default"] as? Int ?? 18
        
        if (membershipType == "public_access") {
            ReceiptManager.instance.acceptTips = vendorInfo["accept_tips"] as! Bool
            ReceiptManager.instance.baseTax = vendorInfo["base_sales_tax"] as! Float
            ReceiptManager.instance.resortTax = vendorInfo["resort_tax"] as! Float
            ReceiptManager.instance.taxServiceFee = vendorInfo["tax_service_fee"] as! Bool
            ReceiptManager.instance.tax = vendorInfo["sales_tax"] as! Float
            ReceiptManager.instance.serviceFee = vendorInfo["service_fee"] as! Float
            
            let deliveryPlaceViewController = storyboard!.instantiateViewController(withIdentifier: "DeliveryPlaceViewController") as! DeliveryPlaceViewController
            deliveryPlaceViewController.venueInfo = vendorInfo
            navigationController!.pushViewController(deliveryPlaceViewController, animated: true)
        }
        else if (membershipType == "private_club") {
            navigationType = 1
            let membershipViewController = storyboard!.instantiateViewController(withIdentifier: "MembershipViewController") as! MembershipViewController
            membershipViewController.venueInfo = vendorInfo
            navigationController!.pushViewController(membershipViewController, animated: true)
        }
    }
    
    //////////////////////////////
}
