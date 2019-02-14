//
//  FoodExtraItem.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/12/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

class FoodExtraItem: NSObject {
    var section: Int = 0
    var index: Int = 0
    var data: [String : Any]!

    override init() {
        index = 0
        section = 0
    }
    
    init(itemSection: Int!, itemIndex: Int!, itemData: [String : Any]!) {
        section = itemSection
        index = itemIndex
        data = itemData
    }
}
