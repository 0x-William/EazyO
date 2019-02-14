//
//  SignupViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 3/23/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
import AlamofireImage

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


class SignUpViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, WebServiceDelegate {
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var cameraText: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var currentTextField: UITextField!
    
    @IBOutlet var dataFields: [UITextField]!
    @IBOutlet var fieldIcons: [UIImageView]!
    @IBOutlet var errorIcons: [UIImageView]!
    @IBOutlet var errorLabels: [UILabel]!
    @IBOutlet var checkIcons: [UIImageView]!
    @IBOutlet var clearIcons: [UIImageView]!
    @IBOutlet var clearButtons: [UIButton]!
    
    @IBOutlet weak var passwordView: UIView!
    
    @IBOutlet weak var agreementLabel: UILabel!
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    
    
    var loadingAnimator : MBProgressHUD?
    var navigationType: Int = 0
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    var fbUserObject = [String : Any]()
    var facebookSignUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (facebookSignUp) {
            passwordView.isHidden = true
            firstName.text = fbUserObject["first_name"] as? String
            lastName.text = fbUserObject["last_name"] as? String
            emailAddress.text = fbUserObject["email"] as? String
            Alamofire.request(fbUserObject["profile_photo"] as! URL)
                .responseImage { response in
                    if let image = response.result.value {
                        UserManager.instance.avatarImage = image
                        self.photo.image = image
                    }
            }
            hidePhotoViews(true)
        }
        
        let agreementText : NSMutableAttributedString = NSMutableAttributedString(string: "By creating an account you agree to our\nTerms & Conditions")
        agreementText.addAttribute(NSForegroundColorAttributeName, value:UIColor.eazyoGreyColor(), range:NSMakeRange(0, 39))
        agreementText.addAttribute(NSForegroundColorAttributeName, value:UIColor.eazyoOrangeColor(), range:NSMakeRange(39, 19))
        agreementLabel.attributedText = agreementText
        agreementLabel.adjustsFontSizeToFitWidth = true
        
        photo.clipsToBounds = true
        
        if (navigationType == 1) {
            createButton.setTitle("Create & Order", for: UIControlState())
        }
        else {
            createButton.setTitle("Create", for: UIControlState())
        }
        
        addDoneButtonOnKeyboard()
        
