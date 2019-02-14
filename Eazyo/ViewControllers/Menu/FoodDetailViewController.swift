//
//  FoodDetailViewController.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/13/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit
import Alamofire


class FoodDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, ExtraInfoDelegate {

    @IBOutlet weak var cartItemCount: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    
    @IBOutlet weak var foodTitle: UILabel!
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var cartButton: UIButton!
    
    var oriItem, cartItem: CartItem?
    var cartIndex: Int?
    
    var groupedOptions = [[String : Any]]()
    var sides = [[String : Any]]()
    var width = UIScreen.main.bounds.width
    var navigationType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if (navigationType == 1) {
            cartItem = CartItem(item: oriItem!)
        }
        else {
            cartItem = oriItem
        }
        
        foodTitle.text = cartItem!.data!["name"] as? String
        
        let groupedOptionsData = cartItem!.data!["grouped_options"] as? [[String : Any]]
        if (groupedOptionsData != nil) {
            groupedOptions = groupedOptionsData!
        }
        
        let sidesData = cartItem!.data!["sides"] as? [[String : Any]]
        if (sidesData != nil) {
            sides = sidesData!
        }
        
        let headerView: ParallaxHeaderView = ParallaxHeaderView.parallaxHeaderView(with: cartItem!.image, for: CGSize(width: width, height: 213), withPadding: 10) as! ParallaxHeaderView
        
        if (cartItem!.image!.size.height == 0) {
            if let imageUrl = cartItem!.data!["image_url"] as? String {
                self.foodTableView.tableHeaderView = headerView
                Alamofire.request(imageUrl)
                    .responseImage { response in
                        if let image = response.result.value {
                            self.cartItem!.image = image
                            headerView.headerImage = image
                            headerView.layer.cornerRadius = 3
                            headerView.clipsToBounds = true
                            
                            headerView.setNeedsLayout()
                            headerView.layoutIfNeeded()
                            headerView.autoresizesSubviews = true
                        }
                }
            }
        }
        else {
            self.foodTableView.tableHeaderView = headerView
        }
        
        //render cta price
        updateCTAPrice()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController!.delegate = self;
        tabBarController!.tabBar.isHidden = true
        foodTableView.reloadData()
        
