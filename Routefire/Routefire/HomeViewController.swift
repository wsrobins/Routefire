//
//  HomeViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/8/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import GoogleMaps
import LyftSDK
import Alamofire
import ReachabilitySwift

class HomeViewController: UIViewController {
  
  // MARK: Presenter
  let presenter = HomePresenter()
  
  // MARK: View
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var reachabilityView: UIView!
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var whereToButton: UIButton!
  @IBOutlet weak var bestRoutesView: UIView!
  @IBOutlet weak var bestRoutesAddressView: UIView!
  @IBOutlet weak var bestRoutesAddressTopView: UIView!
  @IBOutlet weak var bestRoutesExpandButton: UIButton!
  @IBOutlet weak var bestRoutesAddressButton: UIButton!
  @IBOutlet weak var bestRoutesCollectionView: UICollectionView!
  let spacing: CGFloat = 8
  
  // MARK: Constraints
  @IBOutlet weak var reachabilityViewTop: NSLayoutConstraint!
  @IBOutlet weak var reachabilityViewHeight: NSLayoutConstraint!
  @IBOutlet weak var settingsButtonBottom: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonTop: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var bestRoutesAddressViewHeight: NSLayoutConstraint!
  @IBOutlet weak var bestRoutesAddressTopViewHeight: NSLayoutConstraint!
  
  // MARK: Constraint constants
  var reachabilityViewActiveTopConstant: CGFloat!
  var reachabilityViewInactiveTopConstant: CGFloat!
  
  var settingsButtonActiveBottomConstant: CGFloat!
  var settingsButtonInactiveBottomConstant: CGFloat!
  
  var whereToButtonActiveTopConstant: CGFloat!
  var whereToButtonInactiveTopConstant: CGFloat!
  
  var whereToButtonActiveWidthConstant: CGFloat!
  var whereToButtonInactiveWidthConstant: CGFloat!
  
  var whereToButtonActiveHeightConstant: CGFloat!
  var whereToButtonInactiveHeightConstant: CGFloat!
  
  var bestRoutesAddressViewActiveHeightConstant: CGFloat!
  var bestRoutesAddressViewInactiveHeightConstant: CGFloat!
  
  // MARK: Container view controller
  let containerVC = (UIApplication.shared.delegate as? AppDelegate)?.containerVC
  
  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: KVO
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    // Update current location pin on map
    if !presenter.didFindMyLocation {
      guard let myLocation = change?[NSKeyValueChangeKey.newKey] as? CLLocation else { return }
      mapView.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 15)
      presenter.didFindMyLocation = true
    }
  }
  
  // MARK: User interaction
  @IBAction func whereToButtonTouched() {
    let routeVC = RouteViewController()
    transition(to: routeVC)
  }
  
  @IBAction func settingsButtonTouched() {
    let settingsVC = SettingsViewController()
    transition(to: settingsVC)
  }
  
  @IBAction func expandButtonTouched() {
    view.layoutIfNeeded()
    switch bestRoutesAddressViewHeight.constant {
    case bestRoutesAddressViewInactiveHeightConstant:
      UIView.animate(
        withDuration: 0.18,
        delay: 0,
        options: .curveEaseInOut,
        animations: {
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI * 0.5))
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
          self.bestRoutesAddressViewHeight.constant = self.bestRoutesAddressViewActiveHeightConstant
          self.view.layoutIfNeeded()
      }, completion: nil)
    default:
      UIView.animate(
        withDuration: 0.18,
        delay: 0,
        options: .curveEaseInOut,
        animations: {
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: 0)
          self.bestRoutesAddressViewHeight.constant = self.bestRoutesAddressViewInactiveHeightConstant
          self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
  
  @IBAction func closeButtonTouched() {
    closeBestRoutesView()
  }
}

