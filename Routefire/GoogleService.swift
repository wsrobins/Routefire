//
//  GoogleService.swift
//  Routefire
//
//  Created by William Robinson on 6/6/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import RxSwift

struct GoogleService {
	
	static func autocomplete(text: String, forLocation location: CLLocationCoordinate2D) -> Observable<[GMSAutocompletePrediction]> {
		return .create { (observer: AnyObserver<[GMSAutocompletePrediction]>) -> Disposable in
			let northeastCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude + 1, longitude: location.longitude - 1)
			let southwestCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude - 1, longitude: location.longitude + 1)
			let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: northeastCoordinate, coordinate: southwestCoordinate)
			let filter: GMSAutocompleteFilter = GMSAutocompleteFilter()
			filter.type = .address
			GMSPlacesClient.shared().autocompleteQuery(text, bounds: bounds, filter: filter) { (predictions: [GMSAutocompletePrediction]?, error: Error?) in
				observer.onNext(predictions ?? [])
			}
			return Disposables.create()
		}
	}
	
	static func lookUpPlace(withID placeID: String) -> Observable<GMSPlace> {
		return .create { (observer: AnyObserver<GMSPlace>) in
			GMSPlacesClient.shared().lookUpPlaceID(placeID) { (place: GMSPlace?, error: Error?) in
				if let place: GMSPlace = place {
					observer.onNext(place)
				}
			}
			return Disposables.create()
		}
	}
}