        NotificationCenter.default.addObserver(self, selector:#selector(SignUpViewController.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(SignUpViewController.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(SignUpViewController.closeKeyboard))
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
    
    @IBAction func onCreateAccount(_ sender: AnyObject) {
        closeKeyboard()
        if (nameValidation(0) && nameValidation(1) && emailValidation() && phoneNumberValidation() && (facebookSignUp || passwordValidation())) {
            var parameters = [String : Any]()
            
            parameters["first_name"] = firstName.text
            parameters["last_name"] = lastName.text
            parameters["email"] = emailAddress.text
            
            if (facebookSignUp) {
                parameters["fb_user_id"] = fbUserObject["id"] as! String
            }
            else {
                parameters["password"] = password.text
            }
            
            parameters["phone_number"] = phoneNumber.text   //  +17543336819
            parameters["accepted_tcs"] = true
            parameters["device_token"] = true
            
            loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingAnimator!.mode = .indeterminate
            loadingAnimator!.labelText = "Loading..."
            
            if photo.image != nil {
                let imageData = UIImagePNGRepresentation(photo.image!)
                let strBase64:String = "data:image/png;base64," + imageData!.base64EncodedString(options: .lineLength64Characters)
                parameters["image_data"] = strBase64
            }
            
            WebService.instance.delegate = self
            WebService.instance.createAccount(parameters)
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
        case "createAccount":
            let dataObject = data as! [String : Any]
            let authenticationToken = dataObject["authentication_token"] as! String
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(authenticationToken, forKey: "authenticationToken")
            userDefaults.setValue(password!.text, forKey: "password")
            WebService.instance.setAuthToken(authenticationToken)
            UserManager.instance.setUserData(dataObject)
            UserManager.instance.setPassword(password.text)
            CardManager.instance.setSelectedCardIndex(-1)
            Util.enableNotification()
            WebService.instance.getClientToken()
            break
            
        case "getClientToken":
            loadingAnimator!.hide(true)
            let dataObject = data as! [String : Any]
            let clientToken = dataObject["client_token"] as! String
            CardManager.instance.setClientToken(clientToken)
            
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
        case "createAccount":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
        case "getClientToken":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.tag == 4) {
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
        currentTextField = textField
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
            _ = nameValidation(0)
            break
            
        case 1:
            _ = nameValidation(1)
            break
            
        case 2:
            _ = emailValidation()
            break
            
        case 3:
            _ = phoneNumberValidation()
            break
            
        case 4:
            _ = passwordValidation()
            break
            
        default:
            break
        }
    }
    
    func keyboardWillAppear(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo!
        let keyboardFrameBegin: CGRect = (keyboardInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrameBegin.size.height
        let contentViewHeight = screenHeight - NAVIGATION_BAR_HEIGHT
        let tag = CGFloat(currentTextField.tag)
        let textFieldBottom = contentViewHeight * (0.331 + tag * 0.086) + NAVIGATION_BAR_HEIGHT + 20
        let offset = textFieldBottom - (screenHeight - keyboardHeight)
        
        if (offset > 0) {
            contentViewTopConstraint.constant = -offset
            contentViewBottomConstraint.constant = -offset
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillDisappear(_ notification: Notification) {
        contentViewTopConstraint.constant = 0
        contentViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func addDoneButtonOnKeyboard() {
        let nextToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        nextToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(SignUpViewController.nextButtonAction))
        
        if (facebookSignUp) {
            next.title = "Done"
        }
        
        nextToolbar.items = [flexSpace, next]
        nextToolbar.sizeToFit()
        
        phoneNumber.inputAccessoryView = nextToolbar
    }
    
    func nextButtonAction() {
        if (facebookSignUp) {
            phoneNumber.resignFirstResponder()
        }
        else {
            password.becomeFirstResponder()
        }
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    // UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            photo.image = possibleImage
            hidePhotoViews(true)
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            photo.image = possibleImage
            hidePhotoViews(true)
        } else {
            return
        }
        
        // do something interesting here!
        
        dismiss(animated: true, completion: nil)
    }
    
    func hidePhotoViews(_ hide: Bool) {
        removeButton.isHidden = !hide
        photoButton.isHidden = hide
        cameraIcon.isHidden = hide
        cameraText.isHidden = hide
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
        changeValidationStatus(2, status: status)
        
        return status
    }
    
    func isValidEmail(_ emailCandidate:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailCandidate)
    }
    
    func phoneNumberValidation() -> Bool {
        let status = !(phoneNumber.text?.characters.count == 0)
        checkIcons[3].isHidden = !status
        return status
    }
    
    func passwordValidation() -> Bool {
        if (password.text?.characters.count == 0) {
            return false
        }
        
        var status = true
        if (password.text!.rangeOfCharacter(from: CharacterSet.letters) == nil) {
            status = false
            errorLabels[4].text = "Include at least 1 letter"
        }
        else if (password.text!.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil) {
            status = false
            errorLabels[4].text = "Include at least 1 digit"
        }
        else if (password.text?.characters.count < 8) {
            status = false
            errorLabels[4].text = "At least 8 charaters"
        }
        
        changeValidationStatus(4, status: status)
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
    
    // User Photo
    
    @IBAction func onSelectPhoto(_ sender: AnyObject) {
        closeKeyboard()
        let photoSelectMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.takePhoto()
        })
        let libraryAction = UIAlertAction(title: "Photo from library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.selectPicture()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        photoSelectMenu.addAction(cameraAction)
        photoSelectMenu.addAction(libraryAction)
        photoSelectMenu.addAction(cancelAction)
        
        self.present(photoSelectMenu, animated: true, completion: nil)
    }
    
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func takePhoto() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            Util.showAlertMessage(APP_TITLE, message: "Camera is not available now.", parent: self)
            return
        }
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .camera
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func onRemovePhoto(_ sender: AnyObject) {
        closeKeyboard()
        photo.image = nil
        hidePhotoViews(false)
    }
    
    //////////////////////////////
    
    @IBAction func onTerms(_ sender: AnyObject) {
        let termsViewController = storyboard!.instantiateViewController(withIdentifier: "TermsViewController")
        navigationController!.pushViewController(termsViewController, animated: true)
    }
    
    //////////////////////////////
}

