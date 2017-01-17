//
//  Places.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Foundation
import GooglePlaces

final class Places {
  static let shared = Places()
  private init() {}
  
  // MARK: Autocomplete destination
  func autocomplete(_ text: String, completion: @escaping([GMSAutocompletePrediction]) -> Void) {
    
    // New York City bounds
    let northWest = CLLocationCoordinate2D(latitude: 40.917577, longitude: -74.259090)
    let southEast = CLLocationCoordinate2D(latitude: 40.477399, longitude: -73.700272)
    let bounds = GMSCoordinateBounds(coordinate: northWest, coordinate: southEast)
    
    // Request
    GMSPlacesClient.shared().autocompleteQuery(text, bounds: bounds, filter: nil) { results, error in
      guard let results = results, error == nil else {
        print("error during destination autocompletion: \(error)")
        return
      }
      
      completion(results)
    }
  }
}
