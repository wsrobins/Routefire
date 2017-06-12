//
//  SettingsView.swift
//  Routefire
//
//  Created by William Robinson on 6/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Material
import RxCocoa
import RxSwift
import SnapKit

protocol SettingsViewInput: class {
	func showRouteHistory()
}

protocol SettingsViewOutput: class {
	var willShowRouteHistory: ControlEvent<Void> { get }
}

class SettingsView: UIView {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Subviews
	
	fileprivate lazy var routefireLabel: UILabel = {
		let routefireLabel: UILabel = UILabel()
		routefireLabel.text = "ROUTEFIRE"
		routefireLabel.font = RobotoFont.light(with: 24)
		routefireLabel.textAlignment = .center
		return routefireLabel
	}()
	
	fileprivate lazy var historyButton: Button = {
		let historyButton: Button = Button(title: "HISTORY", titleColor: .black)
		historyButton.titleLabel?.font = RobotoFont.light
		return historyButton
	}()
	
	fileprivate lazy var helpButton: Button = {
		let helpButton: Button = Button(title: "HELP", titleColor: .black)
		helpButton.titleLabel?.font = RobotoFont.light
		return helpButton
	}()

	fileprivate lazy var settingsButton: Button = {
		let settingsButton: Button = Button(title: "SETTINGS", titleColor: .black)
		settingsButton.titleLabel?.font = RobotoFont.light
		return settingsButton
	}()
	
	// MARK: Layout properties
	
	fileprivate let padding: CGFloat = 50
	
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
		self.addSubview(self.routefireLabel)
		self.addSubview(self.historyButton)
		self.addSubview(self.helpButton)
		self.addSubview(self.settingsButton)
	}
	
	// MARK: Layout
	
	fileprivate func layout() {
		self.layoutRoutefireLabel()
		self.layoutHistoryButton()
		self.layoutHelpButton()
		self.layoutSettingsButton()
	}
	
	fileprivate func layoutRoutefireLabel() {
		self.routefireLabel.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.equalToSuperview().inset(self.padding * 2)
			remake.centerX.equalToSuperview()
			remake.width.equalToSuperview().inset(self.padding)
		}
	}
	
	fileprivate func layoutHistoryButton() {
		self.historyButton.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.equalTo(self.routefireLabel.snp.bottom).offset(self.padding * 2)
			remake.centerX.equalToSuperview()
			remake.width.equalToSuperview().inset(self.padding)
			remake.height.equalTo(self.padding)
		}
	}
	
	fileprivate func layoutHelpButton() {
		self.helpButton.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.equalTo(self.historyButton.snp.bottom).offset(self.padding)
			remake.centerX.equalToSuperview()
			remake.width.equalToSuperview().inset(self.padding)
			remake.height.equalTo(self.padding)
		}
	}
	
	fileprivate func layoutSettingsButton() {
		self.settingsButton.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.equalTo(self.helpButton.snp.bottom).offset(self.padding)
			remake.centerX.equalToSuperview()
			remake.width.equalToSuperview().inset(self.padding)
			remake.height.equalTo(self.padding)
		}
	}
	
	// MARK: Observation
	
	fileprivate func observe() {
		self.historyButton.rx.tap
			.bind {
				
			}
			.disposed(by: self.disposeBag)
	}
}

// MARK: - Settings view input
extension SettingsView: SettingsViewInput {
	
	func showRouteHistory() {
		
	}
}

// MARK: - Settings view output
extension SettingsView: SettingsViewOutput {
	
	var willShowRouteHistory: ControlEvent<Void> {
		return self.historyButton.rx.tap
	}
}


