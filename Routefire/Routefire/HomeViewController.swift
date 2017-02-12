//
//  HomeView.swift
//  Routefire
//
//  Created by William Robinson on 1/8/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import ReachabilitySwift

protocol HomeViewProtocol: class {
  func setInitialMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float)
  func zoomMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float)
  func routesLayout(_ trip: Trip)
  func noRoutesPopup()
  func toggleReachabilityView()
}

class HomeViewController: UIViewController {
  
  // Presenter
  var presenter: HomePresenterProtocol!
  
  // Wireframe
  var wireframe: HomeWireframeProtocol!
  
  // Subviews
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var whereToButton: UIButton!
  @IBOutlet weak var routesView: UIView!
  @IBOutlet weak var dropdownView: UIView!
  @IBOutlet weak var addressView: UIView!
  @IBOutlet weak var dropdownButton: UIButton!
  @IBOutlet weak var addressButton: UIButton!
  @IBOutlet weak var addressGradientView: UIView!
  @IBOutlet weak var priceButton: UIButton!
  @IBOutlet weak var timeButton: UIButton!
  @IBOutlet weak var routesCollectionView: UICollectionView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var noRoutesView: UIView!
  @IBOutlet weak var noRoutesLabel: UILabel!
  @IBOutlet weak var noRoutesButton: UIButton!
  @IBOutlet weak var reachabilityView: UIView!
  
  // Constraints
  @IBOutlet weak var whereToButtonTop: NSLayoutConstraint!
  @IBOutlet var whereToButtonCondensedWidth: NSLayoutConstraint!
  @IBOutlet var whereToButtonExpandedWidth: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var routesViewTop: NSLayoutConstraint!
  @IBOutlet var addressViewDynamicHeight: NSLayoutConstraint!
  var addressViewStaticHeight: NSLayoutConstraint!
  @IBOutlet weak var priceButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var timeButtonWidth: NSLayoutConstraint!
  @IBOutlet var routesCollectionViewExpandedHeights: [NSLayoutConstraint]!
  var routesCollectionViewExpandedHeight: NSLayoutConstraint!
  @IBOutlet var routesCollectionViewCondensedHeights: [NSLayoutConstraint]!
  var routesCollectionViewCondensedHeight: NSLayoutConstraint!
  @IBOutlet weak var noRoutesViewWidth: NSLayoutConstraint!
  @IBOutlet weak var reachabilityViewBottom: NSLayoutConstraint!
  
  // Constants
  var whereToButtonActiveTop: CGFloat!
  var whereToButtonInactiveTop: CGFloat!
  var whereToButtonActiveHeight: CGFloat!
  var whereToButtonInactiveHeight: CGFloat!
  var routesViewActiveTop: CGFloat!
  var routesViewInactiveTop: CGFloat!
  var addressViewReachableStaticHeight: CGFloat!
  var addressViewUnreachableStaticHeight: CGFloat!
  var addressGradient: CAGradientLayer!
  var filterButtonActiveSettings: (width: CGFloat, borderWidth: CGFloat, font: UIFont, color: UIColor)!
  var filterButtonInactiveSettings: (width: CGFloat, borderWidth: CGFloat, font: UIFont, color: UIColor)!
  var bestRouteCollectionViewCellWidth: CGFloat!
  var routeCollectionViewCellWidth: CGFloat!
  let routeCollectionViewSpacing: CGFloat = 8
  var noRoutesViewActiveWidth: CGFloat!
  var noRoutesViewInactiveWidth: CGFloat!
  var reachabilityViewActiveBottom: CGFloat!
  var reachabilityViewInactiveBottom: CGFloat!
  
