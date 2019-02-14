//
//  UserManager.swift
//  Eazyo
//
//  Created by SoftDev0420 on 5/11/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

import Alamofire
import AlamofireImage

class UserManager {
    static let instance = UserManager()
    
    var authenticationToken: String?
    var avatarUrl: String?
    var avatarImage: UIImage?
    var hasAvatar: Bool?
    var email: String?
    var password: String?
    var firstName, lastName: String?
    var phoneNumber: String?
    var uuid: String?
    var vendor: String?
    var isManager: Bool = false
    var memberCode: String?
    
    init() {
        firstName = ""
        lastName = ""
        phoneNumber = ""
    }
    
    //////////////////////////////
    
    func setUserData(_ data: [String : Any]) {
        authenticationToken = data["authentication_token"] as? String
        
        hasAvatar = data["has_avatar"] as? Bool
        if (hasAvatar == true) {
            let newAvatarUrl = data["avatar_url"] as? String
            if (avatarUrl != newAvatarUrl) {
                avatarImage = nil
                avatarUrl = newAvatarUrl
                if (avatarUrl != nil) {
                    Alamofire.request(avatarUrl!)
                        .responseImage { response in
                            if let image = response.result.value {
                                self.avatarImage = image
                            }
                    }
                }
                else {
                    avatarImage = nil
                }
            }
        }
        else {
            avatarImage = nil
        }
        
        email = data["email"] as? String
        firstName = data["first_name"] as? String
        lastName = data["last_name"] as? String
        phoneNumber = data["phone_number"] as? String
        uuid = data["uuid"] as? String
        vendor = data["vendor"] as? String
        if (vendor != nil) {
            isManager = true
        }
        else {
            UserManager.instance.isManager = false
        }
        
//        if (firstName == nil || firstName == "") {
//            ReceiptManager.instance.additionalInfo = lastName
//        }
//        else {
//            if (lastName == nil || lastName == "") {
//                ReceiptManager.instance.additionalInfo = firstName
//            }
//            else {
//                ReceiptManager.instance.additionalInfo = firstName! + " " + lastName!
//            }
//        }
    }
    
//    func setUserDataForOrdering(_ firstName: String?, lastName: String?, phoneNumber: String?) {
//        firstNameForOrdering = firstName
//        lastNameForOrdering = lastName
//        phoneNumberForOrdering = phoneNumber
//    }
    
    func setPassword(_ newPassword: String?) {
        password = newPassword
    }
    
    func clearUserData() {
        authenticationToken = ""
        firstName = ""
        lastName = ""
        phoneNumber = ""
        isManager = false
        clearVendorData()
    }
    
    func clearVendorData() {
        memberCode = ""
        vendor = ""
    }
}
