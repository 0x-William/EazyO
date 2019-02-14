//
//  WebService.swift
//  Eazyo
//
//  Created by SoftDev0420 on 3/26/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

#if DEVELOPMENT
let SERVER_URL = "http://staging-api.eazyoapp.com/v3/"
let BASIC_HEADER = ["X-App-Key" : "iOSUserApp_Y7tG8ssVxE7"]
#elseif STAGING
let SERVER_URL = "http://staging-api.eazyoapp.com/v3/"
let BASIC_HEADER = ["X-App-Key" : "iOSUserApp_Y7tG8ssVxE7"]
#elseif PRODUCTION
let SERVER_URL = "https://api.eazyoapp.com/v3/"
let BASIC_HEADER = ["X-App-Key" : "iOSUserApp_Y7tG8ssVxE7"]
#endif

import Alamofire

protocol WebServiceDelegate {
    func onSuccess(apiName: String, data: AnyObject)
    func onError(apiName: String, errorInfo: [String])
}

class WebService {
    let SUCCESS_CODE = 200

    var authToken: String = ""
    
    var headers = BASIC_HEADER
    
    static let instance = WebService()
    var delegate: WebServiceDelegate?
    
    private init() {
    }
    
    func setAuthToken(_ token: String) {
        authToken = token
        headers["X-Auth-Token"] = token
    }
    
    func removeAuthToken() {
        authToken = ""
        headers["X-Auth-Token"] = ""
    }
    
