//
//  TAUberServiceClass.swift
//  Forkspot
//
//  Created by Girijesh Kumar on 12/07/16.
//  Copyright © 2016 . All rights reserved.
//

import Foundation
import UberRides
import CoreLocation


let UberErrorDomain = "UberErrorDomain"
private enum UberServiceErrorCode: NSInteger {
    
    case kParameterFailed = 997
    case kProdcutFetchFailed = 998
    case kEstimateTimeFailed = 999

    var description: String {
        
        switch self {
        case kParameterFailed: return "Parameter is missing Please check."
        case kProdcutFetchFailed: return "Product not found on Uber server for your location."
        case kEstimateTimeFailed: return "Estimate Time not found on Uber server for your location."
        }
    }
}

class TAUberServiceClass: RidesClient {

    class var sharedInstance: TAUberServiceClass {
        
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: TAUberServiceClass? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = TAUberServiceClass()
        }
        return Static.instance!
    }
    
    //MARK:- Public Interfce
    func getProductListByLocation(lati: Double?,longi: Double?, block:(result : [UberProduct])->(),failBlock:(error : NSError?)->()) -> Void {
    
        guard let uberLat = lati ,
            uberLng = longi
            else {
                publishUberError(UberServiceErrorCode.kParameterFailed, failBlock: failBlock)
                return;
        }
        
    //  let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)//test data
    let pickupLocation = CLLocation(latitude: uberLat, longitude: uberLng)
    self.fetchProducts(pickupLocation: pickupLocation) { (products, response) in
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if products.count>0
            {
                block(result: products)
            }
            else{
                self.publishUberError(UberServiceErrorCode.kProdcutFetchFailed, failBlock: failBlock)
            }
        })
    }
}
private func getEstimateTimeByProductName(uberName : String?,lati: Double?,longi: Double?,dropLati: Double?,dropLongi: Double?,block:(result : PriceEstimate)->(),failBlock:(error : NSError?)->()) -> Void {
    
    
    // Only Hit API if all the relevant properties can be accessed.
    guard let uberStartLat = lati,
        uberStartLng = longi,
        uberEndLat = dropLati,
        uberEndLng = dropLongi,
        uberCarName = uberName
        else {
            
            self.publishUberError(UberServiceErrorCode.kParameterFailed, failBlock: failBlock)
            return;
    }
    
    // let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
    let pickupLocation = CLLocation(latitude: uberStartLat, longitude: uberStartLng)
    
//    let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
    let dropoffLocation = CLLocation(latitude: uberEndLat, longitude: uberEndLng)

    self.fetchPriceEstimates(pickupLocation: pickupLocation, dropoffLocation: dropoffLocation) { (priceEstimates, response) in
        
        let filteredList = priceEstimates.filter({ (priceEstimate) -> Bool in
            
            guard let name = priceEstimate.name where name == uberCarName
                else {
                    return false
            }
            return true
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if let priceObj = filteredList.last{
                block(result: priceObj)
            }
            else{
                self.publishUberError(UberServiceErrorCode.kEstimateTimeFailed, failBlock: failBlock)
            }
        })
    }
 }
    //MARK: - Private Method
    private func publishUberError(uberError: UberServiceErrorCode, failBlock:( error : NSError?)->())
    {
        let localizedDescription = NSLocalizedString(uberError.description, comment: "")
        let error = NSError(domain: UberErrorDomain, code: uberError.rawValue, userInfo: [
            NSLocalizedDescriptionKey: localizedDescription])
        failBlock(error: error)
    }
}