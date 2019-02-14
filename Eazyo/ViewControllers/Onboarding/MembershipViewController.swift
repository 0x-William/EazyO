//
//  MembershipViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/24/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import MBProgressHUD

class MembershipViewController: UIViewController, UINavigationControllerDelegate, WebServiceDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var askLabel: UILabel!
    @IBOutlet var membershipNumbers: [UILabel]!
    @IBOutlet weak var tempInputField: UITextField!
    @IBOutlet weak var padView: UIView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var padButton: UIButton!
    @IBOutlet weak var cloud: UIImageView!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var welcomeText: UILabel!
    
    @IBOutlet weak var commentLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var padViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var numberTopConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var cloudTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleImageCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeTextTopConstraint: NSLayoutConstraint!
    
    var loadingAnimator: MBProgressHUD?
    
    var venueInfo: [String : Any]?
    var height: CGFloat = UIScreen.main.bounds.height - 64
    var width: CGFloat = UIScreen.main.bounds.width
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(MembershipViewController.closeKeyboard))
        contentView.addGestureRecognizer(singleTap)
        
        cloudTopConstraint.constant = -width * 130 / 375
        circleImageHeightConstraint.constant = height * (-0.116)
        circleImageCenterConstraint.constant = width * 130 / 375 + height * 0.116
        checkImageHeightConstraint.constant = height * (-0.039)
        welcomeTextTopConstraint.constant = width * 130 / 375 + height * 0.232 + 75
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tempInputField.becomeFirstResponder()
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
            return SlideAnimator(slideType: SLIDE_DOWN_PUSH)
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
        case "validateVendorCode":
            let dataObject = data as! [String : Any]
            if dataObject["valid"] as! Bool == true {
                if dataObject["membership_type"] as! String == "member" {
                    ReceiptManager.instance.discountPercent = dataObject["discount_percentage"] as! Float
                }
                
                UserManager.instance.memberCode = tempInputField.text
                
                ReceiptManager.instance.acceptTips = venueInfo!["accept_tips"] as! Bool
                ReceiptManager.instance.baseTax = venueInfo!["base_sales_tax"] as! Float
                ReceiptManager.instance.resortTax = venueInfo!["resort_tax"] as! Float
                ReceiptManager.instance.taxServiceFee = venueInfo!["tax_service_fee"] as! Bool
                ReceiptManager.instance.tax = venueInfo!["sales_tax"] as! Float
                ReceiptManager.instance.serviceFee = venueInfo!["service_fee"] as! Float
                
                makeSuccessAnimation(0)
            }
            else {
                let alert = UIAlertController(title: APP_TITLE, message: "Oop! Try again.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.tempInputField.text = ""
                })
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
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
        case "validateVendorCode":
            Util.showAlertMessage(APP_TITLE, message: alertMessage, parent: self)
            break
            
        default:
            break
        }
    }
    
    func makeSuccessAnimation(_ index: Int) {
        let viewHeight = membershipNumbers[index].frame.size.height
        numberTopConstraints[index].constant = viewHeight - 10
        var delay = 0.0
        if (index == 0) {
            delay = 0.5
        }
        UIView.animate(withDuration: 0.3, delay: delay, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: {(completed: Bool) -> Void in
                if (index < 2) {
                    self.makeSuccessAnimation(index + 1)
                }
                else {
                    self.maskView.isHidden = true
                    self.makeFinalAnimation()
                }
        })
    }
    
    func makeFinalAnimation() {
        commentLabelTopConstraint.constant = -height * 0.124 - 64 - 20
        padViewTopConstraint.constant = padView.frame.size.height
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.padView.alpha = 0.0
            self.commentLabel.alpha = 0.0
            self.askLabel.alpha = 0.0
            }, completion: {(completed: Bool) -> Void in
                self.cloudTopConstraint.constant = 4.0
                self.checkImageHeightConstraint.constant = 0.0
                self.welcomeTextTopConstraint.constant = self.welcomeTextTopConstraint.constant - 60.0
                UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
                    self.checkImage.alpha = 1.0
                    self.welcomeText.alpha = 1.0
                    }, completion: {(completed: Bool) -> Void in
                })
                UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: {(completed: Bool) -> Void in
                        self.moveToDeliveryPlaceView()
                })
                self.circleImageHeightConstraint.constant = 0.0
                UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
                    self.circleImage.layoutIfNeeded()
                    self.circleImage.alpha = 1.0
                    self.cloud.alpha = 1.0
                    }, completion: {(completed: Bool) -> Void in
                })
        })
    }
    
    func moveToDeliveryPlaceView() {
        let deliveryPlaceViewController = storyboard!.instantiateViewController(withIdentifier: "DeliveryPlaceViewController") as! DeliveryPlaceViewController
        deliveryPlaceViewController.venueInfo = venueInfo
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.padButton.alpha = 0.0
        }, completion: {(completed: Bool) -> Void in
            self.navigationController!.pushViewController(deliveryPlaceViewController, animated: true)
        })
    }
    
    func moveToMainTabView() {
        let mainTabViewController = storyboard!.instantiateViewController(withIdentifier: "MainTabViewController") as! MainTabViewController
        mainTabViewController.venueInfo = venueInfo
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .curveEaseOut, animations: {
            self.padButton.alpha = 0.0
        }, completion: {(completed: Bool) -> Void in
            self.navigationController!.pushViewController(mainTabViewController, animated: true)
        })
    }
    
    //////////////////////////////
    
    //  UITextFieldDelegate
    
    @IBAction func onPinCodeChanged(_ sender: AnyObject) {
        let pinCode = tempInputField.text
        let codeLength = pinCode!.characters.count
        
        if (codeLength > 0) {
            for i in 0...codeLength - 1 {
                membershipNumbers[i].text = String((pinCode! as NSString).character(at: i) - 48)
            }
        }
        if (codeLength < 3) {
            for i in codeLength...2 {
                membershipNumbers[i].text = " "
            }
        }
        else {
            validateCode()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 3 // Bool
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    //////////////////////////////
    
    @IBAction func onNumerPad(_ sender: AnyObject) {
        tempInputField.becomeFirstResponder()
    }
    
    func validateCode() {
        loadingAnimator = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingAnimator!.mode = .text
        loadingAnimator!.labelText = "Loading..."
        
        var parameters = [String : Any]()
        parameters["vendorUuid"] = venueInfo!["uuid"] as? String
        var code = ""
        for number in membershipNumbers {
            code = code + number.text!
        }
        parameters["code"] = code
        
        WebService.instance.delegate = self
        WebService.instance.validateVendorCode(parameters)
    }
    
    //////////////////////////////
}
