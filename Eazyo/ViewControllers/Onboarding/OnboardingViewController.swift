//
//  OnboardingViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 3/29/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import MBProgressHUD

class OnboardingViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate, WebServiceDelegate {
    
    @IBOutlet weak var onboardingBackground: UIImageView!
    @IBOutlet weak var tourScrollView: UIScrollView!
    @IBOutlet weak var textScrollView: UIScrollView!
    @IBOutlet var tourScreens: [UIView]!
    @IBOutlet var tourTextViews: [UIView]!
    
    @IBOutlet var dots: [UIView]!
    @IBOutlet weak var dotsView: UIView!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var facebookSignUpButton: UIButton!
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var dotsViewTopConstraint: NSLayoutConstraint!
    
    var loadingAnimator: MBProgressHUD?
    
    var startPoint, endPoint: CGPoint?
    var pageIndex: Int = 0
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    let buttonHeight: CGFloat = 46
    
    var fbUserObject = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        pageIndex = 0
        dots[0].backgroundColor = UIColor.eazyoCoolGreyColor()
        for i in 1...dots.count - 1 {
            dots[i].backgroundColor = UIColor.eazyoCoolGreyColor().withAlphaComponent(0.3)
        }
        for i in 0...tourTextViews.count - 1 {
            tourTextViews[i].alpha = 1.0
        }
        tourScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
        navigationController!.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
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
            CardManager.instance.setSelectedCardIndex(-1)
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
            
            let confirmLocationViewController = storyboard!.instantiateViewController(withIdentifier: "ConfirmLocationViewController")
            navigationController!.pushViewController(confirmLocationViewController, animated: true)
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
    
    //////////////////////////////
    
    //  UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.x / width
        let pageIndex = Int(position)
        tourTextViews[pageIndex].alpha = 1.0 - (position - CGFloat(pageIndex)) * 1.5
        textScrollView.contentOffset = CGPoint(x: 0, y: textScrollView.frame.height * position)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dots[pageIndex].backgroundColor = UIColor.eazyoCoolGreyColor().withAlphaComponent(0.3)
        
        pageIndex = Int(tourScrollView.contentOffset.x / tourScrollView.frame.width)
        dots[pageIndex].backgroundColor = UIColor.eazyoCoolGreyColor()
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
    
    @IBAction func onAgree(_ sender: UIButton) {
        textScrollView.setContentOffset(CGPoint(x: 0, y: textScrollView.frame.height * 4), animated: true)
        tourScrollView.isScrollEnabled = false
    }
    
    @IBAction func onAuth(_ sender: AnyObject) {
        if (sender.tag == 0) {
            let signInViewController = storyboard!.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            navigationController!.pushViewController(signInViewController, animated: true)
        }
        else if (sender.tag == 1) {
            let signUpViewController = storyboard!.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            navigationController!.pushViewController(signUpViewController, animated: true)
        }
        else if (sender.tag == 2) {
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
    
    @IBAction func onEnableLocation(_ sender: AnyObject) {
        let confirmLocationViewController = storyboard!.instantiateViewController(withIdentifier: "ConfirmLocationViewController")
        navigationController!.pushViewController(confirmLocationViewController, animated: true)
    }
    
    //////////////////////////////
}
