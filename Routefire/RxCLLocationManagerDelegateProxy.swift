//
//  RxCLLocationManagerDelegateProxy.swift
//  Routefire
//
//  Created by William Robinson on 6/3/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class RxCLLocationManagerDelegateProxy: DelegateProxy, CLLocationManagerDelegate, DelegateProxyType {
	
	internal lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
	internal lazy var didFailWithErrorSubject = PublishSubject<Error>()
	
	class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
		let locationManager: CLLocationManager = object as! CLLocationManager
		return locationManager.delegate
	}
	
	class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
		let locationManager: CLLocationManager = object as! CLLocationManager
		if let delegate = delegate {
			locationManager.delegate = (delegate as! CLLocationManagerDelegate)
		} else {
			locationManager.delegate = nil
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		_forwardToDelegate?.locationManager(manager, didUpdateLocations: locations)
		didUpdateLocationsSubject.onNext(locations)
	}
	
	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		_forwardToDelegate?.locationManager(manager, didFailWithError: error)
		didFailWithErrorSubject.onNext(error)
	}
	
	deinit {
		self.didUpdateLocationsSubject.on(.completed)
		self.didFailWithErrorSubject.on(.completed)
	}
}