        updateCartCount(CartManager.instance.getOrderedItemCount())
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
        if (navigationType == 1) {
            navigationController!.popViewController(animated: true)
        }
        else {
            if (CartManager.instance.getCartItemCount() == 0) {
                Util.showAlertMessage(APP_TITLE, message: "Your cart is empty now.", parent: self)
                return
            }
            
            let receiptViewController = storyboard!.instantiateViewController(withIdentifier: "ReceiptViewController") as! ReceiptViewController
            navigationController!.pushViewController(receiptViewController, animated: true)
        }
    }
    
    //////////////////////////////
    
    //  UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == UINavigationControllerOperation.push) {
            return SlideAnimator(slideType: SLIDE_UP_PUSH)
        }
        
        if (operation == UINavigationControllerOperation.pop) {
            return nil
        }
        
        return nil
    }
    
    //////////////////////////////
    
    //  ExtraInfoDelegate
    
    func onExtraInfo(_ extraInfo: String) {
        cartItem!.extraInfo = extraInfo
    }
    
    //////////////////////////////
    
    //  UIScrollViewDelegate
    
    func  scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let header = self.foodTableView.tableHeaderView as? ParallaxHeaderView {
            header.layoutHeaderView(forScrollOffset: scrollView.contentOffset)
            self.foodTableView.tableHeaderView = header
        }
    }
    
    //////////////////////////////
    
    //  UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 + Util.sign(sides.count) + groupedOptions.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        else if (section >= 1 + Util.sign(sides.count) + groupedOptions.count) {
            return 2
        }
        else if (section > 0 && section < groupedOptions.count + 1) {
            return Util.sign((groupedOptions[section - 1]["items"] as! [[String : Any]]).count) + (groupedOptions[section - 1]["items"] as! [[String : Any]]).count
        }
        else {
            return 1 + sides.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch (indexPath.section) {
        case 0:
            return 40 + Util.heightForView((cartItem!.data!["description"] as? String)!, font: UIFont(name: "OpenSans", size: 14.0)!, width: width - 20)
        default:
            if (indexPath.row == 0) {
                return 55
            }
            else {
                if (section == 2 + Util.sign(sides.count) + groupedOptions.count) {
                    return 55
                }
                else {
                    return 40
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if (section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FoodInfoCell", for: indexPath) as! FoodInfoCell
            if (cartItem != nil) {
                cell.name.text = cartItem!.data!["name"] as? String
                let price = cartItem!.data!["price"] as? String ?? "0.00"
                let floatPrice = Float(price) ?? 0.00
                cell.price.text = "$" + Util.stringWithPlaceCount(floatPrice, placeCount: 2)
                cell.info.text = cartItem!.data!["description"] as? String
            }
            
            cell.selectionStyle = .none
        
            return cell
        }
        else if (section == 1 + Util.sign(sides.count) + groupedOptions.count) {
            if (row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleCell", for: indexPath) as! SectionTitleCell
                cell.optionTitle.text = "SPECIAL INSTRUCTIONS"
                
                cell.selectionStyle = .none
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExtraInfoCell", for: indexPath) as! ExtraInfoCell
                cell.extraInfo.text = cartItem!.extraInfo
                
                cell.selectionStyle = .none
                
                return cell
            }
        }
        else if (section == 2 + Util.sign(sides.count) + groupedOptions.count) {
            if (row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleCell", for: indexPath) as! SectionTitleCell
                cell.optionTitle.text = "QUANTITY"
                
                cell.selectionStyle = .none
                cell.isHidden = cartItem!.isPromotion
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "QuantityCell", for: indexPath) as! QuantityCell
                cell.quantity.text = String(cartItem!.count)
                
                cell.selectionStyle = .none
                cell.isHidden = cartItem!.isPromotion
                
                return cell
            }
        }
        else if (sides.count > 0 && section == 1 + groupedOptions.count) {
            if (row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleCell", for: indexPath) as! SectionTitleCell
                let maxSideCount = cartItem!.data!["max_sides"] as! Int
                if (maxSideCount > 1) {
                    cell.optionTitle.text = "SELECT \(maxSideCount) SIDES"
                }
                else {
                    cell.optionTitle.text = "SELECT \(maxSideCount) SIDE"
                }
                
                cell.selectionStyle = .none
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionCell
                cell.option.text = sides[row - 1]["name"] as? String
                cell.status.image = UIImage(named: "InactiveCheckIcon")
                cell.option.font = UIFont(name: "OpenSans", size: 14.0)
                cell.bonus.text = ""
                
                for side in cartItem!.additionalSides {
                    if (side.index == row - 1) {
                        cell.status.image = UIImage(named: "ActiveCheckIcon")
                        cell.option.font = UIFont(name: "OpenSans-Bold", size: 14.0)
                    }
                }
                
                cell.selectionStyle = .none
                
                return cell
            }
        }
        else {
            if (row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTitleCell", for: indexPath) as! SectionTitleCell
                let optionTitle = groupedOptions[section - 1]["title"] as? String ?? ""
                cell.optionTitle.text = optionTitle.uppercased()
                cell.selectionStyle = .none
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionCell
                let items = groupedOptions[section - 1]["items"] as! [[String : Any]]
                
                cell.option.text = items[row - 1]["name"] as? String
                let selectionType = groupedOptions[section - 1]["select_type"] as! String
                
                var selectedOption: FoodExtraItem?
                
                for option in cartItem!.selectedOptions {
                    if (option.section == section - 1 && option.index == row - 1) {
                        selectedOption = option
                    }
                }
                
                if (selectedOption != nil) {
                    if (selectionType == "multi") {
                        cell.status.image = UIImage(named: "ActiveCheckIcon")
                    }
                    else {
                        cell.status.image = UIImage(named: "FilledRadioIcon")
                    }
                    cell.option.font = UIFont(name: "OpenSans-Bold", size: 14.0)
                }
                else {
                    if (selectionType == "multi") {
                        cell.status.image = UIImage(named: "InactiveCheckIcon")
                    }
                    else {
                        cell.status.image = UIImage(named: "RadioIcon")
                    }
                    cell.option.font = UIFont(name: "OpenSans", size: 14.0)
                }
                
                let optionPriceInString = (items[row - 1]["price"] as? String)!
                let floatOptionPrice = Float(optionPriceInString)
                if (floatOptionPrice != 0.0) {
                    cell.bonus.text = "+ $" + Util.stringWithPlaceCount(floatOptionPrice!, placeCount: 2)
                }
                else {
                    cell.bonus.text = ""
                }
                
                cell.selectionStyle = .none
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if (section == 0) {
            return
        }
        else if (section == 1 + Util.sign(sides.count) + groupedOptions.count) {
            let extraInfoViewController = storyboard!.instantiateViewController(withIdentifier: "ExtraInfoViewController") as! ExtraInfoViewController
            extraInfoViewController.specialInstruction = cartItem!.extraInfo
            extraInfoViewController.delegate = self
            navigationController!.pushViewController(extraInfoViewController, animated: true)
        }
        else if (section == 2 + Util.sign(sides.count) + groupedOptions.count) {
            
        }
        else if (sides.count > 0 && section == 1 + groupedOptions.count) {
            if (row != 0) {
                let cell = tableView.cellForRow(at: indexPath) as! OptionCell
                for side in cartItem!.additionalSides {
                    if (side.index == indexPath.row - 1) {
                        cell.status.image = UIImage(named: "InactiveCheckIcon")
                        cell.option.font = UIFont(name: "OpenSans", size: 14.0)
                        cartItem!.additionalSides.remove(at: cartItem!.additionalSides.index(of: side)!)
                        return
                    }
                }
                if (cartItem!.additionalSides.count < cartItem!.data!["max_sides"] as! Int) {
                    cell.status.image = UIImage(named: "ActiveCheckIcon")
                    cell.option.font = UIFont(name: "OpenSans-Bold", size: 14.0)
                    cartItem!.additionalSides.append(FoodExtraItem(itemSection: 0, itemIndex: indexPath.row - 1, itemData:sides[indexPath.row - 1]))
                }
            }
        }
        else {
            if (row != 0) {
                var selectedOption: FoodExtraItem?
                
                let selectionType = groupedOptions[section - 1]["select_type"] as? String
                let items = groupedOptions[section - 1]["items"] as! [[String : Any]]
                
                if (selectionType == "multi") {
                    for option in cartItem!.selectedOptions {
                        if (option.section == section - 1 && option.index == row - 1) {
                            selectedOption = option
                        }
                    }
                    if (selectedOption == nil) {
                        selectedOption = FoodExtraItem(itemSection: section - 1, itemIndex: row - 1, itemData: items[row - 1])
                        cartItem!.selectedOptions.append(selectedOption!)
                    }
                    else {
                        cartItem!.selectedOptions.remove(at: cartItem!.selectedOptions.index(of: selectedOption!)!)
                    }
                }
                else {
                    for option in cartItem!.selectedOptions {
                        if (option.section == section - 1) {
                            selectedOption = option
                        }
                    }
                    if (selectedOption == nil) {
                        selectedOption = FoodExtraItem(itemSection: section - 1, itemIndex: row - 1, itemData: items[row - 1])
                        cartItem!.selectedOptions.append(selectedOption!)
                    }
                    else {
                        selectedOption!.data = items[row - 1]
                        selectedOption!.index = row - 1
                    }
                }
                
                foodTableView.reloadData()
            }
        }
        
        //update cta price in case options changed
        updateCTAPrice()
    }
    
    //////////////////////////////
    
    // Quantity
    
    @IBAction func onMinus(_ sender: AnyObject) {
        if (cartItem!.count != 1) {
            cartItem!.count = cartItem!.count - 1
            foodTableView.reloadData()
            updateCTAPrice()
        }
    }
    
    @IBAction func onPlus(_ sender: AnyObject) {
        cartItem!.count = cartItem!.count + 1
        foodTableView.reloadData()
        updateCTAPrice()
    }
    
    func updateCTAPrice(){
        var priceString = "0.00"
        if (!cartItem!.isPromotion) {
            var optionPrice: Float = 0.00
            for option in cartItem!.selectedOptions {
                if(option.data != nil)
                {
                    optionPrice = optionPrice + Float(option.data["price"] as! String)!
                }
            }
            
            //(item price + option price) * item count
            let price = (Float((cartItem!.data!["price"] as? String!)!)! + optionPrice) * Float(cartItem!.count)
            
            priceString = String(format: "%.2f", price)
        }
        
        
        if (navigationType == 0 || navigationType == 2) {
            cartButton.setTitle("Add to Cart : $\(priceString)", for: UIControlState())
        }
        else {
            cartButton.setTitle("Save Changes : $\(priceString)", for: UIControlState())
        }
        
    }
    
    //////////////////////////////
    
    // Carts
    
    @IBAction func onAddToCart(_ sender: AnyObject) {
        if (navigationType == 0 || navigationType == 2) {
            updateCartCount(CartManager.instance.addToCart(cartItem!))
            for (_, viewController) in (navigationController!.viewControllers.enumerated()) {
                if (viewController.isKind(of: VenueMenuViewController.self)) {
                    let venueMenuViewController = viewController as! VenueMenuViewController
                    venueMenuViewController.isAddedItem = true
                    navigationController!.popToViewController(venueMenuViewController, animated: true)
                    break
                }
            }
        }
        else {
            _ = CartManager.instance.updateItem(cartIndex!, item: cartItem!)
            navigationController!.popViewController(animated: true)
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
