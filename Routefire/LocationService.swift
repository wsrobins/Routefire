//
//  LocationService.swift
//  Routefire
//
//  Created by William Robinson on 6/3/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

protocol LocationServiceInput {
	func requestAuthorization()
	func requestLocation()
	func startUpdatingLocation()
	func stopUpdatingLocation()
}

protocol LocationServiceOutput {
	var authorizationStatus: Driver<CLAuthorizationStatus> { get }
	var currentLocation: Driver<CLLocationCoordinate2D> { get }
}

struct LocationService {
	
	// MARK: Location manager
	
	fileprivate let locationManager: CLLocationManager = CLLocationManager()
	
	// MARK: Initialization
	
	init() {
		self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
	}
}

// MARK: - Location service input
extension LocationService: LocationServiceInput {
	
	func requestAuthorization() {
		self.locationManager.requestWhenInUseAuthorization()
	}
	
	func requestLocation() {
		self.locationManager.requestLocation()
	}
	
	func startUpdatingLocation() {
		self.locationManager.startUpdatingLocation()
	}
	
	func stopUpdatingLocation() {
		self.locationManager.stopUpdatingLocation()
	}
}

// MARK: - Location service output
extension LocationService: LocationServiceOutput {
	
	var authorizationStatus: Driver<CLAuthorizationStatus> {
		return Observable
			.deferred {
				return self.locationManager.rx.didChangeAuthorizationStatus.startWith(CLLocationManager.authorizationStatus())
			}
			.asDriver(onErrorJustReturn: .notDetermined)
	}
	
	var currentLocation: Driver<CLLocationCoordinate2D> {
		return self.locationManager.rx.didUpdateLocations
			.asDriver(onErrorJustReturn: [])
			.flatMap { (locations: [CLLocation]) -> Driver<CLLocation> in
				return locations.last.map(Driver.just) ?? .empty()
			}
			.map { (location: CLLocation) -> CLLocationCoordinate2D in
				return location.coordinate
		}
	}
}

