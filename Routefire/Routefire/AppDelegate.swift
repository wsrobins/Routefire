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
    
    // Live demo mode
//    var config = Configuration()
//    config.color = UIColor.black
//    config.defaultSize = CGSize(width: 45, height: 45)
//    Visualizer.start(config)
    
    return true
  }
}

