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
  let name: String
  let id: String
  let lowPrice: Int
  let highPrice: Int
  var wait: String
  var arrival: String
  let start = Location.current!
  let startName = "Current location"
  let end: CLLocationCoordinate2D
  let endAddress: String
}
