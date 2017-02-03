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
  func priceSort()
  func timeSort()
  func noRoutesPopup()
  func toggleReachabilityView(_ reachable: Bool)
  func getReachabilitySettings(_ networkReachable: Bool) -> (routesViewTop: CGFloat, dropdownViewHeight: CGFloat, addressViewHeight: CGFloat, reachabilityViewBottom: CGFloat)
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
  @IBOutlet weak var whereToButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var routesViewTop: NSLayoutConstraint!
  @IBOutlet weak var dropdownViewHeight: NSLayoutConstraint!
  @IBOutlet weak var addressViewHeight: NSLayoutConstraint!
  @IBOutlet weak var priceButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var timeButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var noRoutesViewWidth: NSLayoutConstraint!
  @IBOutlet weak var reachabilityViewBottom: NSLayoutConstraint!
  
  // Constants
  var whereToButtonActiveTop: CGFloat!
  var whereToButtonInactiveTop: CGFloat!
  var whereToButtonActiveWidth: CGFloat!
  var whereToButtonInactiveWidth: CGFloat!
  var whereToButtonActiveHeight: CGFloat!
  var whereToButtonInactiveHeight: CGFloat!
  var routesViewActiveTop: CGFloat!
  var routesViewInactiveTop: CGFloat!
  var dropdownViewActiveHeight: CGFloat!
  var dropdownViewInactiveHeight: CGFloat!
  var filterButtonActiveSettings: (width: CGFloat, borderWidth: CGFloat, font: UIFont, color: UIColor)!
  var filterButtonInactiveSettings: (width: CGFloat, borderWidth: CGFloat, font: UIFont, color: UIColor)!
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
    presenter.observeReachability()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    presenter.setMapCamera(initial: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    presenter.setMapCamera(initial: false)
    presenter.checkForRoutes()
  }
  
  // User interaction
  @IBAction func whereToButtonTouched() {
    presenter.transitionToRouteModule()
  }
  
  @IBAction func dropdownButtonTouched() {
    switch dropdownViewHeight.constant {
    case dropdownViewInactiveHeight - (self.presenter.networkReachable ? 0 : 20):
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 1,
        options: .curveEaseIn,
        animations: {
          self.dropdownViewHeight.constant = self.dropdownViewActiveHeight - (self.presenter.networkReachable ? 0 : 20)
          self.dropdownButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI * 0.5))
          self.dropdownButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
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
    default:
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
          self.dropdownViewHeight.constant = self.dropdownViewInactiveHeight - (self.presenter.networkReachable ? 0 : 20)
          self.dropdownButton.transform = CGAffineTransform(rotationAngle: 0)
          self.view.layoutIfNeeded()
      })
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
        self.dropdownViewHeight.constant = self.dropdownViewInactiveHeight - (self.presenter.networkReachable ? 0 : 20)
        self.dropdownButton.transform = CGAffineTransform(rotationAngle: 0)
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
        self.dropdownViewHeight.constant = self.dropdownViewInactiveHeight - (self.presenter.networkReachable ? 0 : 20)
        self.dropdownButton.transform = CGAffineTransform(rotationAngle: 0)
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
      delay: 0.15,
      options: .curveEaseIn,
      animations: {
        self.whereToButton.alpha = 1
        self.view.layoutIfNeeded()
    })
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0.25,
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
    
    let priceButtonSettings = (sender.currentTitle! == "Price" ? filterButtonActiveSettings : filterButtonInactiveSettings)!
    priceButton.layer.borderWidth = priceButtonSettings.borderWidth
    priceButton.setTitleColor(priceButtonSettings.color, for: .normal)
    priceButton.layer.borderColor = priceButtonSettings.color.cgColor
    
    let timeButtonSettings = (sender.currentTitle! == "Time" ? filterButtonActiveSettings : filterButtonInactiveSettings)!
    self.timeButton.layer.borderWidth = timeButtonSettings.borderWidth
    self.timeButton.setTitleColor(timeButtonSettings.color, for: .normal)
    self.timeButton.layer.borderColor = timeButtonSettings.color.cgColor
    
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
      self.presenter.sort(sender.currentTitle!)
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
  
  func priceSort() {
    self.presenter.trip!.routes.sort {
      if $0.lowPrice < $1.lowPrice {
        return true
      } else if $0.lowPrice == $1.lowPrice {
        if $0.highPrice < $1.highPrice {
          return true
        } else if $0.highPrice == $1.highPrice {
          if $0.arrival < $1.arrival {
            return true
          }
          return $0.name < $1.name
        }
      }
      return false
    }
  }
  
  func timeSort() {
    self.presenter.trip!.routes.sort {
      if $0.arrival < $1.arrival {
        return true
      } else if $0.arrival == $1.arrival {
        if $0.lowPrice < $1.lowPrice {
          return true
        } else if $0.lowPrice == $1.lowPrice {
          if $0.highPrice < $1.highPrice {
            return true
          }
          return $0.name < $1.name
        }
      }
      return false
    }
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
  
  func toggleReachabilityView(_ networkReachable: Bool) {
    let reachabilitySettings = getReachabilitySettings(networkReachable)
    self.setNeedsStatusBarAppearanceUpdate()
    self.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0,
      options: [.curveEaseIn, .allowUserInteraction],
      animations: {
        self.routesViewTop.constant = reachabilitySettings.routesViewTop
        self.dropdownViewHeight.constant = reachabilitySettings.dropdownViewHeight
        self.addressViewHeight.constant = reachabilitySettings.addressViewHeight
        self.reachabilityViewBottom.constant = reachabilitySettings.reachabilityViewBottom
        self.view.layoutIfNeeded()
    })
  }
  
  func getReachabilitySettings(_ networkReachable: Bool) -> (routesViewTop: CGFloat, dropdownViewHeight: CGFloat, addressViewHeight: CGFloat, reachabilityViewBottom: CGFloat) {
    let dropdownViewReachabilityHeight = (dropdownViewHeight.constant > dropdownViewInactiveHeight ? dropdownViewActiveHeight : dropdownViewInactiveHeight)!
    if networkReachable {
      return (
        routesViewTop: routesViewActiveTop,
        dropdownViewHeight: dropdownViewReachabilityHeight,
        addressViewHeight: dropdownViewInactiveHeight,
        reachabilityViewBottom: reachabilityViewInactiveBottom
      )
    }
    
    return (
      routesViewTop: routesViewInactiveTop,
      dropdownViewHeight: dropdownViewReachabilityHeight - 20,
      addressViewHeight: dropdownViewInactiveHeight - 20,
      reachabilityViewBottom: reachabilityViewActiveBottom
    )
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
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BestRouteCell, for: indexPath) as! BestRouteCollectionViewCell
    if let route = presenter.trip?.routes[indexPath.row] {
      cell.addContent(for: route, best: indexPath.row == 0)
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
    
    // Frame
    view.frame = UIScreen.main.bounds
    
    // Initialize constants
    whereToButtonActiveTop = whereToButtonTop.constant
    whereToButtonInactiveTop = 0
    whereToButtonActiveWidth = view.frame.width - 50
    whereToButtonInactiveWidth = view.frame.width
    whereToButtonActiveHeight = whereToButton.frame.height
    whereToButtonInactiveHeight = 200
    routesViewActiveTop = routesViewTop.constant
    routesViewInactiveTop = 8
    dropdownViewActiveHeight = view.frame.height - view.frame.width - 24
    dropdownViewInactiveHeight = view.frame.height - view.frame.width * 1.5 - 24
    filterButtonActiveSettings = (width: 110, borderWidth: 8, font: priceButton.titleLabel!.font, color: priceButton.currentTitleColor)
    filterButtonInactiveSettings = (width: 80, borderWidth: 6, font: timeButton.titleLabel!.font, color: timeButton.currentTitleColor)
    noRoutesViewActiveWidth = noRoutesView.frame.width
    noRoutesViewInactiveWidth = 0
    reachabilityViewActiveBottom = reachabilityView.frame.height
    reachabilityViewInactiveBottom = reachabilityViewBottom.constant
    
    // Settings
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    mapView.isIndoorEnabled = false
    mapView.isBuildingsEnabled = false
    mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: Bundle.main.url(forResource: "MapStyle", withExtension: "json")!)
    whereToButtonWidth.constant = whereToButtonActiveWidth
    dropdownViewHeight.constant = dropdownViewInactiveHeight
    addressViewHeight.constant = dropdownViewInactiveHeight
    addressButton.titleLabel!.adjustsFontSizeToFitWidth = true
    priceButton.layer.borderWidth = filterButtonActiveSettings.borderWidth
    priceButton.layer.borderColor = filterButtonActiveSettings.color.cgColor
    timeButton.layer.borderWidth = filterButtonInactiveSettings.borderWidth
    timeButton.layer.borderColor = filterButtonInactiveSettings.color.cgColor
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    routesCollectionView.collectionViewLayout = layout
    routesCollectionView.backgroundColor = UIColor.clear
    routesCollectionView.register(UINib(nibName: "BestRouteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: BestRouteCell)
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
  
  func resetView() {
    
    // Visibility
    routesView.isHidden = true
    noRoutesView.isHidden = true
    
    // Settings
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



