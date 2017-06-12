//
//  RouteViewController.swift
//  Routefire
//
//  Created by William Robinson on 6/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxSwift

class RouteViewController: UIViewController {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: View
	
	fileprivate var viewInput: RouteViewInput {
		return view as! RouteViewInput
	}
	
	fileprivate var viewOutput: RouteViewOutput {
		return view as! RouteViewOutput
	}
	
	// MARK: View model
	
	fileprivate let viewModelInput: RouteViewModelInput
	fileprivate let viewModelOutput: RouteViewModelOutput
	
	// MARK: Wireframe
	
	fileprivate unowned let wireframe: Wireframe
	
	// MARK: Initialization
	
	init(viewModel: RouteViewModel, wireframe: Wireframe) {
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
		self.view = RouteView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.observeView()
		self.observeViewModel()
	}
	
	// MARK: Observation
	
	fileprivate func observeView() {
		
	}
	
	fileprivate func observeViewModel() {
		
	}
}


