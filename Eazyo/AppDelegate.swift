//
//  AppDelegate.swift
//  Eazyo
//
//  Created by SoftDev0420 on 3/22/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import UserNotifications
import Rollbar
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        BuddyBuildSDK.setup()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        #if PRODUCTION
            Rollbar.initWithAccessToken("d93566a0d7484a979cec381625b3e6a7")
        #else
            Rollbar.initWithAccessToken("2d4a894bf7a6419c84aed56ca56df723")
            WebService.instance.checkStatus()
        #endif
        
        let userDefaults = UserDefaults.standard
        let authenticationToken = userDefaults.value(forKey: "authenticationToken") as? String
        if (authenticationToken != nil && authenticationToken != "") {
            let password = userDefaults.value(forKey: "password") as? String
            UserManager.instance.setPassword(password)
            WebService.instance.setAuthToken(authenticationToken!)
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let loadingViewController = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
            let navController = UINavigationController.init()
            navController.isNavigationBarHidden = true
            navController.pushViewController(loadingViewController, animated: true)
            window!.rootViewController = navController
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isBackground")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "isBackground")
        application.applicationIconBadgeNumber = 0
        
        let hasNotification = userDefaults.bool(forKey: "hasNotification")
        if (hasNotification == false) {
            if (window == nil || window!.rootViewController == nil) {
                return
            }
            let navigationController = window!.rootViewController! as? UINavigationController
            if (navigationController == nil) {
                return
            }
            
            let topViewControllerName = NSStringFromClass(navigationController!.topViewController!.classForCoder)
            if topViewControllerName.range(of: "MainTabViewController") != nil {
                let mainTabViewController = navigationController!.topViewController as! MainTabViewController
                if (mainTabViewController.selectedIndex == 1) {
                    let secondNavigationController = mainTabViewController.viewControllers![1] as! UINavigationController
                    if (secondNavigationController.viewControllers.count == 1) {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "showNotifiedOrder"), object: nil)
                    }
                }
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateApplePayStatus"), object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        var parameters = [String : Any]()
        parameters["device_token"] = token
        parameters["device_type"] = "ios"
        WebService.instance.updateUser(parameters)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
        let orderUuid = userInfo["orderUUID"] as? String
        if (orderUuid != nil && WebService.instance.authToken != "") {
            let userDefaults = UserDefaults.standard
            let isBackground = userDefaults.bool(forKey: "isBackground")
            if (isBackground) {
                userDefaults.set(true, forKey: "hasNotification")
                userDefaults.setValue(orderUuid, forKey: "orderUuid")
                goToMainTabView()
            }
            else {
                if (application.applicationState == .active) {
                    let apn = userInfo["aps"] as! NSDictionary
                    let alert = apn["alert"] as? String
                    showPushNotificationMessage(alert, orderUuid: orderUuid!)
                }
                else {
                    userDefaults.set(true, forKey: "hasNotification")
                    userDefaults.setValue(orderUuid, forKey: "orderUuid")
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let application = UIApplication.shared
        
        let orderUuid = userInfo["orderUUID"] as? String
        if (orderUuid != nil && WebService.instance.authToken != "") {
            let userDefaults = UserDefaults.standard
            let isBackground = userDefaults.bool(forKey: "isBackground")
            if (isBackground) {
                userDefaults.set(true, forKey: "hasNotification")
                userDefaults.setValue(orderUuid, forKey: "orderUuid")
                goToMainTabView()
            }
            else {
                if (application.applicationState == .active) {
                    let apn = userInfo["aps"] as! NSDictionary
                    let alert = apn["alert"] as? String
                    showPushNotificationMessage(alert, orderUuid: orderUuid!)
                }
                else {
                    userDefaults.set(true, forKey: "hasNotification")
                    userDefaults.setValue(orderUuid, forKey: "orderUuid")
                }
            }
        }
    }
    
    func showPushNotificationMessage(_ message: String?, orderUuid: String) {
        let alert = UIAlertController(title: "EazyO", message: message, preferredStyle: .alert)
        let openAction = UIAlertAction(title: "Open", style: .default) { (action) in
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: "hasNotification")
            userDefaults.setValue(orderUuid, forKey: "orderUuid")
            self.goToMainTabView()
        }
        alert.addAction(openAction)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        window!.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    func goToMainTabView() {
        let navigationController = window!.rootViewController! as! UINavigationController
        let topViewControllerName = NSStringFromClass(navigationController.topViewController!.classForCoder)
        if topViewControllerName.range(of: "MainTabViewController") != nil {
            let mainTabViewController = navigationController.topViewController as! MainTabViewController
            let secondNavigationController = mainTabViewController.viewControllers![1] as! UINavigationController
            secondNavigationController.popToRootViewController(animated: true)
            if (secondNavigationController.viewControllers.count == 1 && mainTabViewController.selectedIndex == 1) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "showNotifiedOrder"), object: nil)
            }
            mainTabViewController.selectedIndex = 1
        }
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
}

