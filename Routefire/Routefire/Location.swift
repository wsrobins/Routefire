//
//  Location.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Foundation
import CoreLocation

final class Location: NSObject {
  
  // MARK: Properties
  private let locationManager = CLLocationManager()
  var current: CLLocationCoordinate2D? {
    return locationManager.location?.coordinate
  }
  
  // MARK: Singleton initialization
  static let shared = Location()
  private override init() {}
  
  // MARK: Configure location manager
  func configureManager() {
    locationManager.delegate = self
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      NotificationCenter.default.post(name: Constants.locationAuthorizedNotification, object: nil)
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }
}

// MARK: - Location Manager Delegate
extension Location: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      NotificationCenter.default.post(name: Constants.locationAuthorizedNotification, object: nil)
    }
  }
}
