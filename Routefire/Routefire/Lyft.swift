//
//  Lyft.swift
//  Routefire
//
//  Created by William Robinson on 1/30/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Alamofire
import GooglePlaces

final class Lyft {
  static private var accessToken = ""
  static private func getAccessToken(completion: @escaping(String) -> Void) {
    let url = URL(string: "https://api.lyft.com/oauth/token")!
    let parameters = ["grant_type" : "client_credentials", "scope" : "public"]
    Alamofire
      .request(url, method: .post, parameters: parameters)
      .authenticate(user: Secrets.lyftClientID, password: Secrets.lyftClientSecret)
      .responseJSON { response in
        guard let accessTokenJSON = response.result.value as? [String : Any],
          let accessToken = accessTokenJSON["access_token"] as? String else {
            print("error unwrapping lyft access token")
            return
        }
        
        completion(accessToken)
    }
  }
  
  static func getEstimates(to place: GMSPlace, completion: @escaping ([[String : Any]]) -> Void) {
    getAccessToken { accessToken in
      let url = URL(string: "https://api.lyft.com/v1/cost")!
      let parameters = ["start_lat" : Location.current.latitude,
                        "start_lng" : Location.current.longitude,
                        "end_lat" : place.coordinate.latitude,
                        "end_lng" : place.coordinate.longitude]
      let headers = ["Authorization" : "bearer \(accessToken)"]
      
      Alamofire.request(url, parameters: parameters, headers: headers).responseJSON { response in
        guard let estimatesJSON = response.result.value as? [String : [[String : Any]]],
          let estimates = estimatesJSON.values.first else {
            print("error unwrapping lyft prices")
            return
        }
        
        completion(estimates)
      }
    }
  }
}
