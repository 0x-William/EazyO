//
//  ReceiptManager.swift
//  Eazyo
//
//  Created by SoftDev0420 on 6/21/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

#if DEVELOPMENT
let PAY_MERCHANT_ID = "merchant.org.eazyo.dev"
#elseif STAGING
let PAY_MERCHANT_ID = "merchant.org.eazyo.dev"
#elseif PRODUCTION
let PAY_MERCHANT_ID = "merchant.org.eazyo"
#endif

class ReceiptManager {
    
    static let instance = ReceiptManager()
    
    var additionalInfo: String?
    var acceptTips: Bool!
    var tax: Float!
    var baseTax: Float!
    var resortTax: Float!
    var taxServiceFee: Bool!
    var serviceFee: Float!
    var serviceFeeType: String!
    var discountPercent: Float!
    var serviceFeeTiers: [ServiceFeeTier]!
    var selectedTip: Int?
    var tipValues = [Int]()
    var defaultTip = 0
    var roomNumber = ""
    
    init() {
        clearReceiptData()
    }
    
    func clearReceiptData() {
        additionalInfo = ""
        serviceFeeType = ""
        acceptTips = false
        taxServiceFee = false
        tax = 0.0
        baseTax = 0.0
        resortTax = 0.0
        serviceFee = 0.0
        selectedTip = nil
        serviceFeeTiers = [ServiceFeeTier]()
        roomNumber = ""
    }
}
