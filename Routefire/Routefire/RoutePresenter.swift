//
//  RouteViewModel.swift
//  Routefire
//
//  Created by William Robinson on 1/10/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Foundation
import Alamofire
import GooglePlaces

protocol RoutePresenterProtocol {
  var autocompleteResults: [GMSAutocompletePrediction] { get }
  func transitionToHomeModule(routing: (routes: [Route], destinationName: String)?)
  func autocomplete(_ text: String, completion: @escaping () -> Void)
  func selectedDestination(at indexPath: IndexPath, completion: @escaping () -> Void)
  func locationName(_ indexPath: IndexPath) -> NSMutableAttributedString
}

final class RoutePresenter: RoutePresenterProtocol {
  weak var view: RouteViewController!
  var wireframe: RouteWireframe!
  
  var autocompleteResults = [GMSAutocompletePrediction]()
  
  func transitionToHomeModule(routing: (routes: [Route], destinationName: String)?) {
    wireframe.transitionToHomeModule(routing: routing)
  }
  
  // Input
  func autocomplete(_ text: String, completion: @escaping () -> Void) {
    Google.autocomplete(text) { autocompleteResults in
      DispatchQueue.main.async {
        self.autocompleteResults = autocompleteResults
        completion()
      }
    }
  }
  
  func selectedDestination(at indexPath: IndexPath, completion: @escaping () -> Void) {
    guard let placeID = self.autocompleteResults[indexPath.row].placeID else {
      print("error unwrapping place id")
      completion()
      return
    }
    
    Google.getPlace(with: placeID) { place in
      Uber.getEstimates(to: place.coordinate) { uberEstimates in
        
        print(uberEstimates)
    
        var routes = [Route]()
        
        for uberEstimate in uberEstimates {
          
          
          //            guard let routeType = priceDict["localized_display_name"] as? String,
          //              let price = priceDict["estimate"] as? String,
          //              let distance = priceDict["distance"] as? Double else {
          //                print("error unwrapping uber price info")
          //                completion()
          //                return
          //            }
          //
          //            let route = Route(service: .uber, routeType: routeType, price: price, distance: distance, start: start, startAddress: "654 Flatbush Ave, Brooklyn, NY 11225", startNickname: "Home", end: end.coordinate, endAddress: end.formattedAddress ?? "", endNickname: end.name)
          //            routes.append(route)
        }
      }
      
      completion()
      //        self.wireframe.showBestRoutes(self.view, routes: routes, destinationName: end.name)
    }
  }
  
  
  // Presentation logic
  func locationName(_ indexPath: IndexPath) -> NSMutableAttributedString {
    let locationName = autocompleteResults[indexPath.row].attributedFullText.mutableCopy() as! NSMutableAttributedString
    locationName.enumerateAttribute(kGMSAutocompleteMatchAttribute, in: NSMakeRange(0, locationName.length), options: []) { value, range, _ in
      var attributes: [String : Any]
      
      if value != nil {
        attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 14, weight: UIFontWeightBold),
                      NSForegroundColorAttributeName : UIColor.black]
      } else {
        attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin),
                      NSForegroundColorAttributeName : UIColor.lightGray]
      }
      
      locationName.addAttributes(attributes, range: range)
    }
    
    return locationName
  }
}
