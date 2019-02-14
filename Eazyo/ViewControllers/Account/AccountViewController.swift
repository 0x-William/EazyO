//
//  AccountViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/18/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD

class AccountViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, AddPaymentDelegate, WebServiceDelegate {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var accountDetailTableView: UITableView!
    @IBOutlet weak var emptyScreen: UIView!
    
    var loadingAnimator: MBProgressHUD?
    
    let otherTitles = ["Change your password", "Terms & Conditions"]
    var navigationType: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationType = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
        tabBarController!.tabBar.isHidden = false
        if (WebService.instance.authToken == "") {
            emptyScreen.isHidden = false
            logoutButton.isHidden = true
        }
        else {
            emptyScreen.isHidden = true
            logoutButton.isHidden = false
            accountDetailTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////////
    
    //  NavigationBar
    
    @IBAction func onLogout(_ sender: AnyObject) {
        WebService.instance.removeAuthToken()
        _ = CartManager.instance.clearCart()
        CardManager.instance.clearCardData()
        UserManager.instance.clearUserData()
        VendorManager.instance.clearVendorData()
        ReceiptManager.instance.clearReceiptData()
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue("", forKey: "authenticationToken")
        userDefaults.setValue("", forKey: "password")
        userDefaults.setValue("", forKey: "defaultCardIndex")
        
        let onboardingViewController = storyboard!.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        let navController = UINavigationController()
        
        navController.pushViewController(onboardingViewController, animated: true)
        let appDelegate = UIApplication.shared.delegate
        appDelegate!.window!!.rootViewController = navController
    }
    
    //////////////////////////////
    
    @IBAction func onAccountSetup(_ sender: AnyObject) {
        navigationType = 1
        let accountSetupViewController = storyboard!.instantiateViewController(withIdentifier: "AccountSetupViewController") as! AccountSetupViewController
        accountSetupViewController.navigationType = 1
        navigationController!.pushViewController(accountSetupViewController, animated: true)
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            if (navigationType == 1) {
                navigationType = 0
                return SlideAnimator(slideType: SLIDE_UP_PUSH)
            }
            else {
                return nil
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
        loadingAnimator!.hide(true)
        switch apiName {
        
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        _ = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        
        default:
            break
        }
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
        return 1 + CardManager.instance.cards.count + 1 + 3 + 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4 + CardManager.instance.cards.count) {
            return 32
        }
        else if (indexPath.row == 1) {
            return 130
        }
        else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4 + CardManager.instance.cards.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleCell", for: indexPath) as! SectionTitleCell
            switch (indexPath.row) {
            case 0:
                cell.optionTitle.text = "PROFILE"
                break
            case 2:
                cell.optionTitle.text = "PAYMENT"
                break
            case 4 + CardManager.instance.cards.count:
                cell.optionTitle.text = "OTHER"
                break
            default:
                break
            }
            cell.selectionStyle = .none
            
            return cell
        }
        else if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AccountInfoCell", for: indexPath) as! AccountInfoCell
            cell.name.text = UserManager.instance.firstName! + " " + UserManager.instance.lastName!
            cell.email.text = UserManager.instance.email
            cell.phoneNumber.text = UserManager.instance.phoneNumber
            cell.selectionStyle = .none
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BaseInfoCell", for: indexPath) as! BaseInfoCell
            cell.selectionStyle = .none
            
            if (indexPath.row == 3 + CardManager.instance.cards.count) {
                cell.title.text = "Add New Card"
                cell.title.textColor = UIColor.eazyoOrangeColor()
                cell.backArrow.isHidden = true
                cell.separateLine.isHidden = true
                return cell
            }
            else {
                cell.title.textColor = UIColor.eazyoBlackColor()
                cell.backArrow.isHidden = false
                cell.separateLine.isHidden = false
            }
            
            if (indexPath.row > 2 && indexPath.row < 3 + CardManager.instance.cards.count) {
                let card = CardManager.instance.cards[indexPath.row - 3]
                cell.title.text = card["description"] as! String + " ..." + (card["last4"] as! String)
            }
            else {
                cell.title.text = otherTitles[indexPath.row - CardManager.instance.cards.count - 5]
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 3 + CardManager.instance.cards.count) {
            let addPaymentViewController = storyboard!.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
            addPaymentViewController.isNew = true
            addPaymentViewController.delegate = self
            navigationController!.pushViewController(addPaymentViewController, animated: true)
        }
        else if (indexPath.row > 2 && indexPath.row < 3 + CardManager.instance.cards.count) {
            let addPaymentViewController = storyboard!.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
            addPaymentViewController.isNew = false
            addPaymentViewController.paymentData = CardManager.instance.cards[indexPath.row - 3]
            addPaymentViewController.cardIndex = indexPath.row - 3
            navigationController!.pushViewController(addPaymentViewController, animated: true)
        }
        else if (indexPath.row == CardManager.instance.cards.count + 5) {
            let changePasswordViewController = storyboard!.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            navigationController!.pushViewController(changePasswordViewController, animated: true)
        }
        else if (indexPath.row == CardManager.instance.cards.count + 6) {
            navigationType = 1
            let termsViewController = storyboard!.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
            navigationController!.pushViewController(termsViewController, animated: true)
        }
    }
    
    //  Edit Account Data
    
    @IBAction func onEditInfo(_ sender: AnyObject) {
        let profileViewController = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        navigationController!.pushViewController(profileViewController, animated: true)
    }
    
    @IBAction func onEditPhoto(_ sender: AnyObject) {
        let photoViewController = storyboard!.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        navigationController!.pushViewController(photoViewController, animated: true)
    }
}
