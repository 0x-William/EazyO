//
//  CartManager.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/27/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class CartManager {

    static let instance = CartManager()
    
    var items: [CartItem]!
    var totalPrice: Float!
    
    init () {
        items = [CartItem]()
        _ = clearCart()
    }
    
    //  GetCategoryName
    
    func getCategoryName(uuid: String) -> String {
        if (VendorManager.instance.menu == nil) {
            return ""
        }
        else {
            let categories = VendorManager.instance.menu!["categories"] as? [[String : Any]]
            if (categories == nil || categories!.count == 0) {
                return ""
            }
            else {
                for category in categories! {
                    let items = category["items"] as! [[String : Any]]
                    let has = items.contains(where: { (item) -> Bool in
                        let sUuid = item["uuid"] as! String
                        return sUuid == uuid
                    })
                    if (has) {
                        return category["name"] as? String ?? ""
                    }
                }
                return ""
            }
        }
    }
    
    //  GetCartItem
    
    func getItem(_ index: Int) -> CartItem? {
        if (index >= getCartItemCount()) {
            return nil
        }
        return items[index]
    }
    
    //  GetItemCount
    
    func getCartItemCount() -> Int {
        return items.count
    }
    
    //  GetOrderedItemCount
    
    func getOrderedItemCount() -> Int {
        var orderedItem = 0
        for (_, itemInCart) in items.enumerated() {
            orderedItem += itemInCart.count
        }
        return orderedItem
    }
    
    //  AddCartItem
    
    func addToCart(_ item: CartItem) -> Int {
        if (!item.isPromotion) {
            let price = item.data!["price"] as! String
            
            var optionPrice: Float! = 0.0
            
            for option in item.selectedOptions {
                if(option.data != nil)
                {
                    optionPrice = optionPrice + Float(option.data["price"] as! String)!
                }
            }
            
            totalPrice = totalPrice + (Float(price)! + optionPrice)  * Float(item.count)
        }
        
        items.append(item)
        return getOrderedItemCount()
    }
    
    //  RemoveCartItem
    
//    func removeFromCart(item: CartItem) -> Int {
//        for (index, itemInCart) in items.enumerate() {
//            if (itemInCart.data["uuid"] as! String == item.data["uuid"] as! String) {
//                let price = itemInCart.data!["price"] as! String
//                totalPrice = totalPrice + Float(price)! * Float(itemInCart.count)
//                items.removeAtIndex(index)
//                break
//            }
//        }
//        return getOrderedItemCount()
//    }
    
    func removeFromCartWithIndex(_ index: Int) -> Int {
        if (!items[index].isPromotion) {
            let price = items[index].data!["price"] as! String
            let item = items[index]
            
            var optionPrice: Float! = 0.0
            for option in item.selectedOptions {
                if(option.data != nil)
                {
                    optionPrice = optionPrice + Float(option.data["price"] as! String)!
                }
            }
        
            totalPrice = totalPrice - (Float(price)! + optionPrice)  * Float(items[index].count)
        }
        
        items.remove(at: index)
        return getOrderedItemCount()
    }
    
    func clearCart() -> Int {
        items.removeAll()
        totalPrice = 0.0
        return 0
    }
    
    //  UpdateCartItem
    
    func updateItem(_ index:Int, item: CartItem) -> Int {
        if (!item.isPromotion) {
            let oldItem = getItem(index)
            let price = item.data!["price"] as! String
            
            var newOptionPrice: Float! = 0.0
            for option in item.selectedOptions {
                if(option.data != nil)
                {
                    newOptionPrice = newOptionPrice + Float(option.data["price"] as! String)!
                }
            }
            
            var oldOptionPrice: Float! = 0.0
            if (oldItem != nil) {
                for option in oldItem!.selectedOptions {
                    if(option.data != nil)
                    {
                        oldOptionPrice = oldOptionPrice + Float(option.data["price"] as! String)!
                    }
                }
                totalPrice = totalPrice - (Float(price)! + oldOptionPrice) * Float(oldItem!.count)
            }
            
            totalPrice = totalPrice + (Float(price)! + newOptionPrice) * Float(item.count)
        }
        
        items[index] = item
        return getOrderedItemCount()
    }
    
    //  GetTotalPrice
    
    func getTotalPrice() -> Float {
        return totalPrice
    }
    
    func getSummary() -> String {
        var summary = [String : Int]()
        for item in items {
            let categoryName = item.category
            if (summary[categoryName] == nil) {
                summary[categoryName] = 1
            }
            else {
                summary[categoryName] = summary[categoryName]! + 1
            }
        }
        
        var summaryString = ""
        for key in summary.keys {
            let count = summary[key]!
            summaryString = "\(summaryString), \(count) \(key)"
        }
        if (summaryString.characters.count > 2) {
            summaryString.remove(at: summaryString.startIndex)
            summaryString.remove(at: summaryString.startIndex)
        }
        
        return summaryString
    }
}
