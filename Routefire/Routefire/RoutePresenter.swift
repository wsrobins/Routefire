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

protocol RoutePresenterProtocol: class {
  var autocompleteResults: [GMSAutocompletePrediction] { get set }
  var trip: Trip? { get set }
  func transitionToHomeModule()
  func autocomplete(_ text: String, completion: @escaping () -> Void)
  func selectedDestination(at indexPath: IndexPath, timer: Timer)
  func locationName(_ indexPath: IndexPath) -> NSMutableAttributedString
}

final class RoutePresenter: RoutePresenterProtocol {
  weak var view: RouteViewController!
  var wireframe: RouteWireframe!
  
  var trip: Trip?
  var autocompleteResults: [GMSAutocompletePrediction] = []
  
  func transitionToHomeModule() {
    wireframe.transitionToHomeModule(timer: nil)
  }
  
  // Input
  func autocomplete(_ text: String, completion: @escaping () -> Void) {
    guard text != "" else {
      autocompleteResults = []
      completion()
      return
    }
    
    Google.autocomplete(text) { autocompleteResults in
      self.autocompleteResults = autocompleteResults
      completion()
    }
  }
  
  func selectedDestination(at indexPath: IndexPath, timer: Timer) {
    guard let placeID = self.autocompleteResults[indexPath.row].placeID else {
      print("error unwrapping place id")
      return
    }
    
    Google.getPlace(with: placeID) { place in
      self.trip = Trip()
      self.trip!.name = place.name
      
      let group = DispatchGroup()
      
      // Uber estimates
      group.enter()
      Uber.getEstimates(to: place) { priceEstimates, timeEstimates in
        guard let priceEstimates = priceEstimates, let timeEstimates = timeEstimates else {
          self.wireframe.transitionToHomeModule(timer: timer)
          return
        }
        
        for (name, waitTime) in timeEstimates {
          guard let priceEstimate = priceEstimates[name] else {
            continue
          }
          
          let waitMinutes = waitTime / 60 + Int(round(Double(waitTime % 60) / 60))
          let arrivalDate = Calendar.current.date(byAdding: .second, value: priceEstimate["duration"] as! Int, to: Date())!
          var arrivalHour = Calendar.current.component(.hour, from: arrivalDate)
          let arrivalMinute = Calendar.current.component(.minute, from: arrivalDate)
          var minuteString = "\(arrivalMinute)"
          var period: String
          
          if arrivalHour < 12 {
            period = "AM"
            if arrivalHour == 0 {
              arrivalHour = 12
            }
          } else {
            period = "PM"
            if arrivalHour > 12 {
              arrivalHour -= 12
            }
          }
          
          if arrivalMinute < 10 {
            minuteString.insert("0", at: minuteString.startIndex)
          }
          
          let waitTime = "\(waitMinutes) min away"
          let time = "\(arrivalHour):\(minuteString) \(period)"
          let route = Route(
            service: .uber,
            name: name,
            id: priceEstimate["id"] as! String,
            lowPrice: priceEstimate["lowPrice"] as! Int,
            highPrice: priceEstimate["highPrice"] as! Int,
            wait: waitTime,
            arrival: time,
            end: place.coordinate,
            endAddress: place.formattedAddress!
          )
          
          self.trip!.routes.append(route)
        }
        
        group.leave()
      }
      
      // Lyft estimates
      group.enter()
      Lyft.getEstimates(to: place) { estimates in
        for estimate in estimates {
          guard let name = estimate["display_name"] as? String,
            let id = estimate["ride_type"] as? String,
            let lowPrice = estimate["estimated_cost_cents_min"] as? Int,
            let highPrice = estimate["estimated_cost_cents_max"] as? Int,
            let duration = estimate["estimated_duration_seconds"] as? Int,
            lowPrice != 0, highPrice != 0 else {
              continue
          }
          
          let arrivalDate = Calendar.current.date(byAdding: .second, value: duration, to: Date())!
          var arrivalHour = Calendar.current.component(.hour, from: arrivalDate)
          let arrivalMinute = Calendar.current.component(.minute, from: arrivalDate)
          var minuteString = "\(arrivalMinute)"
          var period: String
          
          if arrivalHour < 12 {
            period = "AM"
            if arrivalHour == 0 {
              arrivalHour = 12
            }
          } else {
            period = "PM"
            if arrivalHour > 12 {
              arrivalHour -= 12
            }
          }
          
          if arrivalMinute < 10 {
            minuteString.insert("0", at: minuteString.startIndex)
          }
          
          let arrival = "\(arrivalHour):\(minuteString) \(period)"
          let route = Route(
            service: .lyft,
            name: name,
            id: id,
            lowPrice: Int(round(Double(lowPrice) / 100.0)),
            highPrice: Int(round(Double(highPrice) / 100.0)),
            wait: "",
            arrival: arrival,
            end: place.coordinate,
            endAddress: place.formattedAddress!
          )
          
          self.trip!.routes.append(route)
        }
        
        group.leave()
      }
      
      group.notify(queue: DispatchQueue.main) {
        self.trip!.routes.sort {
          if $0.lowPrice < $1.lowPrice {
            return true
          } else if $0.lowPrice == $1.lowPrice {
            if $0.highPrice < $1.highPrice {
              return true
            } else if $0.highPrice == $1.highPrice {
              if $0.arrival < $1.arrival {
                return true
              }
              
              return $0.name < $1.name
            }
          }
          
          return false
        }
        
        self.wireframe.transitionToHomeModule(timer: timer)
      }
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
