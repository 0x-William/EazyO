//
//  RoomNumberViewController.swift
//  Eazyo
//
//  Created by SoftDev on 8/15/17.
//  Copyright © 2017 SoftDev0420. All rights reserved.
//

import UIKit

class RoomNumberViewController: UIViewController {

    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var roomNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        roomNumber.text = ReceiptManager.instance.roomNumber
        enableUpdateButton(checkUpdatable())
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
        ReceiptManager.instance.roomNumber = roomNumber.text!
        navigationController!.popViewController(animated: true)
    }
    
    //////////////////////////////
    
    func checkUpdatable() -> Bool {
        if (ReceiptManager.instance.roomNumber != roomNumber.text) {
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
    
    @IBAction func onRoomNumberChanged(_ sender: UITextField) {
        enableUpdateButton(checkUpdatable())
    }
    
    //////////////////////////////
}
