//
//  Util.swift
//  Eazyo
//
//  Created by SoftDev0420 on 3/27/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import CoreLocation
import PassKit
import UserNotifications

let APP_TITLE = "EazyO"
let NAVIGATION_BAR_HEIGHT = CGFloat(64.0)
let TAB_BAR_HEIGHT = CGFloat(49.0)
let PAYMENT_NETWORKS = [PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa, PKPaymentNetwork.discover]


class Util {
    
    class func enableNotification() {
        let center  = UNUserNotificationCenter.current()
        center.delegate = UIApplication.shared.delegate as! AppDelegate
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            if (error == nil) {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    class func composeAlertMessage(_ data: [String]) -> String {
        var alertMessage = ""
        if (data.count > 0) {
            for i in 0...data.count - 1 {
                alertMessage = alertMessage + data[i]
                if (i != data.count - 1) {
                    alertMessage = alertMessage + "\n"
                }
            }
        }
        return alertMessage
    }
    
    class func showAlertMessage(_ title:String, message:String, parent:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        parent.present(alert, animated: true, completion: nil)
    }
    
    class func showAlertMessageWithCallback(_ title:String, message:String, parent:UIViewController, callback: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            callback()
        }
        alert.addAction(okAction)
        parent.present(alert, animated: true, completion: nil)
    }
    
    class func showAlertMessageWithCancel(_ title:String, message:String, parent:UIViewController, callback: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive ) { (action) in
            callback()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        parent.present(alert, animated: true, completion: nil)
    }
    
    class func heightForView(_ text: String, font: UIFont, width: CGFloat) -> CGFloat{
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        if (text == "") {
            label.text = " "
        }
        else {
            label.text = text
        }
        
        label.sizeToFit()
        return label.frame.height
    }
    
    class func widthForView(_ text: String, font: UIFont, height: CGFloat) -> CGFloat{
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        if (text == "") {
            label.text = " "
        }
        else {
            label.text = text
        }
        
        label.sizeToFit()
        return label.frame.width
    }

    class func sign(_ num: Int) -> Int { return (num < 0) ? -1 : (num > 0) ? 1 : 0 }
    
    class func stringWithPlaceCount(_ value: Float, placeCount: Int) -> String {
        return String(format: "%.\(placeCount)f", value)
    }
    
    class func checkApplePay() -> Int {
        if (PKPaymentAuthorizationViewController.canMakePayments()) {
            return 1
        }
        else {
            return 0
        }
    }
    
    class func checkApplePayWithCards() -> Bool {
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: PAYMENT_NETWORKS)
    }
    
    class func boolToInt(bool: Bool) -> Int {
        if (bool) {
            return 1
        }
        else {
            return 0
        }
    }
    
    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
