//
//  VendorManager.swift
//  Eazyo
//
//  Created by SoftDev0420 on 9/16/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import UIKit

class VendorManager {
    static let instance = VendorManager()
    
    var vendor: [String : Any]?
    var vendorUuid = ""
    var vendorName = ""
    var locationType = ""
    var locationName = ""
    var isMenuLoaded = false
    var suppressDiscount = false
    var placeInfo: PlaceInfo?
    var menu: [String : Any]?
    var isPrivate = false
    var hasMaps = false
    var serviceFeeLabel = ""
    var tipLabel = ""
    
    var hasSecondaryServiceFee = false
    var secondaryServiceFeeLabel = ""
    var secondaryServiceFee: Float = 0
    var secondaryServiceFeeType = ""
    
    var mapLatitude: CGFloat = 0.0
    var mapLongitude: CGFloat = 0.0
    var mapOverlay: String?
    var hoursOfOperation = [String : String]()
    var weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    init () {
        clearVendorData()
    }
    
    //  UserMapData
    
    func setUserMapData(_ latitude: CGFloat, longitude: CGFloat, overlay: String) {
        mapLatitude = latitude
        mapLongitude = longitude
        mapOverlay = overlay
    }
    
    //  ResetData
    
    func clearMapData() {
        mapLatitude = 0.0
        mapLongitude = 0.0
        mapOverlay = nil
    }
    
    func clearVendorData() {
        vendorUuid = ""
        locationType = ""
        locationName = ""
        suppressDiscount = false
        isMenuLoaded = false
        isPrivate = false
        hasMaps = false
        serviceFeeLabel = ""
        tipLabel = ""
        
        hasSecondaryServiceFee = false
        secondaryServiceFeeLabel = "Secondary Fee"
        secondaryServiceFee = 0
        secondaryServiceFeeType = ""
        
        hoursOfOperation.removeAll()
        clearMapData()
    }
}
