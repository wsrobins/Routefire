//
//  LaunchView.swift
//  Routefire
//
//  Created by William Robinson on 6/2/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import Material
import RxCocoa
import RxSwift
import SnapKit
import Spring

protocol LaunchViewInput: class {
	var launchAnimation: Completable { get }
}

final class LaunchView: UIView {
	
	// MARK: Subviews
	
	fileprivate lazy var routefireLogoView: RoutefireLogoView = {
		let routefireLogoView: RoutefireLogoView = RoutefireLogoView()
		return routefireLogoView
	}()
	
	fileprivate lazy var whiteView: UIView = {
		let whiteView: UIView = UIView()
		whiteView.backgroundColor = .white
		whiteView.alpha = 0
		return whiteView
	}()
	
	// MARK: Layout properties
	
	fileprivate enum LayoutType {
		case normal
		case launch
	}
	
	// MARK: Initialization
	
	init() {
		super.init(frame: .zero)
		self.style()
		self.addSubviews()
		self.layout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	// MARK: Style
	
	fileprivate func style() {
		self.backgroundColor = .black
	}
	
	// MARK: Add subviews
	
	fileprivate func addSubviews() {
		self.addSubview(self.routefireLogoView)
		self.addSubview(self.whiteView)
	}
	
	// MARK: Layout
	
	private func layout() {
		self.layoutRoutefireLogoView()
		self.layoutWhiteView()
	}
	
	fileprivate func layoutRoutefireLogoView(type: LayoutType = .normal) {
		self.routefireLogoView.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.center.equalToSuperview()
			switch type {
			case .normal:
				remake.size.equalTo(#imageLiteral(resourceName: "RoutefireLogo").size)
			case .launch:
				remake.size.equalTo(self.snp.height)
			}
		}
	}
	
	fileprivate func layoutWhiteView() {
		self.whiteView.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.edges.equalTo(self.routefireLogoView)
		}
	}
}

// MARK: - Launch view input
extension LaunchView: LaunchViewInput {
	
	var launchAnimation: Completable {
		return Completable.create { (completable: @escaping PrimitiveSequenceType.CompletableObserver) in
			UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
				self.whiteView.alpha = 1
			})
			UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
				self.layoutRoutefireLogoView(type: .launch)
				self.layoutIfNeeded()
			}) { _ in
				completable(.completed)
			}
			return Disposables.create()
		}
	}
}
