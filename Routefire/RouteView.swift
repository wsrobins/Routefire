//
//  RouteView.swift
//  Routefire
//
//  Created by William Robinson on 6/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxCocoa
import RxSwift

protocol RouteViewInput: class {
	
}

protocol RouteViewOutput: class {
	
}

class RouteView: UIView {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Subviews
	
	
	
	// MARK: Initialization
	
	init() {
		super.init(frame: .zero)
		self.style()
		self.addSubviews()
		self.layout()
		self.observe()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	// MARK: Styling
	
	fileprivate func style() {
		
	}
	
	// MARK: Add subviews
	
	fileprivate func addSubviews() {
		
	}
	
	// MARK: Layout
	
	fileprivate func layout() {
		
	}
	
	// MARK: Observation
	
	fileprivate func observe() {
	
	}
}

// MARK: - Route view input
extension RouteView: RouteViewInput {
	
}

// MARK: - Route view output
extension RouteView: RouteViewOutput {
	
}


