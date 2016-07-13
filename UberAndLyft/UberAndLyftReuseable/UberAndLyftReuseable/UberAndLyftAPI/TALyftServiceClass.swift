//
//  TALyftServiceClass.swift
//  Forkspot
//
//  Created by Girijesh Kumar on 12/07/16.
//  Copyright © 2016 . All rights reserved.
//

import Foundation
import AFNetworking

let LyftErrorDomain = "LyftErrorDomain"


private  let kLyftClientId          =  "" // Only This value will be changes
private  let kLyftClientSecret      =  "" // Only This value will be changes

private  let kLyftBaseUrl           =  "https://api.lyft.com/"

private  let kLyftToken             =  "oauth/token"
private  let kLyftRidetypes         =  "v1/ridetypes"
private  let kLyftETA               =  "v1/eta"
private  let kLyftCost              =  "v1/cost"

private  let kLyftAuthorization     =  "Authorization"
private  let kLyftAppJson           =  "application/json"
private  let kLyftContentType       =  "Content-Type"

private  let kLyftGrantType         =  "grant_type"
private  let kLyftClientCredentials =  "client_credentials"
private  let kLyftScope             =  "scope"
private  let kLyftPublic            =  "public"
private  let kLyftStartLat          =  "start_lat"
private  let kLyftStartLng          =  "start_lng"
private  let kLyftEndLat            =  "end_lat"
private  let kLyftEndLng            =  "end_lng"
private  let kLyftLat               =  "lat"
private  let kLyftLng               =  "lng"
private  let kLyftAccesToken        =  "access_token"


private enum LyftServiceErrorCode: NSInteger {
    
    case kTokenFailed = 997
    case kParameterFailed = 998
    
    var description: String {
        
        switch self {
        case kTokenFailed: return "Token Not found!!"
        case kParameterFailed: return "Could not fetch data from the Lyft server."
        }
    }
}

class TALyftServiceClass: AFHTTPSessionManager {
    

   private var accessToken: String?
    
    class var sharedInstance: TALyftServiceClass {
        
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: TALyftServiceClass? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = TALyftServiceClass(baseURL:NSURL(string:kLyftBaseUrl))
        }
        Static.instance!.requestSerializer = AFJSONRequestSerializer()
        Static.instance!.requestSerializer.setValue(kLyftAppJson, forHTTPHeaderField: kLyftContentType)
        
//        let policy = AFSecurityPolicy(pinningMode: .Certificate)
//        policy.validatesDomainName=false
//        policy.allowInvalidCertificates=true
//        Static.instance!.securityPolicy=policy

        return Static.instance!
    }
    
    //MARK:- Public Interfce
    func getRideTypesForLocation(lat: String?,lng: String?,completionClosure: (result : AnyObject?) -> (),failClosure: (error : NSError?) -> ()){
        
        guard let lyftLat = lat ,
            lyftLng = lng
            else {
                publishLyftError(LyftServiceErrorCode.kParameterFailed, failBlock: failClosure)
                return;
        }
        
        getAccessToken { (token) in
            
           if let tempAccesstoken = token
            {
                let param = [kLyftLat:lyftLat,kLyftLng:lyftLng]
                self.requestSerializer.setValue("Bearer " + tempAccesstoken, forHTTPHeaderField: kLyftAuthorization)
                self.GET(kLyftRidetypes, parameters: param, progress: nil, success: { (task, reponse) in
                    
                    print(reponse)
                    completionClosure(result: reponse)
                    
                }) { (task, error) in
                    print(error.description)
                    failClosure(error: error)
                }
            }
            else
            {
                self.publishLyftError(LyftServiceErrorCode.kTokenFailed, failBlock: completionClosure)
            }
        }
    }
    
     func getETAForLocation(lat: String?,lng: String?, completionClosure: (result : AnyObject?) -> (),failClosure: (error : NSError?) -> ()) {
        
        guard let lyftLat = lat ,
        lyftLng = lng
        else {
            
            self.publishLyftError(LyftServiceErrorCode.kParameterFailed, failBlock: failClosure)
            return;
        }
        
        getAccessToken { (token)  in
            
            if let tempAccesstoken = token
            {
                let param = [kLyftLat:lyftLat,kLyftLng:lyftLng]
                //ride_type
                
                self.requestSerializer.setValue("Bearer " + tempAccesstoken, forHTTPHeaderField: kLyftAuthorization)
                self.GET(kLyftETA, parameters: param, progress: nil, success: { (task, reponse) in
                    
                    print(reponse)
                    completionClosure(result: reponse)
                    
                }) { (task, error) in
                    print(error.description)
                    failClosure(error: error)
                }
            }
            else
            {
                self.publishLyftError(LyftServiceErrorCode.kTokenFailed, failBlock: failClosure)
            }
        }
    }
    
    func getCostBetween(startLat: String?,startLng: String?,endLat: String?,endLng: String?, completionClosure: (result : AnyObject?) -> (),failClosure: (error : NSError?) -> ())
    {
        
        // Only Hit API if all the relevant properties can be accessed.
        guard let lyftStartLat = startLat ,
                lyftStartLng = startLng ,
                lyftEndLat = endLat ,
                lyftEndLng = endLng
             else {

                self.publishLyftError(LyftServiceErrorCode.kParameterFailed, failBlock: failClosure)

                return;
        }
        
        getAccessToken { (token) in
            
            if let tempAccesstoken = token
            {
                //        let param = [kLyftStartLat:"37.7833",kLyftStartLng:"-122.4167",kLyftEndLat:"37.775200",kLyftEndLng:"-122.417587"]
                let param = [kLyftStartLat:lyftStartLat,kLyftStartLng:lyftStartLng,kLyftEndLat:lyftEndLat,kLyftEndLng:lyftEndLng]
                
                self.requestSerializer.setValue("Bearer " + tempAccesstoken, forHTTPHeaderField: kLyftAuthorization)
                self.GET(kLyftCost, parameters: param, progress: nil, success: { (task, reponse) in
                    
                    print(reponse)
                    completionClosure(result: reponse)
                    
                }) { (task, error) in
                    print(error.description)
                    failClosure(error: error)
                }
            }
            else
            {
                self.publishLyftError(LyftServiceErrorCode.kTokenFailed, failBlock: failClosure)
            }
        }
    }
    
    //MARK: - Private Method
    private func publishLyftError(lyftError: LyftServiceErrorCode, failBlock:(error : NSError?)->())
    {
        let localizedDescription = NSLocalizedString(lyftError.description, comment: "")
        let error = NSError(domain: LyftErrorDomain, code: lyftError.rawValue, userInfo: [
            NSLocalizedDescriptionKey: localizedDescription])
        failBlock(error: error)
    }
    private func getAccessToken(completionClosure:(token : String?)->())->Void
    {
        if let tempToken = accessToken {
            
            completionClosure(token: tempToken)
            return
        }
        let param = [kLyftGrantType:kLyftClientCredentials,kLyftScope:kLyftPublic]
        self.requestSerializer.setAuthorizationHeaderFieldWithUsername(kLyftClientId, password: kLyftClientSecret)
        self.POST(kLyftToken, parameters: param, progress: nil, success: { (task, response) in
            
            print(response!)

            if let reponseDic  = response as? Dictionary<String,AnyObject>
            {
                if let token = reponseDic[kLyftAccesToken] as? String
                {
                    self.accessToken = token
                    completionClosure(token: token)
                    return;
                }
            }
            completionClosure(token: nil)
        }) { (task, error) in
            print(error.description)
            completionClosure(token: nil)
        }
    }
}