  // Status bar
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return presenter.networkReachable ? .default : .lightContent
  }
  
  // Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    presenter.setMapCamera(initial: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    reachabilitySetup()
    presenter.setMapCamera(initial: false)
    presenter.checkForRoutes()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    makeGradient()
  }
  
  // User interaction
  @IBAction func whereToButtonTouched() {
    presenter.transitionToRouteModule()
  }
  
  @IBAction func dropdownButtonTouched() {
    if routesCollectionViewExpandedHeight.isActive {
      addressViewStaticHeight.isActive = true
      addressViewDynamicHeight.isActive = false
      
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 1,
        options: .curveEaseIn,
        animations: {
          self.dropdownButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI * 0.5))
          self.dropdownButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
          self.routesCollectionViewExpandedHeight.isActive = false
          self.routesCollectionViewCondensedHeight.isActive = true
          self.view.layoutIfNeeded()
      })
      
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.3,
        delay: 0.1,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 1,
        options: .curveEaseIn,
        animations: {
          self.priceButton.alpha = 1
          self.timeButton.alpha = 1
          self.view.layoutIfNeeded()
      })
    } else {
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.2,
        delay: 0,
        options: .curveEaseIn,
        animations: {
          self.priceButton.alpha = 0
          self.timeButton.alpha = 0
          self.view.layoutIfNeeded()
      })
      
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.28,
        delay: 0.17,
        usingSpringWithDamping: 0.9,
        initialSpringVelocity: 1,
        options: .curveEaseIn,
        animations: {
          self.dropdownButton.transform = CGAffineTransform(rotationAngle: 0)
          self.routesCollectionViewCondensedHeight.isActive = false
          self.routesCollectionViewExpandedHeight.isActive = true
          self.view.layoutIfNeeded()
      }) { _ in
        self.addressViewDynamicHeight.isActive = true
        self.addressViewStaticHeight.isActive = false
      }
    }
  }
  
  @IBAction func addressButtonTouched() {
    whereToButton.alpha = 0
    whereToButton.isHidden = false
    self.presenter.transitionToRouteModule()
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.whereToButton.alpha = 1
        self.routesView.alpha = 0
        self.dropdownButton.transform = CGAffineTransform(rotationAngle: 0)
        self.routesCollectionViewCondensedHeight.isActive = false
        self.routesCollectionViewExpandedHeight.isActive = true
        self.noRoutesViewWidth.constant = self.noRoutesViewInactiveWidth
        self.noRoutesLabel.alpha = 0
        self.noRoutesButton.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.resetView()
    }
  }
  
  @IBAction func closeButtonTouched() {
    whereToButton.alpha = 0
    whereToButton.isHidden = false
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.routesViewTop.constant = self.view.frame.height
        self.dropdownButton.transform = CGAffineTransform(rotationAngle: 0)
        self.routesCollectionViewCondensedHeight.isActive = false
        self.routesCollectionViewExpandedHeight.isActive = true
        self.noRoutesViewWidth.constant = self.noRoutesViewInactiveWidth
        self.noRoutesLabel.alpha = 0
        self.noRoutesButton.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.routesView.alpha = 0
      self.presenter.trip = nil
      self.resetView()
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0.2,
      options: .curveEaseIn,
      animations: {
        self.whereToButton.alpha = 1
        self.view.layoutIfNeeded()
    })
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0.3,
      options: .curveEaseIn,
      animations: {
        self.whereToButton.titleLabel!.alpha = 1
        self.view.layoutIfNeeded()
    })
  }
  
  @IBAction func filterButtonTouched(_ sender: UIButton) {
    guard sender.frame.width == filterButtonInactiveSettings.width else {
      return
    }
    
    let priceButtonSettings = (sender == priceButton ? filterButtonActiveSettings : filterButtonInactiveSettings)!
    priceButton.layer.borderWidth = priceButtonSettings.borderWidth
    priceButton.setTitleColor(priceButtonSettings.color, for: .normal)
    priceButton.layer.borderColor = priceButtonSettings.color.cgColor
    
    let timeButtonSettings = (sender == timeButton ? filterButtonActiveSettings : filterButtonInactiveSettings)!
    timeButton.layer.borderWidth = timeButtonSettings.borderWidth
    timeButton.setTitleColor(timeButtonSettings.color, for: .normal)
    timeButton.layer.borderColor = timeButtonSettings.color.cgColor
    
    blurView.isHidden = false
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.12,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        self.priceButtonWidth.constant = priceButtonSettings.width
        self.priceButton.titleLabel!.font = priceButtonSettings.font
        self.timeButtonWidth.constant = timeButtonSettings.width
        self.timeButton.titleLabel!.font = timeButtonSettings.font
        self.view.layoutIfNeeded()
    })
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.12,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.blurView.effect = UIBlurEffect(style: .light)
        self.view.layoutIfNeeded()
    }) { _ in
      self.presenter.sortRoutes(sender.currentTitle!)
      self.routesCollectionView.reloadData()
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.12,
      delay: 0.1,
      options: .curveEaseOut,
      animations: {
        self.blurView.effect = nil
        self.view.layoutIfNeeded()
    }) { _ in
      self.blurView.isHidden = true
    }
  }
  
  @IBAction func noRoutesButtonTouched() {
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.12,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.noRoutesLabel.alpha = 0
        self.noRoutesButton.alpha = 0
        self.view.layoutIfNeeded()
    })
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.06,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        self.noRoutesViewWidth.constant += 20
        self.view.layoutIfNeeded()
    })
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.12,
      delay: 0.08,
      options: .curveEaseIn,
      animations: {
        self.noRoutesViewWidth.constant = self.noRoutesViewInactiveWidth
        self.view.layoutIfNeeded()
    }) { _ in
      self.noRoutesView.isHidden = true
    }
  }
}

