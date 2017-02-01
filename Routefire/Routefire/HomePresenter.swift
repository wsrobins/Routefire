//
//  HomePresenter.swift
//  Routefire
//
//  Created by William Robinson on 1/11/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import GooglePlaces
import ReachabilitySwift

protocol HomePresenterProtocol: class {
  var trip: Trip? { get set }
  var uberProductIDs: [String] { get }
  var networkReachable: Bool { get }
  func transitionToRouteModule()
  func setMapCamera(initial: Bool)
  func selectedRoute(at indexPath: IndexPath)
  func observeReachability()
  func reachabilityChanged(notification: Notification)
}

class HomePresenter: HomePresenterProtocol {
  weak var view: HomeViewProtocol!
  var wireframe: HomeWireframeProtocol!
  
  var trip: Trip?
  var uberProductIDs: [String] = []
  var networkReachable: Bool {
    return Network.reachable
  }
  
  func setMapCamera(initial: Bool) {
    if initial {
      view.setInitialMapCamera(to: Location.current, withZoom: 18)
    } else {
      self.view.zoomMapCamera(to: Location.current, withZoom: 14)
    }
  }
  
  func transitionToRouteModule() {
    wireframe.transitionToRouteModule()
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
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let uberURL = URL(string: encodedURLString) else {
            return
        }
        
        UIApplication.shared.open(uberURL, options: [:], completionHandler: nil)
      } else {
        print("uber not installed")
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
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let lyftURL = URL(string: encodedURLString) else {
            return
        }
        
        UIApplication.shared.open(lyftURL, options: [:], completionHandler: nil)
      } else {
        print("lyft not installed")
      }
    }
  }
  
  func observeReachability() {
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
    Network.startNotifier()
  }
  
  @objc func reachabilityChanged(notification: Notification) {
    self.view.toggleReachabilityView((notification.object as! Reachability).isReachable)
  }
}
