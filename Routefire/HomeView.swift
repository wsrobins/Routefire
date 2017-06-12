//
//  HomeView.swift
//  Routefire
//
//  Created by William Robinson on 6/2/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import BouncyLayout
import GoogleMaps
import Material
import RxCocoa
import RxKeyboard
import RxSwift
import SnapKit

protocol HomeViewInput: class {
	func centerCamera(on coordinate: CLLocationCoordinate2D, withZoom zoom: Float)
	func animate(toZoom zoom: Float)
	func bind(autocompletions: Driver<[Autocompletion]>)
	func recognizeGestures()
	func showPullUpView()
}

protocol HomeViewOutput: class {
	var openSettings: ControlEvent<Void> { get }
	var autocompleteQuery: ControlProperty<String?> { get }
	var pullRecognized: ControlEvent<UIPanGestureRecognizer> { get }
}

class HomeView: UIView {
	
	// MARK: Resource disposal
	
	fileprivate let disposeBag: DisposeBag = DisposeBag()
	
	// MARK: Subviews
	
	fileprivate lazy var mapView: GMSMapView = {
		let mapView: GMSMapView = GMSMapView()
		guard let mapStyleURL: URL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") else {
			return mapView
		}
		do {
			mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: mapStyleURL)
		} catch {
			print(error)
		}
		mapView.isMyLocationEnabled = true
		return mapView
	}()
	
	fileprivate lazy var settingsButton: IconButton = {
		let settingsButton: IconButton = IconButton(image: #imageLiteral(resourceName: "SettingsIcon"), tintColor: .black)
		return settingsButton
	}()
	
	fileprivate lazy var searchResultsCollectionView: UICollectionView = {
		let searchResultsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.bouncyLayout)
		searchResultsCollectionView.register(AutocompletionCell.self, forCellWithReuseIdentifier: AutocompletionCell.reuseID)
		searchResultsCollectionView.showsVerticalScrollIndicator = false
		searchResultsCollectionView.backgroundColor = .clear
		return searchResultsCollectionView
	}()
	
	fileprivate lazy var searchView: UIView = {
		let searchView: UIView = UIView()
		searchView.backgroundColor = .white
		searchView.depthPreset = .depth3
		return searchView
	}()
	
	fileprivate lazy var whereToButton: Button = {
		let whereToButton: Button = Button(title: "Where to?", titleColor: .black)
		whereToButton.titleLabel?.font = RobotoFont.light(with: 20)
		whereToButton.pulseAnimation = .none
		return whereToButton
	}()
	
	fileprivate lazy var searchTextField: TextField = {
		let searchTextField: TextField = TextField()
		searchTextField.placeholder = "Where to?"
		searchTextField.font = RobotoFont.light(with: 20)
		searchTextField.placeholderNormalColor = .black
		searchTextField.placeholderActiveColor = .black
		searchTextField.dividerNormalColor = .white
		searchTextField.dividerActiveColor = .black
		searchTextField.dividerNormalHeight = 2
		searchTextField.alpha = 0
		return searchTextField
	}()
	
	fileprivate lazy var closeSearchButton: IconButton = {
		let closeSearchButton: IconButton = IconButton(image: Icon.close, tintColor: .black)
		closeSearchButton.alpha = 0
		return closeSearchButton
	}()
	
	fileprivate lazy var blackFadeView: UIView = {
		let blackFadeView: UIView = UIView()
		blackFadeView.backgroundColor = .black
		blackFadeView.alpha = 0
		return blackFadeView
	}()
	
	fileprivate lazy var pullUpView: UIView = {
		let pullUpView: UIView = UIView()
		pullUpView.backgroundColor = .black
		pullUpView.cornerRadius = self.pullUpViewInactiveCornerRadius
		return pullUpView
	}()
	
	fileprivate lazy var pullUpNewsLabel: UILabel = {
		let pullUpNewsLabel: UILabel = UILabel()
		pullUpNewsLabel.text = "NEWS"
		pullUpNewsLabel.font = RobotoFont.regular(with: 12)
		pullUpNewsLabel.textColor = .gray
		return pullUpNewsLabel
	}()
	
	fileprivate lazy var pullUpTitleLabel: UILabel = {
		let pullUpTitleLabel: UILabel = UILabel()
		pullUpTitleLabel.text = "Save money on your rides and also look at my sister app Trashfire"
		pullUpTitleLabel.numberOfLines = 0
		pullUpTitleLabel.font = RobotoFont.light(with: 24)
		pullUpTitleLabel.textColor = .groupTableViewBackground
		return pullUpTitleLabel
	}()
	
	// MARK: Style properties
	
	fileprivate let pullUpViewActiveCornerRadius: CGFloat = 0
	fileprivate let pullUpViewInactiveCornerRadius: CGFloat = 4
	
	// MARK: Layout properties
	
	fileprivate enum LayoutType {
		case normal
		case simple
		case search
		case news
	}
	
	fileprivate lazy var bouncyLayout: BouncyLayout = {
		let bouncyLayout: BouncyLayout = BouncyLayout(style: .prominent)
		bouncyLayout.itemSize = CGSize(width: self.searchResultsCollectionViewWidth, height: 46)
		bouncyLayout.minimumInteritemSpacing = 0
		bouncyLayout.minimumLineSpacing = 0
		bouncyLayout.sectionInset.top = 8
		return bouncyLayout
	}()
	
	fileprivate let padding: CGFloat = 16
	fileprivate let settingsButtonActiveTopInset: CGFloat = 20
	fileprivate var settingsButtonInactiveTopInset: CGFloat { return self.padding - self.settingsButtonDimension }
	fileprivate var settingsButtonDimension: CGFloat { return #imageLiteral(resourceName: "SettingsIcon").width + self.padding * 2 }
	fileprivate let searchViewActiveHeight: CGFloat = 133
	fileprivate let searchViewInactiveHeight: CGFloat = 66
	fileprivate let searchTextFieldHeight: CGFloat = 50
	fileprivate let searchTextFieldPadding: CGFloat = 28
	fileprivate var searchResultsCollectionViewWidth: CGFloat { return Screen.width - self.padding * 2 }
	fileprivate let pullUpViewActiveTopOffset: CGFloat = -64
	fileprivate let pullUpViewInactiveTopOffset: CGFloat = 0
	fileprivate lazy var pullUpViewCurrentTopOffset: CGFloat = self.pullUpViewActiveTopOffset
	fileprivate let pullUpHorizontalPadding: CGFloat = 5
	
	// MARK: Gesture recognizers
	
	fileprivate let pullUpViewPanGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
	
	// MARK: Initialization
	
	init() {
		super.init(frame: .zero)
		self.addSubviews()
		self.layout()
		self.observe()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	// MARK: Add subviews
	
	fileprivate func addSubviews() {
		self.addSubview(self.mapView)
		self.addSubview(self.settingsButton)
		self.addSubview(self.searchResultsCollectionView)
		self.addSubview(self.searchView)
		self.searchView.addSubview(self.whereToButton)
		self.searchView.addSubview(self.searchTextField)
		self.searchView.addSubview(self.closeSearchButton)
		self.addSubview(self.blackFadeView)
		self.addSubview(self.pullUpView)
		self.pullUpView.addSubview(self.pullUpNewsLabel)
		self.pullUpView.addSubview(self.pullUpTitleLabel)
	}
	
	// MARK: Layout
	
	fileprivate func layout() {
		self.layoutMapView()
		self.layoutSettingsButton()
		self.layoutSearchResultsCollectionView()
		self.layoutSearchView()
		self.layoutWhereToButton()
		self.layoutSearchTextField()
		self.layoutCloseSearchButton()
		self.layoutBlackFadeView()
		self.layoutPullUpView(type: .simple)
		self.layoutPullUpNewsLabel()
		self.layoutPullUpTitleLabel()
	}
	
	fileprivate func layoutMapView() {
		self.mapView.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.edges.equalToSuperview()
		}
	}
	
	fileprivate func layoutSettingsButton(type: LayoutType = .normal) {
		self.settingsButton.snp.remakeConstraints { (remake: ConstraintMaker) in
			switch type {
			case .search:
				remake.top.equalToSuperview().inset(self.settingsButtonInactiveTopInset)
			default:
				remake.top.equalToSuperview().inset(self.settingsButtonActiveTopInset)
			}
			remake.left.equalToSuperview()
			remake.size.equalTo(self.settingsButtonDimension)
		}
	}
	
	fileprivate func layoutSearchResultsCollectionView(type: LayoutType = .normal) {
		self.searchResultsCollectionView.snp.remakeConstraints { (remake: ConstraintMaker) in
			switch type {
			case .search:
				remake.top.equalTo(self.searchView.snp.bottom)
			default:
				remake.top.equalTo(self.pullUpView)
			}
			remake.bottom.equalToSuperview()
			remake.centerX.equalToSuperview()
			remake.width.equalTo(self.searchResultsCollectionViewWidth)
		}
	}
	
	fileprivate func layoutSearchView(type: LayoutType = .normal) {
		self.searchView.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.equalTo(self.settingsButton.snp.bottom).offset(self.padding)
			remake.left.right.equalToSuperview().inset(self.padding)
			switch type {
			case .search:
				remake.height.equalTo(self.searchViewActiveHeight)
			default:
				remake.height.equalTo(self.searchViewInactiveHeight)
			}
		}
	}
	
	fileprivate func layoutWhereToButton(type: LayoutType = .normal) {
		self.whereToButton.snp.remakeConstraints { (remake: ConstraintMaker) in
			switch type {
			case .search:
				remake.bottom.left.equalToSuperview().inset(self.searchTextFieldPadding)
				remake.height.equalTo(self.searchTextField)
			default:
				remake.edges.equalToSuperview()
			}
		}
	}
	
	fileprivate func layoutSearchTextField() {
		self.searchTextField.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.left.bottom.right.equalToSuperview().inset(self.searchTextFieldPadding)
			remake.height.equalTo(self.searchTextFieldHeight)
		}
	}
	
	fileprivate func layoutCloseSearchButton() {
		self.closeSearchButton.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.equalToSuperview().inset(self.padding * 0.5)
			remake.right.equalToSuperview().inset(self.padding)
			remake.size.equalTo((Icon.close?.width ?? 0) + self.padding * 2)
		}
	}
	
	fileprivate func layoutBlackFadeView() {
		self.blackFadeView.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.edges.equalToSuperview()
		}
	}
	
	fileprivate func layoutPullUpView(type: LayoutType = .normal) {
		self.pullUpView.snp.remakeConstraints { (remake: ConstraintMaker) in
			switch type {
			case .simple:
				remake.top.equalTo(self.snp.bottom).offset(self.pullUpViewInactiveTopOffset)
				remake.left.right.equalToSuperview()
			case .news:
				remake.top.equalTo(self.snp.bottom).offset(self.pullUpViewCurrentTopOffset)
				remake.left.right.equalToSuperview()
			default:
				remake.top.equalTo(self.snp.bottom).offset(self.pullUpViewActiveTopOffset)
				remake.left.right.equalToSuperview().inset(self.pullUpHorizontalPadding)
			}
			remake.height.equalToSuperview()
		}
	}
	
	fileprivate func layoutPullUpNewsLabel() {
		self.pullUpNewsLabel.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.equalToSuperview().inset(self.padding)
			remake.left.right.equalToSuperview().inset(self.padding * 2)
		}
	}
	
	fileprivate func layoutPullUpTitleLabel() {
		self.pullUpTitleLabel.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.left.right.equalToSuperview().inset(self.padding * 2)
			remake.top.equalTo(self.pullUpView.snp.top).inset(-self.pullUpViewActiveTopOffset - 17)
		}
	}
	
	// MARK: Observation
	
	fileprivate func observe() {
		self.observeKeyboard()
		self.observeOpenSearch()
		self.observeCloseSearch()
		self.observeOpenSettings()
	}
	
	fileprivate func observeKeyboard() {
		RxKeyboard.instance.visibleHeight
			.drive(onNext: { (keyboardHeight: CGFloat) in
				self.bouncyLayout.sectionInset.bottom = keyboardHeight + 7
			})
			.disposed(by: self.disposeBag)
	}
	
	fileprivate func observeOpenSearch() {
		self.whereToButton.rx.tap
			.bind {
				self.animateOpenSearch()
			}
			.disposed(by: self.disposeBag)
	}
	
	fileprivate func observeCloseSearch() {
		self.closeSearchButton.rx.tap
			.bind {
				self.animateCloseSearch()
			}
			.disposed(by: self.disposeBag)
	}
	
	fileprivate func observeOpenSettings() {
		self.settingsButton.rx.tap
			.bind {
				self.hidePullUpView()
			}
			.disposed(by: self.disposeBag)
	}
	
	// MARK: Animation
	
	fileprivate func animateOpenSearch() {
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
			self.settingsButton.alpha = 0
			self.layoutSearchView(type: .search)
			self.layoutWhereToButton(type: .search)
			self.layoutIfNeeded()
		}) { _ in
			self.whereToButton.alpha = 0
			self.searchTextField.alpha = 1
			_ = self.searchTextField.becomeFirstResponder()
		}
		UIView.animate(withDuration: 0.5, delay: 0.35, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.5, options: .curveEaseOut, animations: {
			self.layoutSettingsButton(type: .search)
			self.closeSearchButton.alpha = 1
			self.layoutIfNeeded()
		})
		UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.layoutSearchResultsCollectionView(type: .search)
			self.layoutIfNeeded()
		})
	}
	
	fileprivate func animateCloseSearch() {
		self.searchTextField.text = nil
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
			self.searchTextField.endEditing(true)
		}) { _ in
			self.whereToButton.alpha = 1
		}
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
			self.layoutSearchResultsCollectionView()
			self.layoutIfNeeded()
		}) { _ in
			self.searchResultsCollectionView.contentOffset = .zero
		}
		UIView.animate(withDuration: 0.1, delay: 0.2, options: .curveEaseIn, animations: {
			self.searchTextField.alpha = 0
			self.closeSearchButton.alpha = 0
		})
		UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseOut, animations: {
			self.layoutSettingsButton()
			self.layoutSearchView()
			self.layoutWhereToButton()
			self.layoutIfNeeded()
		})
		UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseIn, animations: {
			self.settingsButton.alpha = 1
		})
	}
	
	func hidePullUpView() {
		UIView.animate(withDuration: 0.2) {
			self.layoutPullUpView(type: .simple)
			self.layoutIfNeeded()
		}
	}
}

