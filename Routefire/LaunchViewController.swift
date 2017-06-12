//
//  LaunchViewController.swift
//  Routefire
//
//  Created by William Robinson on 6/2/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

final class LaunchViewController: UIViewController {
	
	// MARK: Resource disposal
	
	private let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Status bar
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	// MARK: View
	
	private var viewInput: LaunchViewInput {
		return self.view as! LaunchViewInput
	}
	
	// MARK: View model
	
	private let viewModelInput: LaunchViewModelInput
	private let viewModelOutput: LaunchViewModelOutput
	
	// MARK: Wireframe
	
	private unowned let wireframe: Wireframe
	
	// MARK: Initialization
	
	init(viewModel: LaunchViewModel, wireframe: Wireframe) {
		self.viewModelInput = viewModel
		self.viewModelOutput = viewModel
		self.wireframe = wireframe
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	// MARK: Life cycle
	
	override func loadView() {
		self.view = LaunchView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			self.observeLocationAuthorizationStatus()
		}
	}
	
	// MARK: Observation
	
	private func observeLocationAuthorizationStatus() {
		self.viewModelOutput.locationAuthorizationStatus
			.drive(onNext: { [unowned self] (status: CLAuthorizationStatus) in
				switch status {
				case .notDetermined:
					self.viewModelInput.requestLocationAuthorization()
				case .authorizedWhenInUse:
					self.observeCurrentLocation()
					self.viewModelInput.requestLocation()
				case .denied:
					self.alertLocationAuthorizationDenied()
				default:
					return
				}
			})
			.disposed(by: self.disposeBag)
	}
	
	private func observeCurrentLocation() {
		self.viewModelOutput.currentLocation
			.asObservable()
			.take(1)
			.subscribe(onNext: { (location: CLLocationCoordinate2D) in
				self.wireframe.transitionToHomeModule(withLocation: location, onCompletion: self.viewInput.launchAnimation)
			})
			.disposed(by: self.disposeBag)
	}
	
	// MARK: Alerting
	
	private func alertLocationAuthorizationDenied() {
		let alertController: UIAlertController = UIAlertController(title:  "We have a problem", message: "Routefire requires your location to work correctly. Please enable location while in use in Settings.", preferredStyle: .alert)
		let openSettingsAction: UIAlertAction = UIAlertAction(title: "Settings", style: .default) { _ in
			if let settingsURL: URL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
				UIApplication.shared.open(settingsURL)
			}
		}
		alertController.addAction(openSettingsAction)
		self.present(alertController, animated: true)
	}
	
	// MARK: Transitioning
	
	override func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return LaunchAnimator()
	}
}



