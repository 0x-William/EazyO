//
//  ExtraInfoViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/14/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

protocol ExtraInfoDelegate {
    func onExtraInfo(_ extraInfo: String)
}

class ExtraInfoViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var extraInfo: UITextView!
    @IBOutlet weak var placeholder: UILabel!
    
    @IBOutlet weak var extraInfoBottomConstraint: NSLayoutConstraint!
    
    var delegate: ExtraInfoDelegate?
    var specialInstruction: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if (specialInstruction != "") {
            extraInfo.text = specialInstruction
            placeholder.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(ExtraInfoViewController.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(ExtraInfoViewController.keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        enableSaveButton(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self;
        tabBarController!.tabBar.isHidden = true
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
    
    @IBAction func onClose(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        delegate?.onExtraInfo(extraInfo.text)
        navigationController!.popViewController(animated: true)
    }
    
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
    
    //  UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = !textView.text.isEmpty
        enableSaveButton(checkSaveable())
    }
    
    func keyboardWillAppear(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo!
        let keyboardFrameBegin: CGRect = (keyboardInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrameBegin.size.height
        extraInfoBottomConstraint.constant = -10 - keyboardHeight
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillDisappear(_ notification: Notification) {
        extraInfoBottomConstraint.constant = -10
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    //////////////////////////////
    
    func checkSaveable() -> Bool {
        if (specialInstruction == extraInfo.text) {
            return false
        }
        else {
            return true
        }
    }
    
    func enableSaveButton(_ enable: Bool) {
        if (enable == true) {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
            saveButton.setTitleColor(UIColor.eazyoOrangeColor(), for: UIControlState())
        }
        else {
            saveButton.isEnabled = false
            saveButton.alpha = 0.4
            saveButton.setTitleColor(UIColor.eazyoCoolGreyColor(), for: UIControlState())
        }
    }
    
    //////////////////////////////
}