// MARK: - Best routes collection view delegate and data source
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  // Delegate
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let route = presenter.bestRoutes[indexPath.row]
    let pickupLat = route.start.latitude.description
    let pickupLong = route.start.longitude.description
    let dropoffLat = route.end.latitude.description
    let dropoffLong = route.end.longitude.description
    
    switch route.service {
    case .uber:
      if UIApplication.shared.canOpenURL(URL(fileURLWithPath: "uber://")) {
        let productID: String
        switch route.routeType {
        case "uberPOOL":
          productID = Uber.shared.productIDs?["uberPOOL"] ?? ""
        case "uberX":
          productID = Uber.shared.productIDs?["uberX"] ?? ""
        case "uberXL":
          productID = Uber.shared.productIDs?["uberXL"] ?? ""
        case "UberBLACK":
          productID = Uber.shared.productIDs?["UberBLACK"] ?? ""
        case "SUV":
          productID = Uber.shared.productIDs?["SUV"] ?? ""
        case "WAV":
          productID = Uber.shared.productIDs?["WAV"] ?? ""
        case "uberFAMILY":
          productID = Uber.shared.productIDs?["uberFAMILY"] ?? ""
        default:
          productID = ""
        }
        
        let urlString = "uber://?client_id=\(Secrets.uberClientID)&action=setPickup&pickup[latitude]=\(pickupLat)&pickup[longitude]=\(pickupLong)&pickup[nickname]=\(route.startNickname)&pickup[formatted_address]=\(route.startAddress)&dropoff[latitude]=\(dropoffLat)&dropoff[longitude]=\(dropoffLong)&dropoff[nickname]=\(route.endNickname)&dropoff[formatted_address]=\(route.endAddress)&product_id=\(productID)"
        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let uberURL = URL(string: encodedURLString) else { return }
        
        UIApplication.shared.open(uberURL, options: [:], completionHandler: nil)
      } else {
        print("uber not installed")
      }
    case .lyft:
      if UIApplication.shared.canOpenURL(URL(fileURLWithPath: "lyft://")) {
        let rideKind: RideKind
        switch route.routeType {
        case "Lyft Line":
          rideKind = .Line
        case "Lyft Plus":
          rideKind = .Plus
        default:
          rideKind = .Standard
        }
        
        LyftDeepLink.requestRide(using: .native, kind: rideKind, from: route.start, to: route.end, couponCode: nil)
      } else {
        print("lyft not installed")
      }
    }
  }
  
  // Data source
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return presenter.bestRoutes.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.bestRouteCell, for: indexPath) as? BestRouteCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    let route = presenter.bestRoutes[indexPath.row]
    cell.routeTypeLabel.text = route.routeType
    cell.priceLabel.text = route.price
    
    switch indexPath.row {
    case 0:
      cell.routeTypeLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightBlack)
    default:
      cell.routeTypeLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBlack)
    }
    
    return cell
  }
  
  // Flow layout delegate
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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

// MARK: - User location
private extension HomeViewController {
  @objc func enableCurrentLocation() {
    mapView.isMyLocationEnabled = true
  }
}

// MARK: - Animate transitions
private extension HomeViewController {
  
  // Route view controller
  func transition(to routeVC: RouteViewController) {
    
    // Setup
    containerVC?.add(child: routeVC, .above)
    
    // Home view controller animations
    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.25) {
      self.whereToButton.backgroundColor = UIColor.white
      self.view.layoutIfNeeded()
    }
    
    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.18) {
      self.bestRoutesView.alpha = 0
      self.view.layoutIfNeeded()
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.whereToButton.titleLabel?.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      routeVC.destinationField.becomeFirstResponder()
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.28,
      delay: 0.04,
      options: .curveEaseInOut,
      animations: {
        self.whereToButtonTop.constant = self.whereToButtonInactiveTopConstant
        self.whereToButtonWidth.constant = self.whereToButtonInactiveWidthConstant
        self.whereToButtonHeight.constant = self.whereToButtonInactiveHeightConstant
        self.view.layoutIfNeeded()
    }) { _ in
      routeVC.routeView.backgroundColor = UIColor.white
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.22,
      delay: 0.04,
      options: .curveEaseInOut,
      animations: {
        self.settingsButtonBottom.constant = self.settingsButtonInactiveBottomConstant
        self.settingsButton.alpha = 0
        self.view.layoutIfNeeded()
    }, completion: nil)
    
    // Route view controller animations
    routeVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.55,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 1,
      options: .curveEaseIn,
      animations: {
        routeVC.destinationsTableViewTop.constant = routeVC.destinationsTableViewActiveTopConstant
        routeVC.view.layoutIfNeeded()
    }) { _ in
      self.containerVC?.removePreviousChild()
    }
    
    routeVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0.15,
      options: .curveEaseInOut,
      animations: {
        routeVC.backButton.alpha = 1
        routeVC.fieldStackView.alpha = 1
        routeVC.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  // Settings view controller
  func transition(to settingsVC: SettingsViewController) {
    
    // Setup
    containerVC?.add(child: settingsVC, .above)
    
    // Settings view controller animations
    settingsVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.88,
      delay: 0,
      usingSpringWithDamping: 0.75,
      initialSpringVelocity: 1,
      options: [.allowUserInteraction, .curveEaseOut],
      animations: {
        settingsVC.panelTrailing.constant = settingsVC.panelActiveTrailingConstant
        settingsVC.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  // Close best routes view
  func closeBestRoutesView() {
    
    // Setup
    whereToButton.titleLabel?.alpha = 0
    whereToButton.alpha = 0
    whereToButton.isHidden = false
    
    // Animation
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.35,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.whereToButton.alpha = 1
        self.view.layoutIfNeeded()
    }, completion: nil)
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.3,
      delay: 0.05,
      options: .curveEaseInOut,
      animations: {
        self.settingsButtonBottom.constant = self.settingsButtonActiveBottomConstant
        self.whereToButtonTop.constant = self.whereToButtonActiveTopConstant
        self.whereToButtonWidth.constant = self.whereToButtonActiveWidthConstant
        self.whereToButtonHeight.constant = self.whereToButtonActiveHeightConstant
        self.settingsButton.alpha = 1
        self.view.layoutIfNeeded()
    }, completion: nil)
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.bestRoutesView.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.bestRoutesView.isHidden = true
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.2,
      delay: 0.15,
      options: .curveEaseInOut,
      animations: {
        self.whereToButton.titleLabel?.alpha = 1
        self.view.layoutIfNeeded()
    }, completion: nil)
  }
}

