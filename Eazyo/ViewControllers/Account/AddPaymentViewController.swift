//
//  AddPaymentViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/19/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD
import Braintree
import CreditCardValidator

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


protocol AddPaymentDelegate {
    func onAddNewCard()
}

class AddPaymentViewController: UIViewController, UITextFieldDelegate, WebServiceDelegate {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet var dataFields: [UITextField]!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cardDescription: UITextField!
    @IBOutlet weak var cardNo: UITextField!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var expirationDate: UITextField!
    @IBOutlet weak var cvv: UITextField!
    @IBOutlet weak var cvvView: UIView!
    @IBOutlet weak var removeCardButton: UIButton!
    
    var delegate: AddPaymentDelegate?
    
    var loadingAnimator: MBProgressHUD?
    var braintreeClient: BTAPIClient?
    
    var isNew: Bool?
    var paymentData: [String : Any]?
    var cardIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        braintreeClient = BTAPIClient(authorization: CardManager.instance.clientToken!)
        
        if (isNew == true) {
            cardDescription.returnKeyType = .next
        }
        else {
            addButton.setTitle("Update", for: UIControlState())
            cardDescription.text = paymentData!["description"] as? String
            cardNo.placeholder = paymentData!["last4"] as? String
            cardNo.isEnabled = false
            var brandImage = UIImage(named: paymentData!["brand"] as! String)
            if (brandImage == nil) {
                brandImage = UIImage(named: "DefaultCreditCard")
            }
            cardImage.image = brandImage
            expirationDate.placeholder = (paymentData!["exp_month"] as? String)! + "/" + (paymentData!["exp_year"] as? String)!
            expirationDate.isEnabled = false
            cvvView.isHidden = true
            removeCardButton.isHidden = false
            cardDescription.returnKeyType = .done
        }
        
        addDoneButtonOnKeyboard()
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(AddPaymentViewController.closeKeyboard))
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
    
    @IBAction func onAdd(_ sender: AnyObject) {
        closeKeyboard()
        if (isNew == true) {
            if (braintreeClient != nil)
            {
                let dateComponents =  expirationDate.text?.components(separatedBy: "/")
                if (dateComponents?.count > 1) {
                    let cardClient = BTCardClient(apiClient: braintreeClient!)
                    let card = BTCard(number: cardNo.text!, expirationMonth: dateComponents![0], expirationYear: dateComponents![1], cvv: cvv.text!)
                    
                    self.loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
                    self.loadingAnimator!.mode = .indeterminate
                    self.loadingAnimator!.labelText = "Getting card token..."
                    
                    cardClient.tokenizeCard(card) { (tokenizedCard, error) in
                        // Communicate the tokenizedCard.nonce to your server, or handle error
                        if (error == nil) {
                            var cardImage = UIImage(named: tokenizedCard!.type)
                            if (cardImage == nil) {
                                cardImage = UIImage(named: "DefaultCreditCard")
                            }
                            if (tokenizedCard!.type == "AMEX") {
                                cardImage = UIImage(named: "American Express")
                            }
                            
                            self.cardImage.image = cardImage
                            self.loadingAnimator!.labelText = "Uploading..."
                            var parameters = [String : Any]()
                            parameters["payment_nonce"] = tokenizedCard!.nonce
                            parameters["description"] = self.cardDescription.text
                            WebService.instance.delegate = self
                            WebService.instance.addCard(parameters)
                        }
                        else {
                            self.loadingAnimator!.hide(true)
                            Util.showAlertMessage(APP_TITLE, message: error!.localizedDescription, parent: self)
                        }
                    }
                }
                else {
                    Util.showAlertMessage(APP_TITLE, message: "Invalide expiration date format.", parent: self)
                }
            } else {
                Util.showAlertMessage(APP_TITLE, message: "Unable to create braintreeClient. Check that tokenization key or client token is valid.", parent: self)
            }
        }
        else {
            let cardDescription = paymentData!["description"] as! String
            if (self.cardDescription.text != cardDescription) {
                self.loadingAnimator = MBProgressHUD.showAdded(to: self.view.window!, animated: true)
                self.loadingAnimator!.mode = .indeterminate
                self.loadingAnimator!.labelText = "Updating..."
                
                var parameters = [String : Any]()
                parameters["description"] = self.cardDescription.text
                parameters["card_uuid"] = paymentData!["uuid"] as! String
                WebService.instance.delegate = self
                WebService.instance.updateCard(parameters)
            }
        }
    }
    
    //////////////////////////////
    
    //  WebServiceDelegate
    
    func onSuccess(apiName: String, data: AnyObject) {
        loadingAnimator!.hide(true)
        switch apiName {
        case "addCard":
            CardManager.instance.addCard(data as! [String : Any])
            delegate!.onAddNewCard()
            navigationController!.popViewController(animated: true)
            break
        case "deleteCard":
            Util.showAlertMessageWithCallback(APP_TITLE, message: "Card is removed successfully!", parent: self) {
                CardManager.instance.removeCard(self.paymentData!)
                self.navigationController!.popViewController(animated: true)
            }
            break
        case "updateCard":
            Util.showAlertMessageWithCallback(APP_TITLE, message: "Card is updated successfully!", parent: self) {
                CardManager.instance.updateCard(self.cardIndex!, newCard: data as! [String : Any])
                self.navigationController!.popViewController(animated: true)
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
        case "addCard":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
        case "deleteCard":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
        case "updateCard":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    //////////////////////////////
    
    //  UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (isNew == true) {
            if (textField.tag == 3) {
                textField.resignFirstResponder()
            }
            else {
                dataFields[textField.tag + 1].becomeFirstResponder()
            }
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.tag == 0) {
            return true
        }
        
        var maxLength: Int!
        
        switch (textField.tag) {
        case 1:
            maxLength = 16
            break
        case 2:
            maxLength = 5
            break
        case 3:
            maxLength = 4
            break
        default:
            break
        }
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= maxLength // Bool
    }
    
    @IBAction func onEditingChanged(_ sender: AnyObject) {
        let textField = sender as! UITextField
        let v = CreditCardValidator()
        var brandImage: UIImage!
        
        if v.validate(string: textField.text!) {
            if let type = v.type(from: textField.text!) {
                if (type.name == "Amex") {
                    brandImage = UIImage(named: "American Express")
                }
                else {
                    brandImage = UIImage(named: type.name)
                }

                if (brandImage == nil) {
                    brandImage = UIImage(named: "DefaultCreditCard")
                }
            } else {
                brandImage = UIImage(named: "DefaultCreditCard")
            }
        } else {
            brandImage = UIImage(named: "DefaultCreditCard")
        }
        cardImage.image = brandImage
    }
    
    func addDoneButtonOnKeyboard() {
        let nextToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        nextToolbar.barStyle = UIBarStyle.blackTranslucent
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let next: UIBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(AddPaymentViewController.nextButtonAction))
        nextToolbar.items = [flexSpace, next]
        nextToolbar.sizeToFit()
        cardNo.inputAccessoryView = nextToolbar
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AddPaymentViewController.closeKeyboard))
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        cvv.inputAccessoryView = doneToolbar
    }
    
    func nextButtonAction() {
        expirationDate.becomeFirstResponder()
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    @IBAction func onRemoveCard(_ sender: AnyObject) {
        self.loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.loadingAnimator!.mode = .indeterminate
        self.loadingAnimator!.labelText = "Removing card..."
        
        var parameters = [String : Any]()
        parameters["card_uuid"] = paymentData!["uuid"]
        WebService.instance.delegate = self
        WebService.instance.deleteCard(parameters)
    }
    
    //////////////////////////////
}
