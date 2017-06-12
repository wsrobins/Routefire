//
//  CLLocationManagerRxExtensions.swift
//  Routefire
//
//  Created by William Robinson on 6/3/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

extension Reactive where Base: CLLocationManager {
	
	public var delegate: DelegateProxy {
		return RxCLLocationManagerDelegateProxy.proxyForObject(base)
	}
	
	public var didUpdateLocations: Observable<[CLLocation]> {
		return (delegate as! RxCLLocationManagerDelegateProxy).didUpdateLocationsSubject.asObservable()
	}
	
	public var didFailWithError: Observable<Error> {
		return (delegate as! RxCLLocationManagerDelegateProxy).didFailWithErrorSubject.asObservable()
	}
	
	public var didFinishDeferredUpdatesWithError: Observable<Error?> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFinishDeferredUpdatesWithError:)))
			.map { a in
				return try castOptionalOrThrow(Error.self, a[1])
		}
	}
	
	public var didPauseLocationUpdates: Observable<Void> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:)))
			.map { _ in
				return ()
		}
	}
	
	public var didResumeLocationUpdates: Observable<Void> {
		return delegate.methodInvoked( #selector(CLLocationManagerDelegate.locationManagerDidResumeLocationUpdates(_:)))
			.map { _ in
				return ()
		}
	}
	
	public var didUpdateHeading: Observable<CLHeading> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateHeading:)))
			.map { a in
				return try castOrThrow(CLHeading.self, a[1])
		}
	}
	
	public var didEnterRegion: Observable<CLRegion> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didEnterRegion:)))
			.map { a in
				return try castOrThrow(CLRegion.self, a[1])
		}
	}
	
	public var didExitRegion: Observable<CLRegion> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:)))
			.map { a in
				return try castOrThrow(CLRegion.self, a[1])
		}
	}
	
	public var didDetermineStateForRegion: Observable<(state: CLRegionState, region: CLRegion)> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didDetermineState:for:)))
			.map { a in
				let stateNumber = try castOrThrow(NSNumber.self, a[1])
				let state = CLRegionState(rawValue: stateNumber.intValue) ?? CLRegionState.unknown
				let region = try castOrThrow(CLRegion.self, a[2])
				return (state: state, region: region)
		}
	}
	
	public var monitoringDidFailForRegionWithError: Observable<(region: CLRegion?, error: Error)> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:monitoringDidFailFor:withError:)))
			.map { a in
				let region = try castOptionalOrThrow(CLRegion.self, a[1])
				let error = try castOrThrow(Error.self, a[2])
				return (region: region, error: error)
		}
	}
	
	public var didStartMonitoringForRegion: Observable<CLRegion> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didStartMonitoringFor:)))
			.map { a in
				return try castOrThrow(CLRegion.self, a[1])
		}
	}
	
	public var didRangeBeaconsInRegion: Observable<(beacons: [CLBeacon], region: CLBeaconRegion)> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didRangeBeacons:in:)))
			.map { a in
				let beacons = try castOrThrow([CLBeacon].self, a[1])
				let region = try castOrThrow(CLBeaconRegion.self, a[2])
				return (beacons: beacons, region: region)
		}
	}
	
	public var rangingBeaconsDidFailForRegionWithError: Observable<(region: CLBeaconRegion, error: Error)> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:rangingBeaconsDidFailFor:withError:)))
			.map { a in
				let region = try castOrThrow(CLBeaconRegion.self, a[1])
				let error = try castOrThrow(Error.self, a[2])
				return (region: region, error: error)
		}
	}
	
	@available(iOS 8.0, *)
	public var didVisit: Observable<CLVisit> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didVisit:)))
			.map { a in
				return try castOrThrow(CLVisit.self, a[1])
		}
	}
	
	public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
		return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
			.map { a in
				let number = try castOrThrow(NSNumber.self, a[1])
				return CLAuthorizationStatus(rawValue: Int32(number.intValue)) ?? .notDetermined
		}
	}
}


fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
	guard let returnValue = object as? T else {
		throw RxCocoaError.castingError(object: object, targetType: resultType)
	}
	
	return returnValue
}

fileprivate func castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
	if NSNull().isEqual(object) {
		return nil
	}
	
	guard let returnValue = object as? T else {
		throw RxCocoaError.castingError(object: object, targetType: resultType)
	}
	
	return returnValue
}
