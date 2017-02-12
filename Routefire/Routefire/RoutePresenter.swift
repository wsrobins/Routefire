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
import ReachabilitySwift

protocol RoutePresenterProtocol: class {
  var autocompleteResults: [GMSAutocompletePrediction] { get set }
  var trip: Trip? { get set }
  func transitionToHomeModule()
  func checkForTrip()
  func autocomplete(_ name: String...)
  func selectedDestination(at indexPath: IndexPath)
  func locationName(for indexPath: IndexPath, withFontSize fontSize: CGFloat) -> NSMutableAttributedString
  func observeReachability()
}

final class RoutePresenter: RoutePresenterProtocol {
  weak var view: RouteViewProtocol!
  var wireframe: RouteWireframe!
  
  var trip: Trip?
  var autocompleteResults: [GMSAutocompletePrediction] = []
  var loadingTimer: Timer?
  
  func transitionToHomeModule() {
    wireframe.transitionToHomeModule()
  }
  
  func checkForTrip() {
    if let name = trip?.name {
      DispatchQueue.main.async {
        self.view.setName(name)
      }
      autocomplete(name)
    }
  }
  
  func autocomplete(_ name: String...) {
    let textInput = name.isEmpty ? view.getTextInput() : name.first!
    guard textInput != "", Network.reachable else {
      DispatchQueue.main.async {
        self.autocompleteResults = []
        self.view.refresh()
      }
      return
    }
    
    Google.autocomplete(textInput) { autocompleteResults in
      DispatchQueue.main.async {
        self.autocompleteResults = autocompleteResults
        self.view.refresh()
      }
    }
  }
  
  func selectedDestination(at indexPath: IndexPath) {
    var success = false
    guard Network.reachable, let placeID = self.autocompleteResults[indexPath.row].placeID else {
      doneLoading(success)
      return
    }
    
    loadingTimer = view.loading()
    Google.getPlace(with: placeID) { place in
      guard let place = place else {
        self.doneLoading(success)
        return
      }
      
      self.trip = Trip()
      self.trip!.name = place.name
      let group = DispatchGroup()
      
      // Uber estimates
      group.enter()
      Uber.getEstimates(to: place) { priceEstimates, timeEstimates in
        if let priceEstimates = priceEstimates, let timeEstimates = timeEstimates {
          success = true
          for (name, waitTime) in timeEstimates {
            guard let priceEstimate = priceEstimates[name],
              let id = priceEstimate["id"] as? String,
              let lowPrice = priceEstimate["lowPrice"] as? Int,
              let highPrice = priceEstimate["highPrice"] as? Int,
              let duration = priceEstimate["duration"] as? Int else { continue }
            let wait = "\(waitTime / 60 + Int(round(Double(waitTime % 60) / 60))) min away"
            let arrivalDate = Calendar.current.date(byAdding: .second, value: duration, to: Date())!
            let arrivalHour = Calendar.current.component(.hour, from: arrivalDate)
            let arrivalMinute = Calendar.current.component(.minute, from: arrivalDate)
            let arrival = "\(arrivalHour == 0 ? 12 : arrivalHour % 12):\(arrivalMinute < 10 ? "0" : "")\(arrivalMinute) \(arrivalHour < 12 ? "AM" : "PM")"
            self.trip!.routes.append(Route(service: .uber, name: name, id: id, lowPrice: lowPrice, highPrice: highPrice, wait: wait, arrival: arrival, end: place.coordinate, endAddress: place.formattedAddress!))
          }
        }
        group.leave()
      }
      
      // Lyft estimates
      group.enter()
      Lyft.getEstimates(to: place) { estimates in
        if let estimates = estimates {
          success = true
          for estimate in estimates {
            guard let name = estimate["display_name"] as? String,
              let id = estimate["ride_type"] as? String,
              let lowPriceCents = estimate["estimated_cost_cents_min"] as? Int,
              let highPriceCents = estimate["estimated_cost_cents_max"] as? Int,
              let duration = estimate["estimated_duration_seconds"] as? Int,
              lowPriceCents > 0, highPriceCents > 0 else { continue }
            let lowPrice = Int(round(Double(lowPriceCents) / 100.0))
            let highPrice = Int(round(Double(highPriceCents) / 100.0))
            let arrivalDate = Calendar.current.date(byAdding: .second, value: duration, to: Date())!
            let arrivalHour = Calendar.current.component(.hour, from: arrivalDate)
            let arrivalMinute = Calendar.current.component(.minute, from: arrivalDate)
            let arrival = "\(arrivalHour == 0 ? 12 : arrivalHour % 12):\(arrivalMinute < 10 ? "0" : "")\(arrivalMinute) \(arrivalHour < 12 ? "AM" : "PM")"
            self.trip!.routes.append(Route(service: .lyft, name: name, id: id, lowPrice: lowPrice, highPrice: highPrice, wait: "", arrival: arrival, end: place.coordinate, endAddress: place.formattedAddress!))
          }
        } else {
          success = false
        }
        group.leave()
      }
      
      group.notify(queue: DispatchQueue.main) {
        self.doneLoading(success)
      }
    }
  }
  
  func doneLoading(_ success: Bool) {
    view.doneLoading(success)
    loadingTimer?.invalidate()
    if success {
      transitionToHomeModule()
    }
  }
  
  // Presentation logic
  func locationName(for indexPath: IndexPath, withFontSize fontSize: CGFloat) -> NSMutableAttributedString {
    let locationName = autocompleteResults[indexPath.row].attributedFullText.mutableCopy() as! NSMutableAttributedString
    locationName.enumerateAttribute(kGMSAutocompleteMatchAttribute, in: NSMakeRange(0, locationName.length), options: []) { value, range, _ in
      var attributes: [String : Any]
      if value != nil {
        attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightBold),
                      NSForegroundColorAttributeName : UIColor.black]
      } else {
        attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightThin),
                      NSForegroundColorAttributeName : UIColor.lightGray]
      }
      locationName.addAttributes(attributes, range: range)
    }
    return locationName
  }
  
  // Ensure network connectivity
  func observeReachability() {
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
    Network.startNotifier()
  }
  
  @objc func reachabilityChanged() {
    if Network.reachable {
      autocomplete()
    }
  }
}
