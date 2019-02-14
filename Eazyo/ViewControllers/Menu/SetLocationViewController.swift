//
//  SetLocationViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/17/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

class SetLocationViewController: UIViewController, UINavigationControllerDelegate, UIWebViewDelegate, CLLocationManagerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {

    @IBOutlet weak var mapWebView: UIWebView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var locationManager: CLLocationManager?
    var loadingAnimator: MBProgressHUD?
    
    var authenticated = false
    var gotPosition: Bool = false
    var lat = 0.0
    var long = 0.0
    var bLoad = true
    
    
    let userDefaults = UserDefaults.standard
    var request: URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabBarController!.tabBar.isHidden = true
        
        loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingAnimator!.mode = .text
        loadingAnimator!.labelText = "Loading..."
        
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
        locationManager?.startUpdatingLocation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    @IBAction func onFind(_ sender: Any) {
        if (gotPosition) {
            mapWebView.stringByEvaluatingJavaScript(from: "resetPin(\(long),\(lat));")
        }
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
                
                if let locationUuid = VendorManager.instance.placeInfo?.uuid {
                    let urlString = "\(baseUrl)/map/location\(locationUuid)?lat=\(lat)&long=\(long)&confirm_location=true&os=ios"
                    let url = URL(string: urlString)
                    request = URLRequest(url: url!)
                    mapWebView.loadRequest(request!)
                }
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
    
    @IBAction func onConfirmLocation(_ sender: AnyObject) {
        let dataString = mapWebView.stringByEvaluatingJavaScript(from: "getDataString();")
        if (dataString == nil) {
            Util.showAlertMessage("EazyO", message: "Cannot get user location data.", parent: self)
            return
        }
        
        let mapData = Util.convertToDictionary(text: dataString!)
        if (mapData == nil) {
            Util.showAlertMessage("EazyO", message: "Wrong data.", parent: self)
            return
        }
        
        let overlay = mapData!["overlay"] as? String
        if (overlay == nil) {
            Util.showAlertMessage("EazyO", message: "You should choose the point inside the location.", parent: self)
        }
        else {
            VendorManager.instance.setUserMapData(mapData!["latitude"] as! CGFloat,
                                                  longitude: mapData!["longitude"] as! CGFloat, overlay: overlay!)
            navigationController!.popViewController(animated: true)
        }
    }
    
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
            navigationController!.popViewController(animated: true)
        }
        else {
            Util.showAlertMessage("EazyO", message: "Incorrect location data.", parent: self)
            return
        }
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            return nil
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return nil
        }
        
        return nil
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
}
