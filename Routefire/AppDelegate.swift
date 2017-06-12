//
//  AppDelegate.swift
//  Routefire
//
//  Created by William Robinson on 5/1/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import Material

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

	// MARK: Window
	
	var window: UIWindow?
	
	// MARK: Launch

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		self.authorizeGMSServices()
		self.setUpWindow()
		return true
	}
	
	private func authorizeGMSServices() {
		GMSServices.provideAPIKey(Secrets.googleAPIKey)
		GMSPlacesClient.provideAPIKey(Secrets.googleAPIKey)
	}
	
	private func setUpWindow() {
		self.window = UIWindow()
		self.window?.rootViewController = AppNavigationController()
		self.window?.makeKeyAndVisible()
	}
}

