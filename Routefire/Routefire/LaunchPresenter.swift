//
//  LaunchPresenter.swift
//  Routefire
//
//  Created by William Robinson on 1/25/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

// Commands sent from view to presenter
protocol LaunchPresenterProtocol {
  func showHomeModule()
}

class LaunchPresenter: LaunchPresenterProtocol {
  
  // Wireframe
  var wireframe: LaunchWireframe!
  
  func showHomeModule() {
    wireframe.transitionToHomeModule()
  }
}

