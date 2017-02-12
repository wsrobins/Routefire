//
//  AppDelegate.swift
//  Routefire
//
//  Created by William Robinson on 1/4/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
//import TouchVisualizer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Activate Google Maps and Places
    GMSServices.provideAPIKey(Secrets.googleAPIKey)
    GMSPlacesClient.provideAPIKey(Secrets.googleAPIKey)
    
    // Set up window
    window = UIWindow(frame: UIScreen.main.bounds)
    window!.rootViewController = LaunchViewController()
    window!.makeKeyAndVisible()
    
    // Observe location status
    NotificationCenter.default.addObserver(self, selector: #selector(noLocationAlert), name: noLocationNotification, object: nil)
    
    // Live demo mode
    //    var config = Configuration()
    //    config.color = UIColor.black
    //    config.defaultSize = CGSize(width: 45, height: 45)
    //    Visualizer.start(config)
    
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated), name: locationUpdatedNotification, object: nil)
    Location.checkAuthorizationStatus()
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    (topVC() as? RouteViewController)?.view.endEditing(true)
  }
}

private extension AppDelegate {
  @objc func locationUpdated() {
    NotificationCenter.default.removeObserver(self, name: locationUpdatedNotification, object: nil)
    switch topVC() {
    case let launchVC where launchVC is LaunchViewController:
      (launchVC as! LaunchViewController).transitionToHomeModule()
    case let routeVC where routeVC is RouteViewController:
      (routeVC as! RouteViewController).destinationField.becomeFirstResponder()
    default:
      return
    }
  }
  
  @objc func noLocationAlert() {
    NotificationCenter.default.removeObserver(self, name: noLocationNotification, object: nil)
    
    let alert = UIAlertController(title: "Enable Location", message: "Please allow location access while using Routefire", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
      let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
      if UIApplication.shared.canOpenURL(settingsURL) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.noLocationAlert), name: noLocationNotification, object: nil)
        UIApplication.shared.open(settingsURL)
      }
    })
    alert.view.layoutIfNeeded()
    topVC().present(alert, animated: true)
  }
  
  func topVC(_ startVC: UIViewController...) -> UIViewController {
    let startVC = startVC.isEmpty ? window!.rootViewController! : startVC.first!
    if let nextVC = startVC.presentedViewController {
      return topVC(nextVC)
    }
    return startVC
  }
}

