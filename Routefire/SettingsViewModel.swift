//
//  SettingsViewModel.swift
//  Routefire
//
//  Created by William Robinson on 6/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import RxSwift

protocol SettingsViewModelInput: class {
	
}

protocol SettingsViewModelOutput: class {
	
}

class SettingsViewModel {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Services
	
	fileprivate let servicesInput: SettingsServicesInput
	fileprivate let servicesOutput: SettingsServicesOutput
	
	// MARK: Observables
	
	
	
	// MARK: Initialization
	
	init(services: SettingsServices) {
		self.servicesInput = services
		self.servicesOutput = services
	}
}

// MARK: - Settings view model input
extension SettingsViewModel: SettingsViewModelInput {
	
}

// MARK: - Settings view model output
extension SettingsViewModel: SettingsViewModelOutput {
	
}


