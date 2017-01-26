//
//  HomeInteractor.swift
//  Routefire
//
//  Created by William Robinson on 1/25/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import Alamofire

protocol HomeInteractorProtocol {
  var currentCoordinate: CLLocationCoordinate2D? { get }
  func configureLocation()
  func getUberProductIDs(completion: @escaping ([String]) -> Void)
}

class HomeInteractor: NSObject, HomeInteractorProtocol {
  private let locationManager = CLLocationManager()
  var currentCoordinate: CLLocationCoordinate2D? {
    return locationManager.location?.coordinate
  }
  
  func configureLocation() {
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  func getUberProductIDs(completion: @escaping ([String]) -> Void) {
    guard let currentCoordinate = currentCoordinate,
      let url = URL(string: "https://api.uber.com/v1.2/products") else { return }
    let parameters: [String : Any] = ["server_token" : Secrets.uberServerToken,
                                      "latitude" : currentCoordinate.latitude,
                                      "longitude" : currentCoordinate.longitude]
    Alamofire.request(url, parameters: parameters).responseJSON { response in
      guard let productsJSON = response.result.value as? [String : [[String : Any]]],
        let products = productsJSON["products"] else {
          print("error unwrapping uber products")
          return
      }
      
      var productIDs = [String]()
      for product in products {
        guard let productID = product["product_id"] as? String else { return }
        productIDs.append(productID)
      }
      
      completion(productIDs)
    }
  }
}

// Location manager delegate
extension HomeInteractor: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      NotificationCenter.default.post(name: Constants.locationAuthorizedNotification, object: nil)
    }
  }
}
