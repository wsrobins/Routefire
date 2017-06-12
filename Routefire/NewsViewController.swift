//
//  NewsViewController.swift
//  Routefire
//
//  Created by William Robinson on 6/7/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxCocoa
import RxSwift

class NewsViewController: UIViewController {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: View
	
	fileprivate var viewInput: NewsViewInput {
		return view as! NewsViewInput
	}
	
	fileprivate var viewOutput: NewsViewOutput {
		return view as! NewsViewOutput
	}
	
	// MARK: View model
	
	fileprivate let viewModelInput: NewsViewModelInput
	fileprivate let viewModelOutput: NewsViewModelOutput
	
	// MARK: Wireframe
	
	fileprivate unowned let wireframe: Wireframe
	
	// MARK: Initialization
	
	init(viewModel: NewsViewModel, wireframe: Wireframe) {
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
		self.view = NewsView()
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


