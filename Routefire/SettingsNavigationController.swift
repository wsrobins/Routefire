//
//  SettingsNavigationController.swift
//  Routefire
//
//  Created by William Robinson on 6/7/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Material
import RxSwift
import SideMenu

protocol SettingsNavigationControllerOutput: class {
	var viewDidDisappear: Observable<[Any]> { get }
}

class SettingsNavigationController: UISideMenuNavigationController {
	
	// MARK: Initialization
	
	init(viewModel: SettingsViewModel, wireframe: Wireframe) {
		super.init(rootViewController: SettingsViewController(viewModel: viewModel, wireframe: wireframe))
		self.style()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	// MARK: Styling
	
	fileprivate func style() {
		self.isNavigationBarHidden = true
		self.leftSide = true
		SideMenuManager.menuLeftNavigationController = self
		SideMenuManager.menuPresentMode = .menuSlideIn
		SideMenuManager.menuAnimationOptions = .curveEaseOut
		SideMenuManager.menuFadeStatusBar = false
		SideMenuManager.menuAnimationFadeStrength = 0.2
		SideMenuManager.menuShadowOpacity = 0
		SideMenuManager.menuAnimationTransformScaleFactor = 0.92
	}
}

// MARK: - Settings view controller output
extension SettingsNavigationController: SettingsNavigationControllerOutput {
	
	var viewDidDisappear: Observable<[Any]> {
		return self.rx.sentMessage(#selector(self.viewDidDisappear(_:)))
	}
}
