//
//  RouteInteractor.swift
//  Routefire
//
//  Created by William Robinson on 1/11/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Foundation
import GooglePlaces
import Alamofire

protocol RouteInteractorProtocol {
  func autocomplete(_ text: String, completion: @escaping([GMSAutocompletePrediction]) -> Void)
}

class RouteInteractor {
  
  // MARK: Search autocompletion
  func autocomplete(_ text: String, completion: @escaping([GMSAutocompletePrediction]) -> Void) {
    let northWest = CLLocationCoordinate2D(latitude: 40.917577, longitude: -74.259090)
    let southEast = CLLocationCoordinate2D(latitude: 40.477399, longitude: -73.700272)
    let bounds = GMSCoordinateBounds(coordinate: northWest, coordinate: southEast)
    GMSPlacesClient.shared().autocompleteQuery(text, bounds: bounds, filter: nil) { results, error in
      guard let results = results, error == nil else {
        print("error during autocompletion: \(error)")
        return
      }
      
      completion(results)
    }
  }
  
  func getPlace(_ placeID: String, completion: @escaping (GMSPlace) -> Void) {
    GMSPlacesClient.shared().lookUpPlaceID(placeID) { destination, error in
      guard let destination = destination, error == nil else {
        print("error retrieving google place: \(error)")
        return
      }
      
      completion(destination)
    }
  }
  
  // MARK: Uber price estimate
  func getUberPriceEstimates(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, completion: @escaping ([[String : Any]]?) -> Void) {
    guard let url = URL(string: "https://api.uber.com//v1.2/estimates/price") else { return }
    let parameters: [String : Any] = ["server_token" : Secrets.uberServerToken,
                                      "start_latitude" : start.latitude,
                                      "start_longitude" : start.longitude,
                                      "end_latitude" : end.latitude,
                                      "end_longitude" : end.longitude]
    Alamofire.request(url, parameters: parameters).responseJSON { response in
      guard let pricesJSON = response.result.value as? [String : [[String : Any]]],
        let prices = pricesJSON.values.first else {
          print("error unwrapping uber prices")
          completion(nil)
          return
      }
      
      completion(prices)
    }
  }
  
  // MARK: Lyft price and time estimate
//  func getLyftEstimates(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, completion: @escaping ([Cost]?) -> Void) {
//    LyftAPI.costEstimates(from: start, to: end, rideKind: nil) { response in
//      guard let prices = response.value, response.error == nil else {
//        print("error unwrapping lyft prices: \(response.error)")
//        completion(nil)
//        return
//      }
//      
//      completion(prices)
//    }
//  }
  
  
  // ••••••••••
  
  // MARK: Uber time estimate
  //  func getUberTimeEstimate(completion: @escaping (Double) -> Void) {
  //    guard let url = URL(string: "https://api.uber.com//v1.2/estimates/time") else { return }
  //    let parameters: [String : Any] = ["server_token" : Secrets.uberServerToken,
  //                                      "start_latitude" : 0,
  //                                      "start_longitude" : 0]
  //    Alamofire.request(url, parameters: parameters)
  //      .responseString { response in
  //        print(response)
  //
  //        completion(0)
  //    }
  //  }
  
  // ••••••••••
  
}
