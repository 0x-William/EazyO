//
//  MainTabViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/15/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class MainTabViewController: UITabBarController, UINavigationControllerDelegate {

    var venueInfo: [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let navigationController = self.viewControllers![0] as! UINavigationController
        let venueMenuViewController = navigationController.viewControllers[0] as! VenueMenuViewController
        venueMenuViewController.venueInfo = venueInfo
        
        let userDefaults = UserDefaults.standard
        let hasNotification = userDefaults.bool(forKey: "hasNotification")
        
        if (hasNotification) {
            selectedIndex = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
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
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            return nil
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return SlideAnimator(slideType: SLIDE_UP_PUSH)
        }
        
        return nil
    }
    
    //////////////////////////////
}