// View input
extension HomeViewController: HomeViewProtocol {
  func setInitialMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float) {
    self.mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: zoom)
  }
  
  func zoomMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float) {
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.4)
    CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
    mapView.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: zoom))
    CATransaction.commit()
  }
  
  func routesLayout(_ trip: Trip) {
    whereToButton.isHidden = true
    routesView.isHidden = false
    addressButton.setTitle(trip.name, for: .normal)
    
    if !trip.routes.isEmpty {
      routesCollectionView.setContentOffset(CGPoint.zero, animated: false)
      routesCollectionView.reloadData()
      routesCollectionView.isHidden = false
    } else {
      dropdownButton.isEnabled = false
      routesCollectionView.isHidden = true
    }
  }
  
  func noRoutesPopup() {
    noRoutesView.isHidden = false
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.85,
      initialSpringVelocity: 4,
      options: .curveEaseIn,
      animations: {
        self.noRoutesViewWidth.constant = self.noRoutesViewActiveWidth
        self.view.layoutIfNeeded()
    })
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0.3,
      options: .curveEaseIn,
      animations: {
        self.noRoutesLabel.alpha = 1
        self.noRoutesButton.alpha = 1
        self.view.layoutIfNeeded()
    })
  }
  
  func toggleReachabilityView() {
    self.setNeedsStatusBarAppearanceUpdate()
    
    self.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0,
      options: [.curveEaseIn, .allowUserInteraction],
      animations: {
        self.routesViewTop.constant = self.presenter.networkReachable ? self.routesViewActiveTop : self.routesViewInactiveTop
        self.addressViewStaticHeight.constant = self.presenter.networkReachable ? self.addressViewReachableStaticHeight : self.addressViewUnreachableStaticHeight
        self.reachabilityViewBottom.constant = self.presenter.networkReachable ? self.reachabilityViewInactiveBottom : self.reachabilityViewActiveBottom
        self.view.layoutIfNeeded()
    })
  }
}

// Best routes collection view delegate and data source
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  // Delegate
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    presenter.selectedRoute(at: indexPath)
  }
  
  // Data source
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return presenter.trip?.routes.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: routeCell, for: indexPath) as! RouteCollectionViewCell
    if let route = presenter.trip?.routes[indexPath.row] {
      cell.addContent(for: route, best: indexPath.row == 0)
    }
    
    return cell
  }
  
  // Flow layout delegate
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch indexPath.row {
    case 0:
      return CGSize(width: bestRouteCollectionViewCellWidth, height: routeCollectionViewCellWidth)
    default:
      return CGSize(width: routeCollectionViewCellWidth, height: routeCollectionViewCellWidth)
    }
  }
}

// Transitioning delegate
extension HomeViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return wireframe
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return (dismissed as! RouteViewController).wireframe
  }
}

