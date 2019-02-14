//
//  DeliveryPlaceInfo.swift
//  Eazyo
//
//  Created by Admin on 11/1/17.
//  Copyright © 2017 SoftDev0420. All rights reserved.
//

class PlaceInfo {
    var type: String?
    var uuid: String?
    var name: String?
    var description: String?
    var imageURL: String?
    var suppressDiscount = false
    
    init(type: String?, name: String?) {
        self.type = type
        self.name = name
    }
    
    init(type: String?, uuid: String?, name: String?, description: String?, imageURL: String?, suppressDiscount: Bool) {
        self.type = type
        self.uuid = uuid
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.suppressDiscount = suppressDiscount
    }
}
