//
//  RouteRouter.swift
//  Routefire
//
//  Created by William Robinson on 1/19/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol RouteRouterProtocol {
  func back(_ routeView: RouteViewController)
  func showBestRoutes(_ routeView: RouteViewController, routes: [Route], destinationName: String)
}

class RouteRouter: NSObject, RouteRouterProtocol {
  func back(_ routeView: RouteViewController) {
    routeView.dismiss(animated: true, completion: nil)
  }
  
  func showBestRoutes(_ routeView: RouteViewController, routes: [Route], destinationName: String) {
    let homeView = routeView.presentingViewController as! HomeViewController
    homeView.presenter?.bestRoutes = routes
    homeView.bestRoutesAddressButton.setTitle(destinationName, for: .normal)
    homeView.bestRoutesView.isHidden = false
    homeView.bestRoutesCollectionView.reloadData()
    routeView.dismiss(animated: true, completion: nil)
  }
}