// View configuration
private extension HomeViewController {
  func configureView() {
    
    // Frame
    view.frame = UIScreen.main.bounds
    
    // Size class adjustments
    switch UIScreen.main.traitCollection.horizontalSizeClass {
    case .compact:
      whereToButtonInactiveHeight = 200
      routesCollectionViewExpandedHeight = routesCollectionViewExpandedHeights.first!
      routesCollectionViewCondensedHeight = routesCollectionViewCondensedHeights.first!
      routeCollectionViewCellWidth = (view.frame.width - routeCollectionViewSpacing * 3) / 2
    case .regular:
      whereToButtonInactiveHeight = 300
      routesCollectionViewExpandedHeight = routesCollectionViewExpandedHeights.last!
      routesCollectionViewCondensedHeight = routesCollectionViewCondensedHeights.last!
      routeCollectionViewCellWidth = (view.frame.width - routeCollectionViewSpacing * 4 - 1) / 3
    case .unspecified:
      break
    }
    
    // Initialize constants
    whereToButtonActiveTop = whereToButtonTop.constant
    whereToButtonInactiveTop = 0
    whereToButtonActiveHeight = whereToButton.frame.height
    routesViewActiveTop = routesViewTop.constant
    routesViewInactiveTop = 8
    filterButtonActiveSettings = (width: 110, borderWidth: 8, font: priceButton.titleLabel!.font, color: priceButton.currentTitleColor)
    filterButtonInactiveSettings = (width: 80, borderWidth: 6, font: timeButton.titleLabel!.font, color: timeButton.currentTitleColor)
    bestRouteCollectionViewCellWidth = view.frame.width - routeCollectionViewSpacing * 2
    noRoutesViewActiveWidth = noRoutesView.frame.width
    noRoutesViewInactiveWidth = 0
    reachabilityViewActiveBottom = reachabilityView.frame.height
    reachabilityViewInactiveBottom = reachabilityViewBottom.constant
    
    // Setup
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    mapView.isIndoorEnabled = false
    mapView.isBuildingsEnabled = false
    mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: Bundle.main.url(forResource: "MapStyle", withExtension: "json")!)
    addressButton.titleLabel!.lineBreakMode = .byClipping
    priceButton.layer.borderWidth = filterButtonActiveSettings.borderWidth
    priceButton.layer.borderColor = filterButtonActiveSettings.color.cgColor
    timeButton.layer.borderWidth = filterButtonInactiveSettings.borderWidth
    timeButton.layer.borderColor = filterButtonInactiveSettings.color.cgColor
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = routeCollectionViewSpacing
    layout.minimumLineSpacing = routeCollectionViewSpacing
    routesCollectionView.collectionViewLayout = layout
    routesCollectionView.backgroundColor = UIColor.clear
    routesCollectionView.register(UINib(nibName: "RouteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: routeCell)
    routesCollectionView.delegate = self
    routesCollectionView.dataSource = self
    blurView.effect = nil
    noRoutesButton.layer.cornerRadius = noRoutesButton.frame.height / 2
    
    // Shadowing
    CALayer.shadow(whereToButton)
    CALayer.shadow(routesView)
    CALayer.shadow(dropdownView)
    CALayer.shadow(priceButton)
    CALayer.shadow(timeButton)
    CALayer.shadow(noRoutesView)
    CALayer.shadow(noRoutesButton)
  }
  
  func makeGradient() {
    if addressGradient == nil {
      addressGradient = CAGradientLayer()
      addressGradient.frame = addressGradientView.bounds
      addressGradient.startPoint = CGPoint(x: 0, y: 0.5)
      addressGradient.endPoint = CGPoint(x: 1, y: 0.5)
      addressGradient.locations = [0.3, 1]
      addressGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
      addressGradientView.layer.mask = addressGradient
    }
  }
  
  func reachabilitySetup() {
    
    // Execute during first subview layout only
    if addressViewStaticHeight == nil {
      addressViewStaticHeight = addressView.heightAnchor.constraint(equalToConstant: addressView.frame.height)
      addressViewReachableStaticHeight = addressViewStaticHeight.constant
      addressViewUnreachableStaticHeight = addressViewStaticHeight.constant - (reachabilityView.frame.height + routesViewInactiveTop - routesViewActiveTop)
      presenter.observeReachability()
    }
  }
  
  func resetView() {
    
    // Visibility
    routesView.isHidden = true
    noRoutesView.isHidden = true
    
    // Setup
    routesViewTop.constant = routesViewActiveTop
    dropdownButton.isEnabled = true
    priceButtonWidth.constant = filterButtonActiveSettings.width
    priceButton.layer.borderWidth = filterButtonActiveSettings.borderWidth
    priceButton.titleLabel!.font = filterButtonActiveSettings.font
    priceButton.setTitleColor(filterButtonActiveSettings.color, for: .normal)
    priceButton.layer.borderColor = filterButtonActiveSettings.color.cgColor
    priceButton.alpha = 0
    timeButtonWidth.constant = filterButtonInactiveSettings.width
    timeButton.layer.borderWidth = filterButtonInactiveSettings.borderWidth
    timeButton.titleLabel!.font = filterButtonInactiveSettings.font
    timeButton.setTitleColor(filterButtonInactiveSettings.color, for: .normal)
    timeButton.layer.borderColor = filterButtonInactiveSettings.color.cgColor
    timeButton.alpha = 0
  }
}



