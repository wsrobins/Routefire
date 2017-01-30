//
//  Uber.swift
//  Routefire
//
//  Created by William Robinson on 1/29/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Alamofire
import CoreLocation

final class Uber: NSObject {
  static private let shared = Uber()
  private var productIDs: [String : String] = [:]
  private override init() {}
  
  static func getEstimates(to place: CLLocationCoordinate2D, completion: @escaping ([[String : Any]]) -> Void) {
    let pricesURL = URL(string: "https://api.uber.com/v1.2/estimates/price")!
    let pricesParameters: [String : Any] = ["server_token" : Secrets.uberServerToken,
                                            "start_latitude" : Location.current.latitude,
                                            "start_longitude" : Location.current.longitude,
                                            "end_latitude" : place.latitude,
                                            "end_longitude" : place.longitude]
    let group = DispatchGroup()
    group.enter()
    Alamofire.request(pricesURL, parameters: pricesParameters).responseJSON { response in
      print(response)
      group.leave()
      
    }
  
    group.notify(queue: DispatchQueue.main) {
      print("complete")
    }
  }
}
