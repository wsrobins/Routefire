//
//  Location.swift
//  Routefire
//
//  Created by William Robinson on 1/26/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation

final class Location: NSObject {
  static var current: CLLocationCoordinate2D! {
    return shared.locationManager.location!.coordinate
  }
  
  static private let shared = Location()
  fileprivate let locationManager = CLLocationManager()
  private override init() {
    super.init()
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.delegate = self
  }
  
  static func checkAuthorizationStatus() {
    switch CLLocationManager.authorizationStatus() {
    case .authorizedWhenInUse:
      shared.locationManager.startUpdatingLocation()
    case .notDetermined:
      shared.locationManager.requestWhenInUseAuthorization()
    default:
      NotificationCenter.default.post(Notification(name: noLocationNotification))
    }
  }
}

// Location manager delegate
extension Location: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    NotificationCenter.default.post(name: locationUpdatedNotification, object: nil)
  }
}


