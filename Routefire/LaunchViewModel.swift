//
//  LaunchViewModel.swift
//  Routefire
//
//  Created by William Robinson on 6/10/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import RxCocoa


protocol LaunchViewModelInput {
	func requestLocationAuthorization()
	func requestLocation()
}

protocol LaunchViewModelOutput {
	var locationAuthorizationStatus: Driver<CLAuthorizationStatus> { get }
	var currentLocation: Driver<CLLocationCoordinate2D> { get }
}

struct LaunchViewModel {
	
	// MARK: Services
	
	fileprivate let locationServiceInput: LocationServiceInput
	fileprivate let locationServiceOutput: LocationServiceOutput
	
	// MARK: Initialization
	
	init(locationService: LocationService) {
		self.locationServiceInput = locationService
		self.locationServiceOutput = locationService
	}
}

// MARK: - Launch view model input
extension LaunchViewModel: LaunchViewModelInput {
	
	func requestLocationAuthorization() {
		self.locationServiceInput.requestAuthorization()
	}
	
	func requestLocation() {
		self.locationServiceInput.requestLocation()
	}
}

// MARK: - Launch view model output
extension LaunchViewModel: LaunchViewModelOutput {

	var locationAuthorizationStatus: Driver<CLAuthorizationStatus> {
		return self.locationServiceOutput.authorizationStatus
	}
	
	var currentLocation: Driver<CLLocationCoordinate2D> {
		return self.locationServiceOutput.currentLocation
	}
}
