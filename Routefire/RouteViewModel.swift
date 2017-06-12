//
//  RouteViewModel.swift
//  Routefire
//
//  Created by William Robinson on 6/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxSwift

protocol RouteViewModelInput: class {
	
}

protocol RouteViewModelOutput: class {
	
}

class RouteViewModel {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Services
	
	fileprivate let servicesInput: RouteServicesInput
	fileprivate let servicesOutput: RouteServicesOutput
	
	// MARK: Observables
	
	
	
	// MARK: Initialization
	
	init(services: RouteServices) {
		self.servicesInput = services
		self.servicesOutput = services
	}
}

// MARK: - Route view model input
extension RouteViewModel: RouteViewModelInput {
	
}

// MARK: - Route view model output
extension RouteViewModel: RouteViewModelOutput {
	
}


