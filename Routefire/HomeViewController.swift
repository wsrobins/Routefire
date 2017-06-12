//
//  HomeViewController.swift
//  Routefire
//
//  Created by William Robinson on 6/2/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import CoreLocation
import GoogleMaps
import RxCocoa
import RxSwift

protocol HomeViewControllerInput: class {
	func showStatusBar(withAnimation animation: UIStatusBarAnimation)
	func hideStatusBar(withAnimation animation: UIStatusBarAnimation)
	func centerCamera(on coordinate: CLLocationCoordinate2D)
	func showPullUpView()
}

protocol HomeViewControllerOutput: class {
	
}

class HomeViewController: UIViewController {
	
	// MARK: Resource disposal
	
	fileprivate lazy var disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Status bar
	
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return self.statusBarAnimation }
	override var prefersStatusBarHidden: Bool { return !self.shouldShowStatusBar }
	fileprivate var statusBarAnimation: UIStatusBarAnimation = .slide
	fileprivate var shouldShowStatusBar: Bool = false
	
	// MARK: View
	
	fileprivate var viewInput: HomeViewInput {
		return view as! HomeViewInput
	}
	
	fileprivate var viewOutput: HomeViewOutput {
		return view as! HomeViewOutput
	}
	
	// MARK: View model
	
	fileprivate let viewModelInput: HomeViewModelInput
	fileprivate let viewModelOutput: HomeViewModelOutput
	
	// MARK: Data
	
	
	
	// MARK: Wireframe
	
	fileprivate unowned let wireframe: Wireframe
	
	// MARK: Initialization
	
	init(viewModel: HomeViewModel, wireframe: Wireframe) {
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
		self.view = HomeView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.observeView()
		self.observeViewModel()
		self.viewInput.recognizeGestures()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.bindAutocomplete()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			self.showStatusBar(withAnimation: .slide)
			self.viewInput.animate(toZoom: 14)
			self.viewInput.showPullUpView()
		}
	}
	
	// MARK: Observation
	
	fileprivate func observeView() {
		self.viewOutput.openSettings
			.bind {
				self.hideStatusBar(withAnimation: .fade)
				self.wireframe.transitionToSettingsModule()
			}
			.disposed(by: self.disposeBag)
		self.viewOutput.pullRecognized
			.bind { (recognizer: UIPanGestureRecognizer) in
				switch recognizer.state {
				case .began:
					self.hideStatusBar(withAnimation: .slide)
				case .ended:
					self.showStatusBar(withAnimation: .slide)
				default:
					return
				}
			}
			.disposed(by: self.disposeBag)
	}
	
	fileprivate func observeViewModel() {
		
	}
	
	// MARK: Binding
	
	fileprivate func bindAutocomplete() {
		let autocompletions: Driver<[Autocompletion]> = self.viewModelInput.bind(autocompleteQuery: self.viewOutput.autocompleteQuery)
		self.viewInput.bind(autocompletions: autocompletions)
	}
	
	// MARK: Animation
	
	func hideStatusBar(withAnimation animation: UIStatusBarAnimation) {
		self.statusBarAnimation = animation
		self.shouldShowStatusBar = false
		UIView.animate(withDuration: 0.2) {
			self.setNeedsStatusBarAppearanceUpdate()
		}
	}
}

// MARK: - Home view controller input
extension HomeViewController: HomeViewControllerInput {
	
	func centerCamera(on coordinate: CLLocationCoordinate2D) {
		self.viewInput.centerCamera(on: coordinate, withZoom: 17)
	}
	
	func showStatusBar(withAnimation animation: UIStatusBarAnimation) {
		self.statusBarAnimation = animation
		self.shouldShowStatusBar = true
		UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
			self.setNeedsStatusBarAppearanceUpdate()
		})
	}
	
	func showPullUpView() {
		self.viewInput.showPullUpView()
	}
}

// MARK: - Home view controller output
extension HomeViewController: HomeViewControllerOutput {

}


