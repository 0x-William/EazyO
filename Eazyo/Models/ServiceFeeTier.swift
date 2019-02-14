//
//  ServiceFeeTier.swift
//  Eazyo
//
//  Created by SoftDev0420 on 7/29/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

class ServiceFeeTier {
    var minRange: Float!
    var maxRange: Float?
    var price: Float!
    
    init(min: Float!, max: Float?, p: Float!) {
        minRange = min
        maxRange = max
        price = p
    }
}
