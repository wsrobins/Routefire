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
}

class RouteRouter: NSObject, RouteRouterProtocol {
  func back(_ routeView: RouteViewController) {
    routeView.dismiss(animated: true, completion: nil)
  }
}
