//
//  HomePresenter.swift
//  Routefire
//
//  Created by William Robinson on 1/11/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import CoreLocation

class HomePresenter: NSObject, CLLocationManagerDelegate {
  
  // MARK: Best routes
  var bestRoutes = [Route]()

  // MARK: Status
  var didFindMyLocation = false
  
  // MARK: Input
  let locationManager = (UIApplication.shared.delegate as? AppDelegate)?.locationManager

  func configureLocationManager() {
    locationManager?.delegate = self
    locationManager?.requestWhenInUseAuthorization()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      NotificationCenter.default.post(name: Constants.locationAuthorizedNotification, object: nil)
    }
  }
}
