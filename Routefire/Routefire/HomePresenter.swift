//
//  HomePresenter.swift
//  Routefire
//
//  Created by William Robinson on 1/11/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import ReachabilitySwift

protocol HomePresenterProtocol: class {
  var trip: Trip? { get set }
  var uberProductIDs: [String] { get }
  var networkReachable: Bool { get }
  func transitionToRouteModule()
  func setMapCamera(initial: Bool)
  func checkForRoutes()
  func sortRoutes(_ type: String)
  func selectedRoute(at indexPath: IndexPath)
  func observeReachability()
}

protocol HomePresenterRouteModuleProtocol: class {
  func setTrip(_ trip: Trip?)
}

class HomePresenter: HomePresenterProtocol {
  weak var view: HomeViewProtocol!
  var wireframe: HomeWireframeProtocol!
  
  var trip: Trip?
  var uberProductIDs: [String] = []
  var networkReachable: Bool {
    return Network.reachable
  }
  
  func transitionToRouteModule() {
    wireframe.transitionToRouteModule()
  }
  
  func setMapCamera(initial: Bool) {
    if initial {
      view.setInitialMapCamera(to: Location.current, withZoom: 18)
    } else {
      self.view.zoomMapCamera(to: Location.current, withZoom: 14)
    }
  }
  
  func checkForRoutes() {
    if trip != nil, trip!.routes.isEmpty {
      self.view.noRoutesPopup()
    }
  }
  
  func sortRoutes(_ type: String) {
    switch type {
    case "Price":
      trip!.routes.sort {
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
    case "Time":
      trip!.routes.sort {
        if $0.arrival < $1.arrival {
          return true
        } else if $0.arrival == $1.arrival {
          if $0.lowPrice < $1.lowPrice {
            return true
          } else if $0.lowPrice == $1.lowPrice {
            if $0.highPrice < $1.highPrice {
              return true
            }
            return $0.name < $1.name
          }
        }
        return false
      }
    default:
      return
    }
  }
  
  func selectedRoute(at indexPath: IndexPath) {
    let route = trip!.routes[indexPath.row]
    let pickupLat = route.start.latitude.description
    let pickupLong = route.start.longitude.description
    let dropoffLat = route.end.latitude.description
    let dropoffLong = route.end.longitude.description
    
    switch route.service {
    case .uber:
      if UIApplication.shared.canOpenURL(URL(fileURLWithPath: "uber://")) {
        let productID: String
        switch route.name {
        case "uberPOOL":
          productID = route.id
        case "uberX":
          productID = route.id
        case "uberXL":
          productID = route.id
        case "UberBLACK":
          productID = route.id
        case "SUV":
          productID = route.id
        case "WAV":
          productID = route.id
        case "uberFAMILY":
          productID = route.id
        default:
          productID = ""
        }
        
        let urlString = "uber://?client_id=\(Secrets.uberClientID)&action=setPickup&pickup[latitude]=\(pickupLat)&pickup[longitude]=\(pickupLong)&pickup[nickname]=\(route.startName)&dropoff[latitude]=\(dropoffLat)&dropoff[longitude]=\(dropoffLong)&dropoff[formatted_address]=\(route.endAddress)&product_id=\(productID)"
        let uberURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        UIApplication.shared.open(uberURL, options: [:])
      } else {
        UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/uber/id368677368?mt=8")!, options: [:])
      }
    case .lyft:
      if UIApplication.shared.canOpenURL(URL(fileURLWithPath: "lyft://")) {
        let id: String
        switch route.name {
        case "Lyft":
          id = "lyft"
        case "Lyft Line":
          id = "lyft_line"
        case "Lyft Plus":
          id = "lyft_plus"
        default:
          id = ""
        }
        
        let urlString = "lyft://ridetype?id=\(id)&pickup[latitude]=\(route.start.latitude)&pickup[longitude]=\(route.start.longitude)&destination[latitude]=\(route.end.latitude)&destination[longitude]=\(route.end.longitude)"
        let lyftURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        UIApplication.shared.open(lyftURL, options: [:])
      } else {
        UIApplication.shared.open(URL(string: "https://itunes.apple.com/us/app/lyft-taxi-app-alternative/id529379082?mt=8")!, options: [:])
      }
    }
  }
  
  // Ensure network connectivity
  func observeReachability() {
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
    Network.startNotifier()
  }
  
  @objc func reachabilityChanged() {
    DispatchQueue.main.async {
      self.view.toggleReachabilityView()
    }
  }
}

// Set trip from route module
extension HomePresenter: HomePresenterRouteModuleProtocol {
  func setTrip(_ trip: Trip?) {
    if let trip = trip  {
      self.trip = trip
      sortRoutes("Price")
      view.routesLayout(trip)
    }
  }
}
