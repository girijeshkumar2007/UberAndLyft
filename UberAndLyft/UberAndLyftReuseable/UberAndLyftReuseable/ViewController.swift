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
        
        TALyftServiceClass.sharedInstance.getETAForLocation(String(37.787654), lng: String(-122.402760), completionClosure: { (result) in
            
            }, failClosure:{ (error) in
            
        })
        
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


}

