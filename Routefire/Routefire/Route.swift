//
//  Route.swift
//  Routefire
//
//  Created by William Robinson on 1/12/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Foundation
import CoreLocation

struct Route {
  enum Service {
    case uber, lyft
  }
  
  let service: Service
  let routeType: String
  let price: String
  let distance: Double
  let start: CLLocationCoordinate2D
  let startAddress: String
  let startNickname: String
  let end: CLLocationCoordinate2D
  let endAddress: String
  let endNickname: String
}
