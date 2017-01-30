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
  func toggleReachabilityView(_ reachable: Bool)
}

class HomeViewController: UIViewController {
  
  // Presenter
  var presenter: HomePresenterProtocol!
  
  // Wireframe
  var wireframe: HomeWireframeProtocol!
  
  // Subviews
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var whereToButton: UIButton!
  @IBOutlet weak var bestRoutesView: UIView!
  @IBOutlet weak var bestRoutesDropdownView: UIView!
  @IBOutlet weak var bestRoutesAddressView: UIView!
  @IBOutlet weak var bestRoutesExpandButton: UIButton!
  @IBOutlet weak var bestRoutesAddressButton: UIButton!
  @IBOutlet weak var bestRoutesCollectionView: UICollectionView!
  @IBOutlet weak var reachabilityView: UIView!
  
  // Constraints
  @IBOutlet weak var whereToButtonTop: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var bestRoutesDropdownViewHeight: NSLayoutConstraint!
  @IBOutlet weak var bestRoutesAddressViewHeight: NSLayoutConstraint!
  @IBOutlet weak var reachabilityViewBottom: NSLayoutConstraint!
  
  // Constraint constants
  let bestRoutesDropdownViewExpandedHeight = UIScreen.main.bounds.height - UIScreen.main.bounds.width - 24
  let bestRoutesDropdownViewCollapsedHeight = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 1.5) - 24
  
  // Status bar
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return presenter.networkReachable ? .default : .lightContent
  }
  
  // Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
    presenter.observeReachability()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    presenter.setMapCamera(initial: true)
  }
  
  override func viewDidLayoutSubviews() {
    view.bringSubview(toFront: bestRoutesView)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    presenter.setMapCamera(initial: false)
  }
  
  // User interaction
  @IBAction func whereToButtonTouched() {
    presenter.transitionToRouteModule()
  }
  
  @IBAction func expandButtonTouched() {
    view.layoutIfNeeded()
    switch bestRoutesDropdownViewHeight.constant {
    case bestRoutesDropdownViewCollapsedHeight:
      UIView.animate(
        withDuration: 0.18,
        delay: 0,
        options: .curveEaseInOut,
        animations: {
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI * 0.5))
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
          self.bestRoutesDropdownViewHeight.constant = self.bestRoutesDropdownViewExpandedHeight
          self.view.layoutIfNeeded()
      }, completion: nil)
    default:
      UIView.animate(
        withDuration: 0.18,
        delay: 0,
        options: .curveEaseInOut,
        animations: {
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: 0)
          self.bestRoutesDropdownViewHeight.constant = self.bestRoutesDropdownViewCollapsedHeight
          self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
  
  @IBAction func addressButtonTouched() {
    whereToButton.alpha = 1
    whereToButton.titleLabel?.alpha = 0
    whereToButton.isHidden = false
    
    self.presenter.transitionToRouteModule()
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.bestRoutesView.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.bestRoutesView.isHidden = true
    }
  }
  
  @IBAction func closeButtonTouched() {
    whereToButton.alpha = 0
    whereToButton.titleLabel?.alpha = 0
    whereToButton.isHidden = false
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.whereToButton.alpha = 1
        self.bestRoutesView.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.bestRoutesView.isHidden = true
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0.15,
      options: [.curveEaseIn, .allowUserInteraction],
      animations: {
        self.whereToButton.titleLabel?.alpha = 1
        self.view.layoutIfNeeded()
    }, completion: nil)
  }
}

// View input
extension HomeViewController: HomeViewProtocol {
  func setInitialMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float) {
    DispatchQueue.main.async {
      self.mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: zoom)
    }
  }
  
  func zoomMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.mapView.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: zoom))
    }
  }
  
  func toggleReachabilityView(_ networkReachable: Bool) {
    DispatchQueue.main.async {
      self.setNeedsStatusBarAppearanceUpdate()
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.2,
        delay: 0,
        options: .allowUserInteraction,
        animations: {
          self.reachabilityViewBottom.constant = networkReachable ? 0 : self.reachabilityView.frame.height
          self.view.layoutIfNeeded()
      }, completion: nil)
    }
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
    return presenter.bestRoutes.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BestRouteCell, for: indexPath) as? BestRouteCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    let route = presenter.bestRoutes[indexPath.row]
    cell.nameLabel.text = route.name
    cell.timeLabel.text = route.arrival
    cell.priceLabel.text = route.lowPrice == route.highPrice ? "$\(route.lowPrice)" : "$\(route.lowPrice)-\(route.highPrice)"
    
    switch indexPath.row {
    case 0:
      cell.nameLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightBlack)
    default:
      cell.nameLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBlack)
    }
    
    return cell
  }
  
  // Flow layout delegate
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let spacing = (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
    let full = UIScreen.main.bounds.width - spacing * 2
    let half = (UIScreen.main.bounds.width - spacing * 3) / 2
    
    switch indexPath.row {
    case 0:
      return CGSize(width: full, height: half)
    default:
      return CGSize(width: half, height: half)
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
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    mapView.isIndoorEnabled = false
    mapView.isBuildingsEnabled = false
    mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: Bundle.main.url(forResource: "MapStyle", withExtension: "json")!)
    
    bestRoutesDropdownViewHeight.constant = bestRoutesDropdownViewCollapsedHeight
    bestRoutesAddressViewHeight.constant = bestRoutesDropdownViewCollapsedHeight
    
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    bestRoutesCollectionView.collectionViewLayout = layout
    bestRoutesCollectionView.backgroundColor = UIColor.clear
    bestRoutesCollectionView.delegate = self
    bestRoutesCollectionView.dataSource = self
    bestRoutesCollectionView.register(UINib(nibName: "BestRouteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: BestRouteCell)
    bestRoutesAddressButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
    whereToButtonWidth.constant = view.frame.width - 50
    
    CALayer.boldShadow(whereToButton)
    CALayer.boldShadow(bestRoutesView)
    CALayer.boldShadow(bestRoutesDropdownView)
    
    
    
    //    // Store constraint constants
    //    reachabilityViewActiveTopConstant = reachabilityViewTop.constant
    //    reachabilityViewInactiveTopConstant = reachabilityViewHeight.constant
    //
    //    settingsButtonActiveBottomConstant = settingsButtonBottom.constant
    //    settingsButtonInactiveBottomConstant = 0
    //
    //    whereToButtonActiveTopConstant = whereToButtonTop.constant
    //    whereToButtonInactiveTopConstant = 0
    //
    //    whereToButtonActiveWidthConstant = UIScreen.main.bounds.width - 40
    //    whereToButtonInactiveWidthConstant = UIScreen.main.bounds.width
    //
    //    whereToButtonActiveHeightConstant = whereToButtonHeight.constant
    //    whereToButtonInactiveHeightConstant = 200
    //
    
    // Configure initial constraints
    //    if Reachability()!.currentReachabilityStatus == .notReachable {
    //      UIApplication.shared.statusBarStyle = .lightContent
    //      reachabilityViewTop.constant = reachabilityViewActiveTopConstant
    //    } else {
    //      UIApplication.shared.statusBarStyle = .default
    //      reachabilityViewTop.constant = reachabilityViewInactiveTopConstant
    //    }
    //
    //    whereToButtonWidth.constant = whereToButtonActiveWidthConstant
    //    bestRoutesAddressViewHeight.constant = bestRoutesAddressViewInactiveHeightConstant
    //    bestRoutesAddressTopViewHeight.constant = bestRoutesAddressViewInactiveHeightConstant
  }
}