// MARK: - Home view input
extension HomeView: HomeViewInput {
	
	func centerCamera(on coordinate: CLLocationCoordinate2D, withZoom zoom: Float) {
		self.mapView.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
	}
	
	func animate(toZoom zoom: Float) {
		CATransaction.begin()
		CATransaction.setAnimationDuration(0.4)
		CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
		self.mapView.animate(toZoom: zoom)
		CATransaction.commit()
	}
	
	func bind(autocompletions: Driver<[Autocompletion]>) {
		autocompletions
			.asObservable()
			.bind(to: self.searchResultsCollectionView.rx.items(cellIdentifier: AutocompletionCell.reuseID, cellType: AutocompletionCell.self)) { (index: Int, autocompletion: Autocompletion, cell: AutocompletionCell) in
				let cellInput: AutcompletionCellInput = cell
				let isDefault: Bool = (0...2).contains(index)
				cellInput.setUp(with: autocompletion, isDefault: isDefault)
			}
			.disposed(by: self.disposeBag)
	}
	
	func recognizeGestures() {
		self.pullUpViewPanGestureRecognizer.rx.event
			.bind { (recognizer: UIPanGestureRecognizer) in
				let didBegin: Bool = recognizer.state == .began
				let didChange: Bool = recognizer.state == .changed
				let didEnd: Bool = recognizer.state == .ended
				self.pullUpViewCurrentTopOffset = self.pullUpViewActiveTopOffset + (didChange ? recognizer.translation(in: self).y : 0)
				UIView.animate(withDuration: didChange ? 0.1 : 0.3, delay: 0, options: [didChange ? .allowUserInteraction : .allowUserInteraction, .curveEaseOut], animations: {
					self.blackFadeView.alpha = didChange ? max(-self.pullUpViewCurrentTopOffset / Screen.height, 0) : 0
					self.layoutPullUpView(type: didChange ? .news : .normal)
					self.layoutIfNeeded()
				})
				if didBegin || didEnd {
					let cornerRadiusAnimation: CABasicAnimation = CABasicAnimation(keyPath: #keyPath(UIView.cornerRadius))
					cornerRadiusAnimation.duration = 0.2
					cornerRadiusAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
					cornerRadiusAnimation.isRemovedOnCompletion = false
					cornerRadiusAnimation.fromValue = self.pullUpView.cornerRadius
					let toValue: CGFloat = didBegin ? self.pullUpViewActiveCornerRadius : self.pullUpViewInactiveCornerRadius
					cornerRadiusAnimation.toValue = toValue
					self.pullUpView.cornerRadius = toValue
					self.pullUpView.layer.add(cornerRadiusAnimation, forKey: nil)
				}
			}
			.disposed(by: self.disposeBag)
		self.pullUpView.addGestureRecognizer(self.pullUpViewPanGestureRecognizer)
	}
	
	func showPullUpView() {
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
			self.layoutPullUpView()
			self.layoutIfNeeded()
		})
	}
}

// MARK: - Home view output
extension HomeView: HomeViewOutput {
	
	var openSettings: ControlEvent<Void> {
		return self.settingsButton.rx.tap
	}
	
	var autocompleteQuery: ControlProperty<String?> {
		return self.searchTextField.rx.text
	}
	
	var pullRecognized: ControlEvent<UIPanGestureRecognizer> {
		return self.pullUpViewPanGestureRecognizer.rx.event
	}
}



