//
//  LoginViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 3/23/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import MBProgressHUD
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


class SignInViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, WebServiceDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet var dataFields: [UITextField]!
    @IBOutlet var fieldIcons: [UIImageView]!
    @IBOutlet var errorIcons: [UIImageView]!
    @IBOutlet var errorLabels: [UILabel]!
    @IBOutlet var checkIcons: [UIImageView]!
    @IBOutlet var clearIcons: [UIImageView]!
    @IBOutlet var clearButtons: [UIButton]!
    
    @IBOutlet weak var emailTrailingConstraint: NSLayoutConstraint!
    
    var loadingAnimator : MBProgressHUD?
    var navigationType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(SignInViewController.closeKeyboard))
        contentView.addGestureRecognizer(singleTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
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
    
    @IBAction func onSignIn(_ sender: AnyObject) {
        closeKeyboard()
        if emailValidation() && passwordValidation() {
            var parameters = [String : Any]()
            parameters["email"] = emailAddress.text
            parameters["password"] = password.text

            loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingAnimator!.mode = .indeterminate
            loadingAnimator!.labelText = "Loading..."
            WebService.instance.delegate = self
            WebService.instance.signIn(parameters)
        }
        else {
            Util.showAlertMessage(APP_TITLE, message: "One or more invalid fields.", parent: self)
        }
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
        case "signIn":
            let dataObject = data as! [String : Any]
            let authenticationToken = dataObject["authentication_token"] as! String
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(authenticationToken, forKey: "authenticationToken")
            userDefaults.setValue(password!.text, forKey: "password")
            WebService.instance.setAuthToken(authenticationToken)
            UserManager.instance.setUserData(dataObject)
            UserManager.instance.setPassword(password.text)
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
            
            if (navigationType > 0) {
                let viewController = navigationController!.viewControllers[(navigationController!.viewControllers.count) - 3]
                navigationController!.popToViewController(viewController, animated: true)
            }
            else {
                let confirmLocationViewController = storyboard!.instantiateViewController(withIdentifier: "ConfirmLocationViewController")
                navigationController!.pushViewController(confirmLocationViewController, animated: true)
            }
            break
                
        default:
            break
        }
    }
    
    func onError(apiName: String, errorInfo: [String]) {
        loadingAnimator!.hide(true)
        
        let alertMessage = Util.composeAlertMessage(errorInfo)
        
        switch apiName {
        case "signIn":
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
    
    //  UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.tag == 0) {
            password.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let index = textField.tag
        showNormalViews(index)
    }
    
    @IBAction func onEditingChanged(_ sender: AnyObject) {
        let dataField = sender as! UITextField
        let index = dataField.tag
        showNormalViews(index)
    }
    
    @IBAction func onFieldEdited(_ sender: AnyObject) {
        let dataField = sender as! UITextField
        
        switch dataField.tag {
        case 0:
            _ = emailValidation()
            break
            
        case 1:
            _ = passwordValidation()
            break
            
        default:
            break
        }
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    // Validations
    
    func emailValidation() -> Bool {
        if (emailAddress.text?.characters.count == 0) {
            return false
        }
        let status = isValidEmail(emailAddress.text!)
        changeValidationStatus(0, status: status)
        
        return status
    }
    
    func isValidEmail(_ emailCandidate:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailCandidate)
    }
    
    func passwordValidation() -> Bool {
        if (password.text?.characters.count == 0) {
            return false
        }
        let status = !(password.text?.characters.count < 8)
        changeValidationStatus(1, status: status)
        return status
    }
    
    func changeValidationStatus(_ index: Int, status: Bool) {
        fieldIcons[index].isHidden = !status
        checkIcons[index].isHidden = !status
        hideErrorViews(index, status: status)
    }
    
    func showNormalViews(_ index: Int) {
        fieldIcons[index].isHidden = false
        checkIcons[index].isHidden = true
        hideErrorViews(index, status: true)
    }
    
    func hideErrorViews(_ index: Int, status: Bool) {
        errorIcons[index].isHidden = status
        errorLabels[index].isHidden = status
        clearIcons[index].isHidden = status
        clearButtons[index].isHidden = status
    }
    
    //////////////////////////////
    
    @IBAction func onClear(_ sender: AnyObject) {
        let clearButton = sender as! UIButton
        let index = clearButton.tag
        
        dataFields[index].text = ""
        dataFields[index].becomeFirstResponder()
        changeValidationStatus(index, status: true)
        checkIcons[index].isHidden = true
    }
}

