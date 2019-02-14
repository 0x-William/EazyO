//
//  PaymentViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/24/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import PassKit

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


class PaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddPaymentDelegate {
    
    @IBOutlet weak var cardsTableView: UITableView!
    @IBOutlet weak var updateButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    var selectedPaymentIndex: Int?
    var paymentMethodCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = nil
        
        paymentMethodCount = CardManager.instance.getCardCount()
        paymentMethodCount = paymentMethodCount + Util.checkApplePay()
        paymentMethodCount = paymentMethodCount + Util.boolToInt(bool: UserManager.instance.isManager)
        
        cardsTableView.reloadData()
        enableUpdateButton(checkUpdatable())
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
        CardManager.instance.setSelectedCardIndex(selectedPaymentIndex!)
        navigationController!.popViewController(animated: true)
    }
    
    //////////////////////////////
    
    //  AddPaymentDelegate
    
    func onAddNewCard() {
//        if (UserManager.instance.isManager == true && CardManager.instance.getSelectedCardIndex() == CardManager.instance.getCardCount() - 1) {
//            CardManager.instance.setSelectedCardIndex(CardManager.instance.getCardCount())
//        }
//        selectedPaymentIndex = CardManager.instance.getCardCount() - 1
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethodCount + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < paymentMethodCount) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! SelectPaymentCell
            if (indexPath.row < CardManager.instance.cards.count) {
                cell.paymentName.text = CardManager.instance.cards[indexPath.row]["description"] as! String +
                    " ..." + (CardManager.instance.cards[indexPath.row]["last4"] as! String)
            }
            else if (indexPath.row + 1 == CardManager.instance.getCardCount() + Util.checkApplePay()) {
                cell.paymentName.text = "Apple Pay"
            }
            else if (indexPath.row + 1 == CardManager.instance.getCardCount() + Util.checkApplePay() + Util.boolToInt(bool: UserManager.instance.isManager)) {
                cell.paymentName.text = "Manager Comp"
            }
            
            if (indexPath.row == selectedPaymentIndex) {
                cell.selectImage.image = UIImage(named:"FilledRadioIcon")
            }
            else {
                cell.selectImage.image = UIImage(named:"RadioIcon")
            }
            
            cell.selectionStyle = .none
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddPaymentCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == paymentMethodCount) {
            let addPaymentViewController = storyboard!.instantiateViewController(withIdentifier: "AddPaymentViewController") as! AddPaymentViewController
            addPaymentViewController.isNew = true
            addPaymentViewController.delegate = self
            navigationController!.pushViewController(addPaymentViewController, animated: true)
        }
        else {
            if (indexPath.row != selectedPaymentIndex) {
                if (selectedPaymentIndex != -1) {
                    let cell = tableView.cellForRow(at: IndexPath(row: selectedPaymentIndex!, section: 0)) as? SelectPaymentCell
                    if (cell != nil) {
                        cell!.selectImage.image = UIImage(named:"RadioIcon")
                    }
                }
                let currentCell = tableView.cellForRow(at: indexPath) as! SelectPaymentCell
                currentCell.selectImage.image = UIImage(named:"FilledRadioIcon")
                selectedPaymentIndex = indexPath.row
            }
            enableUpdateButton(checkUpdatable())
        }
    }
    
    //////////////////////////////
    
    func checkUpdatable() -> Bool {
        if (CardManager.instance.getSelectedCardIndex() != selectedPaymentIndex) {
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
