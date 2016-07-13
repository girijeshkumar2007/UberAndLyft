//
//  ViewController.swift
//  UberAndLyftReuseable
//
//  Created by Girijesh Kumar on 13/07/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //let pickupLocation = CLLocation(latitude: 37.787654, longitude: -122.402760)
        //let dropoffLocation = CLLocation(latitude: 37.775200, longitude: -122.417587)
        
//        TALyftServiceClass.sharedInstance.getETAForLocation(String(37.787654), lng: String(-122.402760), completionClosure: { (result) in
//            
//            }, failClosure:{ (error) in
//            
//        })
        getEstimateTimeForLyftByProduct("lyft_plus")
        
        
//        TAUberServiceClass.sharedInstance.getProductListByLocation(37.787654, longi: -122.402760, block: { (result) in
//           
//            print(result)
//        },failBlock:{ (error) in
//           
//            print(error?.description)
//
//        })
        
//        TAUberServiceClass.sharedInstance.getProductListByLocation
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Hit Lyft API
    private func getEstimateTimeForLyftByProduct(lyftName : String) -> Void {
        
        //        https://api.lyft.com/v1/cost?start_lat=37.7772&start_lng=-122.4233&end_lat=37.7972&end_lng=-122.4533
        
        TALyftServiceClass.sharedInstance.getCostBetween(lyftName, startLat: String(37.7772), startLng: String(-122.4233), endLat: String(37.7972), endLng: String(-122.4533), completionClosure: { (result) in
            
            if let duration = result["estimated_duration_seconds"] as? Double
            {
                let durationInMin = String(format:"%0.0f",duration/60)
                //self.etaLbl.text = durationInMin + " MIN"
                print(durationInMin)

            }
            
            if let minCost = result["estimated_cost_cents_min"] as? Double
            {
                if let maxCost = result["estimated_cost_cents_max"] as? Double
                {
                    if let currency = result["currency"] as? String
                    {

                     let costEstimates = String(format:"%@ %0.0f-%0.0f",currency, minCost,maxCost)
                     print(costEstimates)

                    }
                }
            }
            },failClosure: { (error) in
                
                print(error.debugDescription)
        })
    }
}

