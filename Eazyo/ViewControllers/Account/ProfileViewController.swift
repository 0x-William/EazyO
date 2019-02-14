//
//  ProfileViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/19/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD

class ProfileViewController: UIViewController, UITextFieldDelegate, WebServiceDelegate {
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
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
        firstName.text = UserManager.instance.firstName
        lastName.text = UserManager.instance.lastName
        phoneNumber.text = UserManager.instance.phoneNumber
        emailAddress.text = UserManager.instance.email
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(ProfileViewController.closeKeyboard))
        contentView.addGestureRecognizer(singleTap)
        
        enableUpdateButton(false)
        
        addDoneButtonOnKeyboard()
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
        if (nameValidation(0) && nameValidation(1) && emailValidation() && phoneNumberValidation()) {
            var parameters = [String : Any]()
            if (UserManager.instance.firstName != firstName.text) {
                parameters["first_name"] = firstName.text
            }
            if (UserManager.instance.lastName != lastName.text) {
                parameters["last_name"] = lastName.text
            }
            if (UserManager.instance.phoneNumber != phoneNumber.text) {
                parameters["phone_number"] = phoneNumber.text
            }
            if (UserManager.instance.email != emailAddress.text) {
                parameters["email"] = emailAddress.text
            }
            
            if (parameters.count != 0) {
                loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
                loadingAnimator!.mode = .text
                loadingAnimator!.labelText = "Updating..."
                WebService.instance.delegate = self
                WebService.instance.updateUser(parameters)
            }
        }
        else {
            Util.showAlertMessage(APP_TITLE, message: "One or more invalid fields.", parent: self)
        }
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        loadingAnimator!.hide(true)
        switch apiName {
        case "updateUser":
            UserManager.instance.setUserData(data as! [String : Any])
            enableUpdateButton(false)
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
        if (textField.tag == 3) {
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
        enableUpdateButton(checkUpdatable())
    }
    
    @IBAction func onFieldEdited(_ sender: AnyObject) {
        let dataField = sender as! UITextField
        
        switch dataField.tag {
        case 0:
            _ = nameValidation(0)
            break
        case 1:
            _ = nameValidation(1)
            break
        case 2:
            _ = phoneNumberValidation()
            break
        case 3:
            _ = emailValidation()
            break
            
        default:
            break
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let nextToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        nextToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(ProfileViewController.nextButtonAction))
        nextToolbar.items = [flexSpace, next]
        nextToolbar.sizeToFit()
        
        phoneNumber.inputAccessoryView = nextToolbar
    }
    
    func nextButtonAction() {
        emailAddress.becomeFirstResponder()
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    // Validations
    
    func nameValidation(_ tag: Int) -> Bool {
        if (dataFields[tag].text?.characters.count == 0) {
            return false
        }
        let status = !((dataFields[tag].text!.characters.count == 0) || (dataFields[tag].text!.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil))
        changeValidationStatus(tag, status: status)
        return status
    }
    
    func emailValidation() -> Bool {
        if (emailAddress.text?.characters.count == 0) {
            return false
        }
        let status = isValidEmail(emailAddress.text!)
        changeValidationStatus(3, status: status)
        
        return status
    }
    
    func isValidEmail(_ emailCandidate:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailCandidate)
    }
    
    func phoneNumberValidation() -> Bool {
        let status = !(phoneNumber.text?.characters.count == 0)
        checkIcons[2].isHidden = !status
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
    
    //////////////////////////////
    
    func checkUpdatable() -> Bool {
        if (UserManager.instance.firstName != firstName.text || UserManager.instance.lastName != lastName.text
            || UserManager.instance.phoneNumber != phoneNumber.text || UserManager.instance.email != emailAddress.text) {
            return true
        }
        else {
            return false
        }
    }
    
    func enableUpdateButton(_ enable: Bool) {
        if (enable == true) {
            updateButton.setTitleColor(UIColor.eazyoOrangeColor(), for: UIControlState())
            updateButton.alpha = 1.0
            updateButton.isEnabled = true
        }
        else {
            updateButton.setTitleColor(UIColor.eazyoCoolGreyColor(), for: UIControlState())
            updateButton.alpha = 0.4
            updateButton.isEnabled = false
        }
    }
    
    //////////////////////////////
}
