//
//  SettingsViewController.swift
//  Routefire
//
//  Created by William Robinson on 6/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxSwift

class SettingsViewController: UIViewController {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: View
	
	fileprivate var viewInput: SettingsViewInput {
		return view as! SettingsViewInput
	}
	
	fileprivate var viewOutput: SettingsViewOutput {
		return view as! SettingsViewOutput
	}
	
	// MARK: View model
	
	fileprivate let viewModelInput: SettingsViewModelInput
	fileprivate let viewModelOutput: SettingsViewModelOutput
	
	// MARK: Wireframe
	
	fileprivate unowned let wireframe: Wireframe
	
	// MARK: Initialization
	
	init(viewModel: SettingsViewModel, wireframe: Wireframe) {
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
		self.view = SettingsView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.observeView()
		self.observeViewModel()
	}
	
	// MARK: Observation
	
	fileprivate func observeView() {
		self.viewOutput.willShowRouteHistory
			.bind {
				
				self.viewInput.showRouteHistory()
			}
			.disposed(by: self.disposeBag)
	}
	
	fileprivate func observeViewModel() {
		
	}
}


