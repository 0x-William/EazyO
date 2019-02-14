//
//  LoadingViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 7/5/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoadingViewController: UIViewController, WebServiceDelegate {

    var loadingAnimator: MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingAnimator!.mode = .indeterminate
        loadingAnimator!.labelText = "Loading..."
        WebService.instance.delegate = self
        WebService.instance.getUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.isNavigationBarHidden = true
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
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        switch apiName {
        case "getUser":
            let dataObject = data as! [String : Any]
            UserManager.instance.setUserData(dataObject)
            Util.enableNotification()
            WebService.instance.getClientToken()
            break
            
        case "getClientToken":
            let dataObject = data as! [String : Any]
            let clientToken = dataObject["client_token"] as! String
            CardManager.instance.setClientToken(clientToken)
            WebService.instance.getCards()
            break
            
        case "getCards":
            loadingAnimator!.hide(true)
            
            let cardData = data as? [[String : Any]]
            if (cardData != nil) {
                CardManager.instance.cards = cardData!
            }
            CardManager.instance.setSelectedCardIndex(-1)
            
            let confirmLocationViewController = storyboard!.instantiateViewController(withIdentifier: "ConfirmLocationViewController")
            navigationController!.pushViewController(confirmLocationViewController, animated: true)
            
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "getUser", "getClientToken", "getCards":
            Util.showAlertMessageWithCallback(APP_TITLE, message: alertMessage, parent: self, callback: { 
                let onboardingViewController = self.storyboard!.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
                let navController = UINavigationController()
                
                navController.pushViewController(onboardingViewController, animated: true)
                let appDelegate = UIApplication.shared.delegate
                appDelegate!.window!!.rootViewController = navController
                UserDefaults.standard.setValue("", forKey: "authenticationToken")
                WebService.instance.removeAuthToken()
            })
            break
        
        default:
            break
        }
    }
    
    //////////////////////////////
}
