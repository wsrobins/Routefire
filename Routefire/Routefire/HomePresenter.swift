//
//  HomePresenter.swift
//  Routefire
//
//  Created by William Robinson on 1/11/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation

protocol HomePresenterProtocol: class {
  var bestRoutes: [Route] { get set }
  func configureLocation()
  func updateLocation(_ change: [NSKeyValueChangeKey : Any]?)
}

class HomePresenter {
  
  // View
  weak var view: HomeViewProtocol!
  
  // Wireframe
  var wireframe: HomeWireframeProtocol!
  
  // MARK: Properties
  var bestRoutes = [Route]()
  var didFindMyLocation = false
  
  @objc func locationAuthorized() {
    view.enableCurrentLocationOnMap()
  }
}

// MARK: - Home presenter protocol
extension HomePresenter: HomePresenterProtocol {
  func configureLocation() {
    NotificationCenter.default.addObserver(self, selector: #selector(locationAuthorized), name: Constants.locationAuthorizedNotification, object: nil)
    Location.shared.configureManager()
  }
  
  func updateLocation(_ change: [NSKeyValueChangeKey : Any]?) {
    guard !didFindMyLocation, let myLocation = (change?[NSKeyValueChangeKey.newKey] as? CLLocation)?.coordinate else { return }
    didFindMyLocation = true
    view.zoomTo(myLocation)
  }
}

