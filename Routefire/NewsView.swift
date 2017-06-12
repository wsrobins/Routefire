//
//  NewsView.swift
//  Routefire
//
//  Created by William Robinson on 6/7/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit

protocol NewsViewInput: class {
	
}

protocol NewsViewOutput: class {
	
}

class NewsView: UIView {
	
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
		self.backgroundColor = .white
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

// MARK: - News view input
extension NewsView: NewsViewInput {
	
}

// MARK: - News view output
extension NewsView: NewsViewOutput {
	
}


