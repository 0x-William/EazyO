//
//  CategoryMenuViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/12/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import MRProgress
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CategoryMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var cartItemCount: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    
    @IBOutlet weak var categoryItemsTableView: UITableView!
    @IBOutlet weak var categoryItemsListView: UITableView!
    
    var screenHeight: CGFloat?
    var screenWidth: CGFloat?
    
    var loadingAnimator : MBProgressHUD?
    var categoryData: [String : Any]?
    var categoryName: String?
    var items = [[String : Any]]()
    var categoryItemImages: [UIImage]?
    var loadedImageCount: Int = -1
    var totalItemCount: Int = 0
    var navigationType: Int = 0
    var loadingView: UIView?
    var progressView: MRActivityIndicatorView?
    var viewType = "list"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryName = categoryData!["name"] as? String ?? ""
        categoryTitle.text = categoryName

        categoryItemsListView.tableFooterView = UIView()
        categoryItemImages = [UIImage]()
        
        if (categoryData != nil) {
            viewType = categoryData!["display_type"] as? String ?? "list"
            items = categoryData!["items"] as! [[String : Any]]
            if (viewType == "grid") {
                totalItemCount = items.count
                loadedImageCount = 0
                
                for _ in items {
                    categoryItemImages!.append(UIImage())
                }
                
                for i in 0...categoryItemImages!.count - 1 {
                    if let imageUrl = items[i]["thumb_url"] as? String {
                        Alamofire.request(imageUrl)
                            .responseImage { response in
                                self.checkSum()
                                if let image = response.result.value {
                                    self.categoryItemImages![i] = image
                                }
                        }
                    }
                    else {
                        self.checkSum()
                    }
                }
            }
            else {
                categoryItemsListView.isHidden = false
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self
        tabBarController!.tabBar.isHidden = false
        updateCartCount(CartManager.instance.getOrderedItemCount())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (viewType == "grid") {
            if (loadedImageCount < totalItemCount) {
                screenHeight = UIScreen.main.bounds.height
                screenWidth = UIScreen.main.bounds.width
//                loadingView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth!, height: screenHeight!))
//                loadingView!.backgroundColor = UIColor.clear
//                progressView = MRActivityIndicatorView(frame: CGRect(x: screenWidth! * 3 / 8, y: (screenHeight! - screenWidth! / 4) / 2 - 8, width: screenWidth! / 4, height: screenWidth! / 4))
//                progressView!.tintColor = UIColor.eazyoOrangeColor()
//                progressView!.startAnimating()
//                loadingView!.addSubview(progressView!)
//                
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.window!.addSubview(loadingView!)
            }
            else {
//                categoryItemsTableView.isHidden = false
                categoryItemsTableView.reloadData()
            }
        }
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
    
    @IBAction func onCart(_ sender: AnyObject) {
        if (CartManager.instance.getCartItemCount() == 0) {
            Util.showAlertMessage(APP_TITLE, message: "Your cart is empty now.", parent: self)
            return
        }
        
        navigationType = 1
        let receiptViewController = storyboard!.instantiateViewController(withIdentifier: "ReceiptViewController") as! ReceiptViewController
        navigationController!.pushViewController(receiptViewController, animated: true)
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            if (navigationType == 1) {
                return SlideAnimator(slideType: SLIDE_UP_PUSH)
            }
            else {
                return nil
            }
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return nil
        }
        
        return nil
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoryData == nil {
            return 0
        }
        else {
            if (viewType == "grid") {
                if (tableView.tag == 0 && loadedImageCount == totalItemCount) {
                    return 1 + Int(ceil((Float)(items.count) / 2))
                }
                else {
                    return 0
                }
            }
            else {
                if (tableView.tag == 0) {
                    return 0
                }
                else {
                    return items.count
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView.tag == 0) {
            if (indexPath.row == 0) {
                return 10.0
            }
            else {
                return 206.0
            }
        }
        else {
            return 54.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.tag == 0) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Header", for: indexPath)
                cell.selectionStyle = .none
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryItemCell", for: indexPath) as! CategoryItemCell
                cell.firstItemName.text = items[(indexPath.row - 1) * 2]["name"] as? String
                var price = items[(indexPath.row - 1) * 2]["price"] as? String
                var floatPrice = Float(price!)
                cell.firstItemPrice.text = "$" + Util.stringWithPlaceCount(floatPrice!, placeCount: 2)
                cell.firstButton.tag = (indexPath.row - 1) * 2
                cell.firstItemImage.image = categoryItemImages![(indexPath.row - 1) * 2]
                
                cell.secondItemView.isHidden = true
                if (indexPath.row * 2 - 1 < items.count) {
                    cell.secondItemName.text = items[indexPath.row * 2 - 1]["name"] as? String
                    price = items[indexPath.row * 2 - 1]["price"] as? String
                    floatPrice = Float(price!)
                    cell.secondItemPrice.text = "$" + Util.stringWithPlaceCount(floatPrice!, placeCount: 2)
                    cell.secondButton.tag = indexPath.row * 2 - 1
                    cell.secondItemImage.image = categoryItemImages![indexPath.row * 2 - 1]
                    cell.secondItemView.isHidden = false
                }
                cell.selectionStyle = .none
                
                return cell
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! CategoryListItemCell
            cell.foodName.text = items[indexPath.row]["name"] as? String
            let price = items[indexPath.row]["price"] as? String
            let floatPrice = Float(price!)
            cell.foodPrice.text = "$" + Util.stringWithPlaceCount(floatPrice!, placeCount: 2)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let foodDetailViewController = storyboard!.instantiateViewController(withIdentifier: "FoodDetailViewController") as! FoodDetailViewController
        foodDetailViewController.navigationType = 0
        foodDetailViewController.oriItem = CartItem(itemData: items[indexPath.row], categoryName: categoryName!, itemImage: UIImage())
        navigationController!.pushViewController(foodDetailViewController, animated: true)
    }
    
    @IBAction func onFoodItem(_ sender: AnyObject) {
        navigationType = 0
        let button = sender as! UIButton
        let foodDetailViewController = storyboard!.instantiateViewController(withIdentifier: "FoodDetailViewController") as! FoodDetailViewController
        foodDetailViewController.navigationType = 0
        foodDetailViewController.oriItem = CartItem(itemData: items[button.tag], categoryName: categoryName!, itemImage: UIImage())
        navigationController!.pushViewController(foodDetailViewController, animated: true)
    }
    
    //////////////////////////////
    
    func checkSum() {
        loadedImageCount = loadedImageCount + 1
        if (loadedImageCount == totalItemCount) {
            if (loadingView != nil) {
                progressView!.stopAnimating()
                loadingView!.isHidden = true
            }
//            categoryItemsTableView.isHidden = false
            categoryItemsTableView.reloadData()
        }
    }
    
    func updateCartCount(_ count: Int) {
        if (count == 0) {
            cartItemCount.text = ""
        }
        else {
            cartItemCount.text = String(count)
        }
        subTotal.text = "$" + String(format: "%.2f", CartManager.instance.totalPrice)
    }
    
    //////////////////////////////
}
