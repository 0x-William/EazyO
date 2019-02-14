//
//  CartItem.swift
//  Eazyo
//
//  Created by SoftDev0420 on 4/29/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

class CartItem {
    var data: [String : Any]?
    var category: String = ""
    var image: UIImage?
    var count: Int!
    var selectedOptions: [FoodExtraItem]!
    var additionalSides: [FoodExtraItem]!
    var extraInfo: String!
    var totalPrice: Float!
    var isPromotion: Bool = false
    var promotionUuid: String = ""
    
    init(item: CartItem) {
        data = item.data
        category = item.category
        image = item.image
        count = item.count
        selectedOptions = [FoodExtraItem]()
        for option in item.selectedOptions {
            let newOption = FoodExtraItem(itemSection: option.section, itemIndex: option.index, itemData: option.data)
            selectedOptions.append(newOption)
        }
        additionalSides = [FoodExtraItem]()
        for side in item.additionalSides {
            let newSide = FoodExtraItem(itemSection: side.section, itemIndex: side.index, itemData: side.data)
            additionalSides.append(newSide)
        }
        extraInfo = item.extraInfo
        totalPrice = item.totalPrice
        
        isPromotion = item.isPromotion
        promotionUuid = item.promotionUuid
    }
    
    init (itemData: [String : Any]!, categoryName: String, itemImage: UIImage?) {
        data = itemData
        category = categoryName
        image = itemImage
        count = 1
        
        selectedOptions = [FoodExtraItem]()
        let groupedOptions = itemData["grouped_options"] as? [[String : Any]]
        if (groupedOptions != nil) {
            for (groupIndex, groupedOption) in groupedOptions!.enumerated() {
                let options = groupedOption["items"] as! [[String : Any]]
                for (itemIndex, option) in options.enumerated() {
                    let isDefault = option["default"] as! Bool
                    if isDefault == true {
                        selectedOptions.append(FoodExtraItem(itemSection: groupIndex, itemIndex: itemIndex, itemData: option))
                        break
                    }
                }
            }
        }
        
        additionalSides = [FoodExtraItem]()
        let sides = itemData["sides"] as? [[String : Any]]
        if (sides != nil) {
            for (sideIndex, side) in sides!.enumerated() {
                let isDefault = side["default"] as! Bool
                if isDefault == true {
                    additionalSides.append(FoodExtraItem(itemSection: 0, itemIndex: sideIndex, itemData: side))
                    break
                }
            }
        }
        
        extraInfo = ""
        totalPrice = 0.00
    }
}
