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
  func autocomplete(_ text: String, completion: @escaping () -> Void)
  func selectedDestination(at indexPath: IndexPath)
  func locationName(_ indexPath: IndexPath) -> NSMutableAttributedString
}

final class RoutePresenter: RoutePresenterProtocol {
  weak var view: RouteViewController!
  var interactor: RouteInteractor!
  var router: RouteRouter!
  
  // MARK: Output
  var autocompleteResults = [GMSAutocompletePrediction]()
  
  // MARK: Input
  func autocomplete(_ text: String, completion: @escaping () -> Void) {
    interactor.autocomplete(text) {
      self.autocompleteResults = $0
      completion()
    }
  }
  
  func selectedDestination(at indexPath: IndexPath) {
    guard let start = Location.shared.current,
      let destinationID = autocompleteResults[indexPath.row].placeID else {
        print("error unwrapping locations")
        return
    }
    
    interactor.getPlace(destinationID) { end in
      var routes = [Route]()
      self.interactor.getUberPriceEstimates(start: start, end: end.coordinate) { uberPrices in
        if let uberPrices = uberPrices {
          for priceDict in uberPrices {
            guard let routeType = priceDict["localized_display_name"] as? String,
              let price = priceDict["estimate"] as? String,
              let distance = priceDict["distance"] as? Double else {
                print("error unwrapping uber price info")
                return
            }
            
            let route = Route(service: .uber, routeType: routeType, price: price, distance: distance, start: start, startAddress: "654 Flatbush Ave, Brooklyn, NY 11225", startNickname: "Home", end: end.coordinate, endAddress: end.formattedAddress ?? "", endNickname: end.name)
            routes.append(route)
          }
        }
        
        self.router.showBestRoutes(self.view, routes: routes, destinationName: end.name)
      }
    }
  }
  
  // MARK: Presentation logic
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
