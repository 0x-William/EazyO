//
//  ForgotPasswordViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 6/30/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, UINavigationControllerDelegate, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = URL(string: "https://app.eazyoapp.com/forgot")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        loadingIndicator.startAnimating()
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
    
    //  NavigationBar
    
    @IBAction func onClose(_ sender: AnyObject) {
        navigationController!.popViewController(animated: true)
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
    
    //  UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        webView.isHidden = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        errorLabel.isHidden = false
    }
    
    //////////////////////////////
}
