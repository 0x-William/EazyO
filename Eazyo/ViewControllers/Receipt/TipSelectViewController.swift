//
//  TipSelectViewController.swift
//  Eazyo
//
//  Created by SoftDev on 2/3/17.
//  Copyright © 2017 SoftDev0420. All rights reserved.
//

import UIKit

class TipSelectViewController: UIViewController {

    @IBOutlet weak var tipText: UILabel!
    @IBOutlet var tipButtons: [UIButton]!
    @IBOutlet var dots: [UIButton]!
    
    var receiptViewController: ReceiptViewController?
    
    var screenWidth = UIScreen.main.bounds.width
    let tipLevelDataSource = ReceiptManager.instance.tipValues
    var tipAmount: Float = 0.0
    var totalPrice: Float = 0.0
    var currentTipIndex = 0
    let selectedColor = UIColor.eazyoOrangeColor()
    let unselectedColor = UIColor.eazyoGreyColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for (index, button) in tipButtons.enumerated() {
            if (index == currentTipIndex) {
                tipButtons[index].setTitleColor(UIColor.eazyoOrangeColor(), for: .normal)
                tipButtons[index].layer.borderColor = UIColor.eazyoOrangeColor().cgColor
            }
            else {
                tipButtons[index].layer.borderColor = UIColor.eazyoGreyColor().cgColor
            }
            button.layer.borderWidth = 3.0
            button.layer.cornerRadius = screenWidth * 0.099
            if (index < 3) {
                button.setTitle(tipLevelDataSource[index].description + "%", for: .normal)
            }
        }
        
        for dot in dots {
            dot.layer.cornerRadius = screenWidth * 0.01
        }
        
        if (currentTipIndex == 3) {
            tipText.text = String(format: "$%.2f", tipAmount)
            for dot in dots {
                dot.backgroundColor = UIColor.eazyoOrangeColor()
            }
        }
        else {
            let tipLevel = tipLevelDataSource[currentTipIndex]
            tipAmount = totalPrice * Float(tipLevel) * 0.01
            tipText.text = String(format: "$%.2f", tipAmount)
        }
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
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApplyTip(_ sender: Any) {
        receiptViewController!.tipIndex = currentTipIndex
        receiptViewController!.tipPrice = tipAmount
        receiptViewController!.tipUpdate()
        dismiss(animated: true, completion: nil)
    }
    
    //////////////////////////////
    
    @IBAction func onPercentSelect(_ sender: UIButton) {
        tipButtons[currentTipIndex].layer.borderColor = UIColor.eazyoGreyColor().cgColor
        tipButtons[currentTipIndex].setTitleColor(UIColor.eazyoGreyColor(), for: .normal)
        if (currentTipIndex == 3) {
            for dot in dots {
                dot.backgroundColor = UIColor.eazyoGreyColor()
            }
        }
        
        currentTipIndex = sender.tag
        
        tipButtons[currentTipIndex].layer.borderColor = UIColor.eazyoOrangeColor().cgColor
        tipButtons[currentTipIndex].setTitleColor(UIColor.eazyoOrangeColor(), for: .normal)
        
        let tipLevel = tipLevelDataSource[currentTipIndex]
        tipAmount = totalPrice * Float(tipLevel) * 0.01
        tipText.text = String(format: "$%.2f", tipAmount)
    }
    
    @IBAction func onAmountSelect(_ sender: UIButton) {
        tipButtons[currentTipIndex].layer.borderColor = UIColor.eazyoGreyColor().cgColor
        tipButtons[currentTipIndex].setTitleColor(UIColor.eazyoGreyColor(), for: .normal)
        
        currentTipIndex = 3
        tipButtons[3].layer.borderColor = UIColor.eazyoOrangeColor().cgColor
        for dot in dots {
            dot.backgroundColor = UIColor.eazyoOrangeColor()
        }
        
        let passwordAlert = UIAlertController(title: nil, message: "Enter Tip Amount", preferredStyle: .alert)
        passwordAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "$0.00"
            textField.keyboardType = .decimalPad
        })
        passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        passwordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let inputAmount = Float((passwordAlert.textFields![0] as UITextField).text!)
            if (inputAmount == nil) {
                Util.showAlertMessage("Error", message: "Input correct amount.", parent: self)
            }
            else {
                self.tipAmount = round(inputAmount! * 100) / 100
                self.tipText.text = String(format: "$%.2f", self.tipAmount)
            }
        }))
        
        self.present(passwordAlert, animated: true, completion: nil)
    }
    
    //////////////////////////////
}
