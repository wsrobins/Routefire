//
//  Uber.swift
//  Routefire
//
//  Created by William Robinson on 1/29/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Alamofire
import GooglePlaces

final class Uber {
  static func getEstimates(to place: GMSPlace, completion: @escaping ([String : [String : Any]]?, [String : Int]?) -> Void) {
    let group = DispatchGroup()
    
    // Price estimates
    var priceEstimates: [String : [String : Any]]?
    let pricesURL = URL(string: "https://api.uber.com/v1.2/estimates/price")!
    let pricesParameters: [String : Any] = [
      "server_token" : Secrets.uberServerToken,
      "start_latitude" : Location.current.latitude,
      "start_longitude" : Location.current.longitude,
      "end_latitude" : place.coordinate.latitude,
      "end_longitude" : place.coordinate.longitude
    ]
    
    getPrices(pricesURL, pricesParameters, group) { estimates in
      priceEstimates = estimates
    }
    
    // Time estimates
    var timeEstimates: [String : Int]?
    let timesURL = URL(string: "https://api.uber.com/v1.2/estimates/time")!
    let timesParameters: [String : Any] = [
      "server_token" : Secrets.uberServerToken,
      "start_latitude" : Location.current.latitude,
      "start_longitude" : Location.current.longitude
    ]
    
    getTimes(timesURL, timesParameters, group) { estimates in
      timeEstimates = estimates
    }
    
    // Requests complete
    group.notify(queue: DispatchQueue.main) {
      completion(priceEstimates, timeEstimates)
    }
  }
  
  static private func getPrices(_ url: URL, _ parameters: [String : Any], _ group: DispatchGroup, completion: @escaping ([String : [String : Any]]?) -> Void) {
    var priceEstimates: [String : [String : Any]] = [:]
    group.enter()
    Alamofire.request(url, parameters: parameters).responseJSON { response in
      guard let pricesJSON = response.result.value as? [String : [[String : Any]]],
        let pricesArray = pricesJSON.values.first else {
          print("error unwrapping uber prices")
          completion(nil)
          group.leave()
          return
      }
      
      for priceDict in pricesArray {
        guard let name = priceDict["localized_display_name"] as? String,
          let id = priceDict["product_id"] as? String,
          let lowPrice = priceDict["low_estimate"] as? Int,
          let highPrice = priceDict["high_estimate"] as? Int,
          let duration = priceDict["duration"] as? Int else { continue }
        priceEstimates[name] = ["id" : id, "lowPrice" : lowPrice, "highPrice" : highPrice, "duration" : duration]
      }
      
      completion(priceEstimates)
      group.leave()
    }
  }
  
  static private func getTimes(_ url: URL, _ parameters: [String : Any], _ group: DispatchGroup, completion: @escaping ([String : Int]?) -> Void) {
    var timeEstimates: [String : Int] = [:]
    group.enter()
    Alamofire.request(url, parameters: parameters).responseJSON { response in
      guard let timesJSON = response.result.value as? [String : [[String : Any]]],
        let timesArray = timesJSON.values.first else {
          print("error unwrapping uber times")
          completion(nil)
          group.leave()
          return
      }
      
      for timeDict in timesArray {
        guard let name = timeDict["localized_display_name"] as? String,
          let waitTime = timeDict["estimate"] as? Int else { continue }
        timeEstimates[name] = waitTime
      }
      
      completion(timeEstimates)
      group.leave()
    }
  }
}







