//
//  ChangePasswordViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/19/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

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


class ChangePasswordViewController: UIViewController, WebServiceDelegate {
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet var dataFields: [UITextField]!
    @IBOutlet var fieldIcons: [UIImageView]!
    @IBOutlet var errorIcons: [UIImageView]!
    @IBOutlet var errorLabels: [UILabel]!
    @IBOutlet var checkIcons: [UIImageView]!
    @IBOutlet var clearIcons: [UIImageView]!
    @IBOutlet var clearButtons: [UIButton]!
    
    var loadingAnimator : MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(ChangePasswordViewController.closeKeyboard))
        contentView.addGestureRecognizer(singleTap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////////
    
    //  NavigationBar
    
    @IBAction func onBack(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onUpdate(_ sender: AnyObject) {
        closeKeyboard()
        if (newPassword.text != confirmPassword.text) {
            Util.showAlertMessage(APP_TITLE, message: "Passwords are not match", parent: self)
        }
        else {
            if (newPassword.text == "") {
                Util.showAlertMessage(APP_TITLE, message: "Enter new password.", parent: self)
            }
            else {
                showPasswordInputDialog()
            }
        }
    }
    
    func showPasswordInputDialog() {
        let passwordAlert = UIAlertController(title: APP_TITLE, message: "Enter current password", preferredStyle: .alert)
        passwordAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Current Password"
            textField.isSecureTextEntry = true
        })
        passwordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let currentPassword = passwordAlert.textFields![0] as UITextField
            if (currentPassword.text != UserManager.instance.password) {
                Util.showAlertMessage(APP_TITLE, message: "Wrong password", parent: self)
            }
            else {
                self.loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
                self.loadingAnimator!.mode = .indeterminate
                self.loadingAnimator!.labelText = "Updating..."
                
                var parameters = [String : Any]()
                parameters["password"] = self.newPassword.text
                WebService.instance.delegate = self
                WebService.instance.updateUser(parameters)
            }
        }))
        passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(passwordAlert, animated: true, completion: nil)
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        loadingAnimator!.hide(true)
        switch apiName {
        case "updateUser":
            UserManager.instance.setUserData(data as! [String : Any])
            UserManager.instance.setPassword(newPassword.text)
            Util.showAlertMessage(APP_TITLE, message: "Updated successfully!", parent: self)
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
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.tag == 1) {
            textField.resignFirstResponder()
        }
        else {
            dataFields[textField.tag + 1].becomeFirstResponder()
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
        _ = passwordValidation(dataField.tag)
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    // Validations
        
    func passwordValidation(_ index: Int) -> Bool {
        if (dataFields[index].text?.characters.count == 0) {
            return false
        }
        
        var status = true
        if (dataFields[index].text!.rangeOfCharacter(from: CharacterSet.letters) == nil) {
            status = false
            errorLabels[index].text = "Include at least 1 letter"
        }
        else if (dataFields[index].text!.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil) {
            status = false
            errorLabels[index].text = "Include at least 1 digit"
        }
        else if (dataFields[index].text?.characters.count < 6) {
            status = false
            errorLabels[index].text = "At least 6 charaters"
        }
        
        changeValidationStatus(index, status: status)
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
