//
//  DeliveryPlaceViewController.swift
//  Eazyo
//
//  Created by Admin on 10/26/17.
//  Copyright © 2017 SoftDev0420. All rights reserved.
//

import UIKit
import MBProgressHUD

class DeliveryPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebServiceDelegate {

    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var locationTableView: UITableView!
    
    var loadingAnimator: MBProgressHUD?
    
    var venueInfo: [String : Any]?
    var locationResponse: [String : [[String : Any]]]?
    
    var placeCellData = [PlaceInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tipView.layer.borderColor = UIColor(red: 237 / 255, green: 100 / 255, blue: 57 / 255, alpha: 1).cgColor
        tipView.layer.cornerRadius = 3
        
        if (venueInfo != nil) {
            let venueUuid = venueInfo!["uuid"] as? String
            if (venueUuid != nil) {
                let appDelegate = UIApplication.shared.delegate
                loadingAnimator = MBProgressHUD.showAdded(to: appDelegate!.window!, animated: true)
                loadingAnimator!.mode = .text
                loadingAnimator!.labelText = "Getting Locations..."
                
                var parameters = [String : Any]()
                parameters["vendor_uuid"] = venueUuid!
                WebService.instance.delegate = self
                WebService.instance.getLocations(parameters)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = nil
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
    
    //////////////////////////////
    
    //  NavigationBar
    
    @IBAction func onBack(_ sender: AnyObject) {
        let membershipType = venueInfo!["membership_type"] as? String
        if (membershipType == "public_access") {
            navigationController!.popViewController(animated: true)
        }
        else {
            let count = navigationController!.viewControllers.count
            navigationController!.popToViewController(navigationController!.viewControllers[count - 3], animated: true)
        }
        
        UserManager.instance.clearVendorData()
        VendorManager.instance.clearVendorData()
    }

    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        loadingAnimator!.hide(false)
        switch apiName {
        case "getLocations":
            locationResponse = data as?  [String : [[String : Any]]]
            refreshLocationList()
            break
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(false)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "getLocations":
            showErrorMessage(alertMessage)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    func refreshLocationList() {
        placeCellData.removeAll()
        
        if (locationResponse != nil) {
            let deliveries = locationResponse!["delivery"]
            let pickups = locationResponse!["pickup"]
            let roomServices = locationResponse!["room_service"]
            
            if (deliveries != nil && deliveries!.count > 0) {
                placeCellData.append(PlaceInfo(type: nil, name: "Delivery"))
                
                var deliveryData = [PlaceInfo]()
                for delivery in deliveries! {
                    deliveryData.append(PlaceInfo(type: "delivery", uuid: delivery["uuid"] as? String, name: delivery["name"] as? String, description: delivery["description"] as? String, imageURL: delivery["image_url"] as? String, suppressDiscount: delivery["suppress_discount"] as! Bool))
                }
                placeCellData.append(contentsOf: deliveryData)
            }
            
            if (pickups != nil && pickups!.count > 0) {
                placeCellData.append(PlaceInfo(type: nil, name: "Pickup"))
                
                var pickupData = [PlaceInfo]()
                for pickup in pickups! {
                    pickupData.append(PlaceInfo(type: "pickup", uuid: pickup["uuid"] as? String, name: pickup["name"] as? String, description: pickup["description"] as? String, imageURL: pickup["image_url"] as? String, suppressDiscount: pickup["suppress_discount"] as! Bool))
                }
                placeCellData.append(contentsOf: pickupData)
            }
            
            if (roomServices != nil && roomServices!.count > 0) {
                placeCellData.append(PlaceInfo(type: nil, name: "Room Service"))
                
                var roomServiceData = [PlaceInfo]()
                for roomService in roomServices! {
                    roomServiceData.append(PlaceInfo(type: "room_service", uuid: roomService["uuid"] as? String, name: roomService["name"] as? String, description: roomService["description"] as? String, imageURL: roomService["image_url"] as? String, suppressDiscount: roomService["suppress_discount"] as! Bool))
                }
                placeCellData.append(contentsOf: roomServiceData)
            }
        }
        
        locationTableView.reloadData()
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeCellData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = placeCellData[indexPath.row].type
        if (type == nil) {
            return 69
        }
        else {
            return 54
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeData = placeCellData[indexPath.row]
        if (placeData.type == nil) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceTypeCell", for: indexPath) as! PlaceTypeCell
            let type = placeData.name
            cell.type.text = type
            cell.typeImage.image = UIImage(named: type!.replacingOccurrences(of: " ", with: "") + "Icon")
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceCell
            cell.placeName.text = placeData.name
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeData = placeCellData[indexPath.row]
        if (placeData.type != nil) {
            VendorManager.instance.locationType = placeData.type!
            VendorManager.instance.locationName = placeData.name!
            VendorManager.instance.suppressDiscount = placeData.suppressDiscount
            VendorManager.instance.isMenuLoaded = false
            VendorManager.instance.placeInfo = placeData
            
            let mainTabViewController = storyboard!.instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
            mainTabViewController.venueInfo = venueInfo
            navigationController!.pushViewController(mainTabViewController, animated: true)
        }
    }
    
    //////////////////////////////
    
    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    //////////////////////////////
}
