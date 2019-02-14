//
//  AccountSetupViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/7/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import MBProgressHUD

class AccountSetupViewController: UIViewController, UINavigationControllerDelegate, WebServiceDelegate {

    @IBOutlet weak var loginButton: UIButton!
    
    var loadingAnimator: MBProgressHUD?
    
    var navigationType: Int?
    var fbUserObject = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController!.tabBar.isHidden = true
        navigationController!.delegate = self
        
        loginButton.layer.cornerRadius = 3
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.eazyoOrangeColor().cgColor
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
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            return SlideAnimator(slideType: SLIDE_UP_PUSH)
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return SlideAnimator(slideType: SLIDE_DOWN_POP)
        }
        
        return nil
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        switch apiName {
        case "signInWithFacebook":
            let dataObject = data as! [String : Any]
            let authenticationToken = dataObject["authentication_token"] as! String
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(authenticationToken, forKey: "authenticationToken")
            userDefaults.setValue("", forKey: "password")
            WebService.instance.setAuthToken(authenticationToken)
            UserManager.instance.setUserData(dataObject)
            UserManager.instance.setPassword("")
            Util.enableNotification()
            WebService.instance.getClientToken()
            break
            
        case "createAccount":
            let dataObject = data as! [String : Any]
            let authenticationToken = dataObject["authentication_token"] as! String
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(authenticationToken, forKey: "authenticationToken")
            userDefaults.setValue("", forKey: "password")
            WebService.instance.setAuthToken(authenticationToken)
            UserManager.instance.setUserData(dataObject)
            UserManager.instance.setPassword("")
            CardManager.instance.setSelectedCardIndex(-1)
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
        case "signInWithFacebook":
            registerWithFacebook()
            break
        case "createAccount":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
        case "getClientToken":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
        case "getCards":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  Setup Account
    
    @IBAction func onFacebookSignUp(_ sender: Any) {
        loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingAnimator!.mode = .indeterminate
        loadingAnimator!.labelText = "Loading..."
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self, handler: { (loginResult, error) in
            if (error != nil) {
                self.loadingAnimator!.hide(true)
                print("Process error.")
            }
            else if (loginResult!.isCancelled) {
                self.loadingAnimator!.hide(true)
                print("Cancelled.")
            }
            else {
                print("Logged in.")
                self.getUserInfo(loginResult!.token)
            }
        })
    }
    
    func getUserInfo(_ token: FBSDKAccessToken) {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name"], tokenString: token.tokenString, version: nil, httpMethod: "GET")
            .start { (connection, result, error) in
                if (error == nil) {
                    self.fbUserObject = result as! [String : Any]
                    self.fbUserObject["profile_photo"] = "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=" + token.tokenString
                    self.signInWithFacebookId()
                }
                else {
                    self.loadingAnimator!.hide(true)
                    print(error!)
                }
        }
    }
    
    func signInWithFacebookId() {
        let email = fbUserObject["email"] as? String
        let userId = fbUserObject["id"] as? String
        if (userId == nil) {
            Util.showAlertMessage("EazyO", message: "Something is wrong with Facebook user ID.", parent: self)
            self.loadingAnimator!.hide(true)
        }
        else {
            var parameters = [String : String]()
            parameters["fb_user_id"] = userId
            if (email != nil) {
                parameters["email"] = email
            }
            
            WebService.instance.delegate = self
            WebService.instance.signInWithFacebook(parameters)
        }
    }
    
    func registerWithFacebook() {
        loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingAnimator!.mode = .indeterminate
        loadingAnimator!.labelText = "Loading..."
        
        var parameters = [String : Any]()
        
        parameters["first_name"] = fbUserObject["first_name"] as? String ?? ""
        parameters["last_name"] = fbUserObject["last_name"] as? String ?? ""
        parameters["email"] = fbUserObject["email"] as? String ?? ""
        parameters["fb_user_id"] = fbUserObject["id"] as! String
        parameters["image_url"] = fbUserObject["profile_photo"] as! String
        parameters["accepted_tcs"] = true
        parameters["device_token"] = true
        
        WebService.instance.delegate = self
        WebService.instance.createAccount(parameters)
    }
    
    
    @IBAction func onSignUp(_ sender: AnyObject) {
        let signUpViewController = storyboard!.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        signUpViewController.navigationType = navigationType! + 1
        navigationController!.pushViewController(signUpViewController, animated: true)
    }
    
    @IBAction func onLogIn(_ sender: AnyObject) {
        let signInViewController = storyboard!.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        signInViewController.navigationType = navigationType! + 1
        navigationController!.pushViewController(signInViewController, animated: true)
    }
    
    //////////////////////////////
}