    func callAPI(callType: HTTPMethod, apiName: String, endPoint:String, parameters:[String : Any]) {
        
        var encoding: ParameterEncoding = URLEncoding.default
        switch callType {
        case .get:
            encoding = URLEncoding.default
            break
        case .post:
            encoding = JSONEncoding.default
            break
        default:
            break
        }
        
        Alamofire.request(endPoint, method: callType, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON { (response) in
            print(response)
            switch response.result {
            case .success(let value):
                let valueObject = value as! [String : Any]
                let code = valueObject["code"] as! Int
                if code == self.SUCCESS_CODE {
                    let data = valueObject["data"] as AnyObject
                    self.delegate?.onSuccess(apiName: apiName, data: data)
                }
                else {
                    let error = (valueObject["data"] as! [String : Any])["error"] as! [String]
                    self.delegate?.onError(apiName: apiName, errorInfo: error)
                }
                break
            case .failure( _):
                var errorMessage: String?
                do {
                    let errorDic = try JSONSerialization.jsonObject(with: response.data!, options: []) as! [String : AnyObject]
                    errorMessage = errorDic["message"] as? String
                }
                catch {
                    errorMessage = "Unknown error"
                }
                self.delegate?.onError(apiName: apiName, errorInfo: [errorMessage!])
                break
            }
        }
    }
    
    //////////////////////////////
    
    // Status
    
    func checkStatus() {
        let endPoint = SERVER_URL + "status"
        callAPI(callType: HTTPMethod.get, apiName: "checkStatus", endPoint: endPoint, parameters: [:])
    }
    
    //////////////////////////////
    
    // Authentication & Registration
    
    func signIn(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "authentication"
        callAPI(callType: HTTPMethod.post, apiName: "signIn", endPoint: endPoint, parameters: parameters)
    }
    
    func signInWithFacebook(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "authentication/facebook"
        callAPI(callType: HTTPMethod.post, apiName: "signInWithFacebook", endPoint: endPoint, parameters: parameters)
    }
    
    func createAccount(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "registration"
        callAPI(callType: HTTPMethod.post, apiName: "createAccount", endPoint: endPoint, parameters: parameters)
    }
    
    //////////////////////////////
    
    //  User
    
    func getUser() {
        let endPoint = SERVER_URL + "user"
        callAPI(callType: HTTPMethod.get, apiName: "getUser", endPoint: endPoint, parameters: [:])
    }
    
    func updateUser(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "user"
        callAPI(callType: HTTPMethod.put, apiName: "updateUser", endPoint: endPoint, parameters: parameters)
    }
    
    func getClientToken() {
        let endPoint = SERVER_URL + "user/client_token"
        callAPI(callType: HTTPMethod.get, apiName: "getClientToken", endPoint: endPoint, parameters: [:])
    }
    
    //////////////////////////////
    
    //  Vendors
    
    func getVendors(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "vendors"
        callAPI(callType: HTTPMethod.post, apiName: "getVendors", endPoint: endPoint, parameters: parameters)
    }
    
    func getVendor(_ parameters: [String : Any]) {
        let uuid = parameters["uuid"] as! String
        let endPoint = SERVER_URL + "vendors/" + uuid
        callAPI(callType: HTTPMethod.get, apiName: "getVendor", endPoint: endPoint, parameters: [:])
    }
    
    func getVendorMaps(_ parameters: [String : Any]) {
        let uuid = parameters["location_id"] as! String
        let endPoint = SERVER_URL + "vendors/" + uuid + "/maps"
        callAPI(callType: HTTPMethod.get, apiName: "getVendorMaps", endPoint: endPoint, parameters: [:])
    }
    
    func getVendorMap(_ parameters: [String : Any]) {
        let vendorUuid = parameters["vendorUuid"] as! String
        let mapUuid = parameters["mapUuid"] as! String
        let endPoint = SERVER_URL + "vendors/" + vendorUuid + "/maps/" + mapUuid
        callAPI(callType: HTTPMethod.get, apiName: "getVendorMap", endPoint: endPoint, parameters: [:])
    }
    
    func validateVendorCode(_ parameters: [String : Any]) {
        let vendorUuid = parameters["vendorUuid"] as! String
        let endPoint = SERVER_URL + "vendors/" + vendorUuid + "/validate_code"
        callAPI(callType: HTTPMethod.post, apiName: "validateVendorCode", endPoint: endPoint, parameters: parameters)
    }
    
    //////////////////////////////
    
    //  Location
    
    func getLocations(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "locations"
        callAPI(callType: HTTPMethod.post, apiName: "getLocations", endPoint: endPoint, parameters: parameters)
    }
    
    //////////////////////////////
    
    //  Menu
    
    func getMenu(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "menu"
        callAPI(callType: HTTPMethod.post, apiName: "getMenu", endPoint: endPoint, parameters: parameters)
    }
    
    //////////////////////////////
    
    //  Card
    
    func getCards() {
        let endPoint = SERVER_URL + "cards"
        callAPI(callType: HTTPMethod.get, apiName: "getCards", endPoint: endPoint, parameters: [:])
    }
    
    func addCard(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "cards"
        callAPI(callType: HTTPMethod.post, apiName: "addCard", endPoint: endPoint, parameters: parameters)
    }
    
    func deleteCard(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "cards/" + (parameters["card_uuid"] as! String)
        callAPI(callType: HTTPMethod.delete, apiName: "deleteCard", endPoint: endPoint, parameters: [:])
    }
    
    func updateCard(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "cards/" + (parameters["card_uuid"] as! String)
        callAPI(callType: HTTPMethod.put, apiName: "updateCard", endPoint: endPoint, parameters: parameters)
    }
    
    //////////////////////////////
    
    //  ApplyPay
    
    func getApplyPay() {
        let endPoint = SERVER_URL + "apple_pay"
        callAPI(callType: HTTPMethod.get, apiName: "getApplyPay", endPoint: endPoint, parameters: [:])
    }
    
    func addApplyPay(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "apple_pay"
        callAPI(callType: HTTPMethod.post, apiName: "addApplyPay", endPoint: endPoint, parameters: [:])
    }
    
    func deleteApplePay(_ parameters: [String : Any]) {
        let applePayUuid = parameters["applePayUuid"] as! String
        let endPoint = SERVER_URL + "apple_pay/" + applePayUuid
        callAPI(callType: HTTPMethod.delete, apiName: "addApplyPay", endPoint: endPoint, parameters: [:])
    }
    
    //////////////////////////////
    
    //  Order
    
    func placeOrder(_ parameters: [String : Any]) {
        let endPoint = SERVER_URL + "order"
        callAPI(callType: HTTPMethod.post, apiName: "placeOrder", endPoint: endPoint, parameters: parameters)
    }
    
    func getActiveOrders() {
        let endPoint = SERVER_URL + "orders/active"
        callAPI(callType: HTTPMethod.get, apiName: "getActiveOrders", endPoint: endPoint, parameters: [:])
    }
    
    func getOrderHistory() {
        let endPoint = SERVER_URL + "orders/history"
        callAPI(callType: HTTPMethod.get, apiName: "getOrderHistory", endPoint: endPoint, parameters: [:])
    }
    
    func getOrderStatus(_ parameters: [String : Any]) {
        let orderUUID = parameters["order_uuid"] as! String
        let endPoint = SERVER_URL + "orders/" + orderUUID + "/status"
        callAPI(callType: HTTPMethod.get, apiName: "getOrderStatus", endPoint: endPoint, parameters: parameters)
    }
    
    func completeOrder(_ parameters: [String : Any]) {
        let orderUUID = parameters["order_uuid"] as! String
        let endPoint = SERVER_URL + "orders/" + orderUUID + "/complete"
        callAPI(callType: HTTPMethod.post, apiName: "completeOrder", endPoint: endPoint, parameters: parameters)
    }
    
    //////////////////////////////
}
