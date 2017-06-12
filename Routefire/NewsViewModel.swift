//
//  NewsViewModel.swift
//  Routefire
//
//  Created by William Robinson on 6/7/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxSwift

protocol NewsViewModelInput: class {
	
}

protocol NewsViewModelOutput: class {
	
}

class NewsViewModel {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Services
	
	fileprivate let servicesInput: NewsServicesInput
	fileprivate let servicesOutput: NewsServicesOutput
	
	// MARK: Initialization
	
	init(services: NewsServices) {
		self.servicesInput = services
		self.servicesOutput = services
	}
}

// MARK: - News view model input
extension NewsViewModel: NewsViewModelInput {
	
}

// MARK: - News view model output
extension NewsViewModel: NewsViewModelOutput {
	
}


