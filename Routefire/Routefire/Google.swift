//
//  Google.swift
//  Routefire
//
//  Created by William Robinson on 1/29/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Alamofire
import GooglePlaces

final class Google {
  static func autocomplete(_ text: String, completion: @escaping([GMSAutocompletePrediction]) -> Void) {
    let northWest = CLLocationCoordinate2D(latitude: Location.current.latitude - 1, longitude: Location.current.longitude - 1)
    let southEast = CLLocationCoordinate2D(latitude: Location.current.latitude + 1, longitude: Location.current.longitude + 1)
    let bounds = GMSCoordinateBounds(coordinate: northWest, coordinate: southEast)
    GMSPlacesClient.shared().autocompleteQuery(text, bounds: bounds, filter: nil) { results, error in
      guard let results = results, error == nil else {
        print("error during autocompletion: \(error)")
        return
      }
      
      completion(results)
    }
  }
  
  static func getPlace(with placeID: String, completion: @escaping (GMSPlace) -> Void) {
    GMSPlacesClient.shared().lookUpPlaceID(placeID) { place, error in
      guard let place = place, error == nil else {
        print("error retrieving google place: \(error)")
        return
      }
      
      completion(place)
    }
  }
}
