//
//  AppNavigationController.swift
//  Routefire
//
//  Created by William Robinson on 6/2/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import Material
import RxCocoa
import RxSwift
import SideMenu

protocol Wireframe: class {
	func transitionToHomeModule(withLocation location: CLLocationCoordinate2D, onCompletion completable: Completable)
	func transitionToSettingsModule()
	func transitionToNewsModule()
}

final class AppNavigationController: UINavigationController {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	fileprivate lazy var locationDisposeBag: DisposeBag = DisposeBag()
	fileprivate lazy var settingsModuleDisposeBag: DisposeBag = DisposeBag()
	
	// MARK: Services
	
	let locationService: LocationService = LocationService()
	
	// MARK: Initialization
	
	init() {
		super.init(nibName: nil, bundle: nil)
		self.isNavigationBarHidden = true
		let launchViewModel: LaunchViewModel = LaunchViewModel(locationService: self.locationService)
		let launchViewController: LaunchViewController = LaunchViewController(viewModel: launchViewModel, wireframe: self)
		self.delegate = launchViewController
		self.viewControllers = [launchViewController]
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
}

// MARK: - Wireframe
extension AppNavigationController: Wireframe {
	
	private func moduleInterface<T>(ofType type: T.Type) -> T? {
		return self.viewControllers
			.flatMap { (viewController: UIViewController) -> T? in
				return viewController as? T
			}
			.first
	}
	
	func transitionToHomeModule(withLocation location: CLLocationCoordinate2D, onCompletion completable: Completable) {
		let homeViewModel: HomeViewModel = HomeViewModel(locationService: self.locationService)
		let homeViewController: HomeViewController = HomeViewController(viewModel: homeViewModel, wireframe: self)
		let homeViewControllerInput: HomeViewControllerInput = homeViewController
		homeViewControllerInput.centerCamera(on: location)
		completable
			.subscribe(onCompleted: {
				self.pushViewController(homeViewController, animated: false)
				self.viewControllers = [homeViewController]
			})
			.disposed(by: self.disposeBag)
	}
	
	func transitionToSettingsModule() {
		let settingsServices: SettingsServices = SettingsServices()
		let settingsViewModel: SettingsViewModel = SettingsViewModel(services: settingsServices)
		let settingsNavigationController: SettingsNavigationController = SettingsNavigationController(viewModel: settingsViewModel, wireframe: self)
		self.observeSettingsModule(output: settingsNavigationController)
		self.present(settingsNavigationController, animated: true)
	}
	
	private func observeSettingsModule(output: SettingsNavigationControllerOutput) {
		output.viewDidDisappear
			.bind { _ in
				if let homeViewControllerInput: HomeViewControllerInput = self.moduleInterface(ofType: HomeViewControllerInput.self) {
					homeViewControllerInput.showStatusBar(withAnimation: .fade)
					homeViewControllerInput.showPullUpView()
				}
				self.settingsModuleDisposeBag = DisposeBag()
			}
			.disposed(by: self.settingsModuleDisposeBag)
	}
	
	func transitionToNewsModule() {
		let newsServices: NewsServices = NewsServices()
		let newsViewModel: NewsViewModel = NewsViewModel(services: newsServices)
		let newsViewController: NewsViewController = NewsViewController(viewModel: newsViewModel, wireframe: self)
		self.present(newsViewController, animated: true, completion: nil)
	}
}


