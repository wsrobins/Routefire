//
//  Uber.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Foundation
import Alamofire

final class Uber {
  static let shared = Uber()
  var productIDs: [String : String]?
  private init() {}
  
  func getProductIDs() {
    guard let location = Location.shared.current,
      let url = URL(string: "https://api.uber.com/v1.2/products") else { return }
    let parameters: [String : Any] = ["server_token" : Secrets.uberServerToken,
                                      "latitude" : location.latitude,
                                      "longitude" : location.longitude]
    Alamofire.request(url, parameters: parameters).responseJSON { response in
      guard let productsJSON = response.result.value as? [String : [[String : Any]]],
        let products = productsJSON["products"] else {
          print("error unwrapping uber products")
          return
      }
      
      var productIDs = [String : String]()
      for product in products {
        guard let displayName = product["display_name"] as? String,
          let productID = product["product_id"] as? String else { return }
        productIDs[displayName] = productID
      }
      
      self.productIDs = productIDs
    }
  }
}
