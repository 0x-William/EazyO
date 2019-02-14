//
//  DeliveryInfoViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/24/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class DeliveryInfoViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!

//    @IBOutlet var dataFields: [UITextField]!
//    @IBOutlet var fieldIcons: [UIImageView]!
//    @IBOutlet var errorIcons: [UIImageView]!
//    @IBOutlet var errorLabels: [UILabel]!
//    @IBOutlet var checkIcons: [UIImageView]!
//    @IBOutlet var clearIcons: [UIImageView]!
//    @IBOutlet var clearButtons: [UIButton]!
//    
//    @IBOutlet var firstName: UITextField!
//    @IBOutlet var lastName: UITextField!
    @IBOutlet var extraInfo: UITextView!
    @IBOutlet var placeholder: UILabel!
    
    @IBOutlet weak var extraInfoBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let additionalInfo = ReceiptManager.instance.additionalInfo
        
        if (additionalInfo != "") {
            extraInfo.text = additionalInfo
            placeholder.isHidden = true
        }
        
//        firstName.text = UserManager.instance.firstNameForOrdering
//        lastName.text = UserManager.instance.lastNameForOrdering
        
        NotificationCenter.default.addObserver(self, selector:#selector(DeliveryInfoViewController.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(DeliveryInfoViewController.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(DeliveryInfoViewController.closeKeyboard))
        contentView.addGestureRecognizer(singleTap)
        
//        extraInfo.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController!.delegate = nil
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
    
    //  NavigationBar
    
    @IBAction func onBack(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onUpdate(_ sender: AnyObject) {
//        if (nameValidation(0) && nameValidation(1)) {
            var info: String?
            if (extraInfo.textColor == UIColor.eazyoSilverColor()) {
                info = ""
            }
            else {
                info = extraInfo.text
            }
            
//            UserManager.instance.firstNameForOrdering = firstName.text
//            UserManager.instance.lastNameForOrdering = lastName.text
            ReceiptManager.instance.additionalInfo = info
            
            navigationController!.popViewController(animated: true)
//        }
//        else {
//            Util.showAlertMessage(APP_TITLE, message: "One or more invalid fields.", parent: self)
//        }
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
//        if (firstName.text != UserManager.instance.firstName || lastName.text != UserManager.instance.lastName || ReceiptManager.instance.additionalInfo != extraInfo.text) {
        if (ReceiptManager.instance.additionalInfo != extraInfo.text) {
            enableUpdateButton(true)
        }
        else {
            enableUpdateButton(false)
        }
    }
    
    //////////////////////////////
     
    //  UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
        changeUpdateButton()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars <= 140
    }
    
    //////////////////////////////
    
    func keyboardWillAppear(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo!
        let keyboardFrameBegin: CGRect = (keyboardInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrameBegin.size.height
        extraInfoBottomConstraint.constant = -20 - keyboardHeight
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillDisappear(_ notification: Notification) {
        extraInfoBottomConstraint.constant = -14
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    //////////////////////////////
    
    //  UITextFieldDelegate
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if (textField.tag == 2) {
//            textField.resignFirstResponder()
//        }
//        else {
//            dataFields[textField.tag + 1].becomeFirstResponder()
//        }
//        
//        return true
//    }
//    
//    @IBAction func onEditingChanged(_ sender: AnyObject) {
//        let dataField = sender as! UITextField
//        let index = dataField.tag
//        fieldIcons[index].isHidden = false
//        checkIcons[index].isHidden = true
//        errorIcons[index].isHidden = true
//        errorLabels[index].isHidden = true
//        clearIcons[index].isHidden = true
//        clearButtons[index].isHidden = true
//        changeUpdateButton()
//    }
//    
//    @IBAction func onFieldEdited(_ sender: AnyObject) {
//        let dataField = sender as! UITextField
//        
//        switch dataField.tag {
//        case 0:
//            _ = nameValidation(0)
//            break
//        case 1:
//            _ = nameValidation(1)
//            break
//            
//        default:
//            break
//        }
//        
//        changeUpdateButton()
//    }
//
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    // Validations
    
//    func nameValidation(_ tag: Int) -> Bool {
//        if (dataFields[tag].text?.characters.count == 0) {
//            return false
//        }
//        let status = !((dataFields[tag].text?.characters.count == 0) || (dataFields[tag].text?.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil))
//        changeValidationStatus(tag, status: status)
//        return status
//    }
//    
//    func changeValidationStatus(_ index: Int, status: Bool) {
//        fieldIcons[index].isHidden = !status
//        checkIcons[index].isHidden = !status
//        errorIcons[index].isHidden = status
//        errorLabels[index].isHidden = status
//        clearIcons[index].isHidden = status
//        clearButtons[index].isHidden = status
//    }
    
    //////////////////////////////
    
//    @IBAction func onClear(_ sender: AnyObject) {
//        let clearButton = sender as! UIButton
//        let index = clearButton.tag
//        
//        dataFields[index].text = ""
//        dataFields[index].becomeFirstResponder()
//        changeValidationStatus(index, status: true)
//        checkIcons[index].isHidden = true
//    }
    
    //////////////////////////////
}
