//
//  PhoneNumberViewController.swift
//  Eazyo
//
//  Created by SoftDev on 1/4/17.
//  Copyright © 2017 SoftDev0420. All rights reserved.
//

import UIKit

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet var fieldIcon: UIImageView!
    @IBOutlet var errorIcon: UIImageView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var checkIcon: UIImageView!
    @IBOutlet var clearIcon: UIImageView!
    @IBOutlet var clearButton: UIButton!
    
    @IBOutlet var phoneNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        phoneNumber.text = UserManager.instance.phoneNumber
        
        addDoneButtonOnKeyboard()
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
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onUpdate(_ sender: AnyObject) {
        if (phoneNumberValidation()) {
            UserManager.instance.phoneNumber = phoneNumber.text
            navigationController!.popViewController(animated: true)
        }
        else {
            Util.showAlertMessage(APP_TITLE, message: "Invalid phone number.", parent: self)
        }
    }
    
    //////////////////////////////
    
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
    
    func changeUpdateButton() {
        if (phoneNumber.text != UserManager.instance.phoneNumber) {
            enableUpdateButton(true)
        }
        else {
            enableUpdateButton(false)
        }
    }

    //////////////////////////////
    
    //  UITextFieldDelegate
    
    @IBAction func onEditingChanged(_ sender: AnyObject) {
        fieldIcon.isHidden = false
        checkIcon.isHidden = true
        errorIcon.isHidden = true
        errorLabel.isHidden = true
        clearIcon.isHidden = true
        clearButton.isHidden = true
        changeUpdateButton()
    }
    
    @IBAction func onFieldEdited(_ sender: AnyObject) {
        _ = phoneNumberValidation()
        changeUpdateButton()
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(PhoneNumberViewController.closeKeyboard))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        phoneNumber.inputAccessoryView = doneToolbar
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    // Validations
    
    func phoneNumberValidation() -> Bool {
        let status = !(phoneNumber.text?.characters.count == 0)
        checkIcon.isHidden = !status
        return status
    }
    
    func changeValidationStatus(_ status: Bool) {
        fieldIcon.isHidden = !status
        checkIcon.isHidden = !status
        errorIcon.isHidden = status
        errorLabel.isHidden = status
        clearIcon.isHidden = status
        clearButton.isHidden = status
    }
    
    //////////////////////////////
    
    @IBAction func onClear(_ sender: AnyObject) {
        phoneNumber.text = ""
        phoneNumber.becomeFirstResponder()
        changeValidationStatus(true)
        checkIcon.isHidden = true
    }
    
    //////////////////////////////
}