// MARK: - Configuration
private extension HomeViewController {
  func configure() {
    
    // Presenter
    NotificationCenter.default.addObserver(self, selector: #selector(enableCurrentLocation), name: Constants.locationAuthorizedNotification, object: nil)
    mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
    presenter.configureLocationManager()
    
    // View
    if let mapStyleURL = Bundle.main.url(forResource: "MapStyle", withExtension: "json") {
      mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: mapStyleURL)
    }
    
    CALayer.boldShadow(whereToButton)
    CALayer.boldShadow(bestRoutesView)
    CALayer.boldShadow(bestRoutesAddressView)
    
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = spacing
    layout.minimumLineSpacing = spacing
    bestRoutesCollectionView.collectionViewLayout = layout
    bestRoutesCollectionView.backgroundColor = UIColor.clear
    bestRoutesCollectionView.delegate = self
    bestRoutesCollectionView.dataSource = self
    bestRoutesCollectionView.register(UINib(nibName: "BestRouteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.bestRouteCell)
    bestRoutesAddressButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
    // Store constraint constants
    reachabilityViewActiveTopConstant = reachabilityViewTop.constant
    reachabilityViewInactiveTopConstant = reachabilityViewHeight.constant
    
    settingsButtonActiveBottomConstant = settingsButtonBottom.constant
    settingsButtonInactiveBottomConstant = 0
    
    whereToButtonActiveTopConstant = whereToButtonTop.constant
    whereToButtonInactiveTopConstant = 0
    
    whereToButtonActiveWidthConstant = UIScreen.main.bounds.width - 40
    whereToButtonInactiveWidthConstant = UIScreen.main.bounds.width
    
    whereToButtonActiveHeightConstant = whereToButtonHeight.constant
    whereToButtonInactiveHeightConstant = 200
    
    bestRoutesAddressViewActiveHeightConstant = UIScreen.main.bounds.height - UIScreen.main.bounds.width - 24
    bestRoutesAddressViewInactiveHeightConstant = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 1.5) - 24
    
    // Configure initial constraints
    if Reachability()!.currentReachabilityStatus == .notReachable {
      UIApplication.shared.statusBarStyle = .lightContent
      reachabilityViewTop.constant = reachabilityViewActiveTopConstant
    } else {
      UIApplication.shared.statusBarStyle = .default
      reachabilityViewTop.constant = reachabilityViewInactiveTopConstant
    }
    
    whereToButtonWidth.constant = whereToButtonActiveWidthConstant
    bestRoutesAddressViewHeight.constant = bestRoutesAddressViewInactiveHeightConstant
    bestRoutesAddressTopViewHeight.constant = bestRoutesAddressViewInactiveHeightConstant
  }
}

