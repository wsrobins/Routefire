//
//  HomeViewModel.swift
//  Routefire
//
//  Created by William Robinson on 6/2/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import GooglePlaces
import RxCocoa
import RxSwift

protocol HomeViewModelInput: class {
	func bind(autocompleteQuery: ControlProperty<String?>) -> Driver<[Autocompletion]>
}

protocol HomeViewModelOutput: class {
	var currentLocation: Driver<CLLocationCoordinate2D> { get }
}

class HomeViewModel {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Services
	
	fileprivate let locationServiceInput: LocationServiceInput
	fileprivate let locationServiceOutput: LocationServiceOutput
	
	// MARK: Data
	
	fileprivate let defaultAutocompletions: [Autocompletion] = {
		let homeTitle: NSAttributedString = NSAttributedString(string: "Home")
		let workTitle: NSAttributedString = NSAttributedString(string: "Work")
		let otherTitle: NSAttributedString = NSAttributedString(string: "Other")
		return [Autocompletion(title: homeTitle), Autocompletion(title: workTitle), Autocompletion(title: otherTitle)]
	}()
	
	// MARK: Initialization
	
	init(locationService: LocationService) {
		self.locationServiceInput = locationService
		self.locationServiceOutput = locationService
	}
}

// MARK: - Home view model input
extension HomeViewModel: HomeViewModelInput {
	
	func bind(autocompleteQuery: ControlProperty<String?>) -> Driver<[Autocompletion]> {
		return Observable
			.create { (observer: AnyObserver<[Autocompletion]>) -> Disposable in
				observer.onNext(self.defaultAutocompletions)
				autocompleteQuery
					.orEmpty
					.throttle(0.5, scheduler: MainScheduler.instance)
					.distinctUntilChanged()
					.bind { (query: String) in
						self.bindAutocompletions(fromQuery: query, withObserver: observer)
					}
					.disposed(by: self.disposeBag)
				return Disposables.create()
			}
			.asDriver(onErrorJustReturn: [])
	}
	
	private func bindAutocompletions(fromQuery query: String, withObserver observer: AnyObserver<[Autocompletion]>) {
		let location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.7128, longitude: 74.0059)
		GoogleService.autocomplete(text: query, forLocation: location)
			.map { (predictions: [GMSAutocompletePrediction]) -> [Autocompletion] in
				return predictions.map { (prediction: GMSAutocompletePrediction) -> Autocompletion in
					return Autocompletion(title: prediction.attributedFullText)
				}
			}
			.bind { (autocompletions: [Autocompletion]) in
				observer.onNext(self.defaultAutocompletions + autocompletions)
			}
			.disposed(by: self.disposeBag)
	}
}

// MARK: - Home view model output
extension HomeViewModel: HomeViewModelOutput {

	var currentLocation: Driver<CLLocationCoordinate2D> {
		return self.locationServiceOutput.currentLocation
	}
}

