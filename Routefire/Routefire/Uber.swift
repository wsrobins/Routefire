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
  private var productIDs: [String] = []
  private override init() {
    super.init()
    
    NotificationCenter.default.addObserver(self, selector: #selector(getProductIDs), name: LocationFoundNotification, object: nil)
  }
  
  func getProductIDs() {
    NotificationCenter.default.removeObserver(self)
    
    print("getting product ids")
    
    let url = URL(string: "https://api.uber.com/v1.2/products")!
    let parameters: [String : Any] = ["server_token" : Secrets.uberServerToken,
                                      "latitude" : Location.current.latitude,
                                      "longitude" : Location.current.longitude]
    Alamofire.request(url, parameters: parameters).responseJSON { response in
      guard let productsJSON = response.result.value as? [String : [[String : Any]]],
        let products = productsJSON["products"] else {
          print("error unwrapping uber products")
          return
      }
      
      var productIDs: [String] = []
      for product in products {
        guard let productID = product["product_id"] as? String else { return }
        productIDs.append(productID)
      }
      
      self.productIDs = productIDs
     
    }
  }
  
  static func getEstimates(to place: CLLocationCoordinate2D, completion: @escaping ([[String : Any]]) -> Void) {
    let url = URL(string: "https://api.uber.com/v1.2/requests/estimate")!
    var estimates = [[String : Any]]()
    let group = DispatchGroup()
    
    for productID in shared.productIDs {
      let parameters: [String : Any] = ["server_token" : Secrets.uberServerToken,
                                        "product_id" : productID,
                                        "start_latitude" : Location.current.latitude,
                                        "start_longitude" : Location.current.longitude,
                                        "end_latitude" : place.latitude,
                                        "end_longitude" : place.longitude]
      print("yes")
      group.enter()
      Alamofire.request(url, method: .post, parameters: parameters).responseJSON { response in
        
        print(response)
        
        if let estimate = response.result.value as? [String : Any]  {
          estimates.append(estimate)
        }
        
        group.leave()
      }
    }
    
    print("yesyes")
    group.notify(queue: DispatchQueue.main) {
      completion(estimates)
    }
  }
}
