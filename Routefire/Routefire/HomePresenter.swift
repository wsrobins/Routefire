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
  var networkReachable: Bool { get }
  var bestRoutes: [Route] { get set }
  var uberProductIDs: [String] { get }
  func observeReachability()
  func reachabilityChanged(notification: Notification)
  func setMapCamera(initial: Bool)
  func transitionToRouteModule()
  func selectedRoute(at indexPath: IndexPath)
}

class HomePresenter: HomePresenterProtocol {
  weak var view: HomeViewProtocol!
  var wireframe: HomeWireframeProtocol!
  
  var uberProductIDs: [String] = []
  var bestRoutes: [Route] = []
  var networkReachable: Bool {
    return Network.reachable
  }
  
  func observeReachability() {
    NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
    Network.startNotifier()
  }
  
  @objc func reachabilityChanged(notification: Notification) {
    DispatchQueue.main.async {
      self.view.toggleReachabilityView((notification.object as! Reachability).isReachable)
    }
  }
  
  func setMapCamera(initial: Bool) {
    if initial {
      view.setInitialMapCamera(to: Location.current, withZoom: 12)
    } else {
      self.view.zoomMapCamera(to: Location.current, withZoom: 15)
    }
  }
  
  func transitionToRouteModule() {
    wireframe.transitionToRouteModule()
  }
  
  func selectedRoute(at indexPath: IndexPath) {
    //    let route = bestRoutes[indexPath.row]
    //    let pickupLat = route.start.latitude.description
    //    let pickupLong = route.start.longitude.description
    //    let dropoffLat = route.end.latitude.description
    //    let dropoffLong = route.end.longitude.description
    
    //    switch route.service {
    //    case .uber:
    //      if UIApplication.shared.canOpenURL(URL(fileURLWithPath: "uber://")) {
    //        let productID: String
    //        switch route.routeType {
    //        case "uberPOOL":
    //          productID = uberProductIDs["uberPOOL"] ?? ""
    //        case "uberX":
    //          productID = uberProductIDs["uberX"] ?? ""
    //        case "uberXL":
    //          productID = uberProductIDs["uberXL"] ?? ""
    //        case "UberBLACK":
    //          productID = uberProductIDs["UberBLACK"] ?? ""
    //        case "SUV":
    //          productID = uberProductIDs["SUV"] ?? ""
    //        case "WAV":
    //          productID = uberProductIDs["WAV"] ?? ""
    //        case "uberFAMILY":
    //          productID = uberProductIDs["uberFAMILY"] ?? ""
    //        default:
    //          productID = ""
    //        }
    //
    //        let urlString = "uber://?client_id=\(Secrets.uberClientID)&action=setPickup&pickup[latitude]=\(pickupLat)&pickup[longitude]=\(pickupLong)&pickup[nickname]=\(route.startNickname)&pickup[formatted_address]=\(route.startAddress)&dropoff[latitude]=\(dropoffLat)&dropoff[longitude]=\(dropoffLong)&dropoff[nickname]=\(route.endNickname)&dropoff[formatted_address]=\(route.endAddress)&product_id=\(productID)"
    //        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
    //          let uberURL = URL(string: encodedURLString) else { return }
    //
    //        UIApplication.shared.open(uberURL, options: [:], completionHandler: nil)
    //      } else {
    //        print("uber not installed")
    //      }
    //    case .lyft:
    //      return
    //    }
  }
}
