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
  func zoomMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float, completion: @escaping () -> Void)
  func showNoRoutes()
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
  @IBOutlet weak var priceButton: UIButton!
  @IBOutlet weak var timeButton: UIButton!
  @IBOutlet weak var bestRoutesCollectionView: UICollectionView!
  @IBOutlet weak var noRoutesView: UIView!
  @IBOutlet weak var noRoutesLabel: UILabel!
  @IBOutlet weak var noRoutesButton: UIButton!
  @IBOutlet weak var reachabilityView: UIView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  
  // Constraints
  @IBOutlet weak var whereToButtonTop: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var whereToButtonHeight: NSLayoutConstraint!
  @IBOutlet weak var bestRoutesViewTop: NSLayoutConstraint!
  @IBOutlet weak var bestRoutesDropdownViewHeight: NSLayoutConstraint!
  @IBOutlet weak var bestRoutesAddressViewHeight: NSLayoutConstraint!
  @IBOutlet weak var priceButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var timeButtonWidth: NSLayoutConstraint!
  @IBOutlet weak var noRoutesViewWidth: NSLayoutConstraint!
  @IBOutlet weak var reachabilityViewBottom: NSLayoutConstraint!
  
  // Constants
  var whereToButtonActiveTopConstant: CGFloat!
  var whereToButtonInactiveTopConstant: CGFloat!
  var whereToButtonActiveWidthConstant: CGFloat!
  var whereToButtonInactiveWidthConstant: CGFloat!
  var whereToButtonActiveHeightConstant: CGFloat!
  var whereToButtonInactiveHeightConstant: CGFloat!
  var noRoutesViewActiveWidth: CGFloat!
  var noRoutesViewInactiveWidth: CGFloat!
  var reachabilityViewActiveBottomConstant: CGFloat!
  var reachabilityViewInactiveBottomConstant: CGFloat!
  let bestRoutesDropdownViewExpandedHeight = UIScreen.main.bounds.height - UIScreen.main.bounds.width - 24
  let bestRoutesDropdownViewCollapsedHeight = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * 1.5) - 24
  let activeBorderWidth: CGFloat = 8
  let inactiveBorderWidth: CGFloat = 6
  let activeFont = UIFont.systemFont(ofSize: 29, weight: UIFontWeightBlack)
  let inactiveFont = UIFont.systemFont(ofSize: 23, weight: UIFontWeightBlack)
  let activeButtonWidth: CGFloat = 110
  let inactiveButtonWidth: CGFloat = 80
  
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
  }
  
  // User interaction
  @IBAction func whereToButtonTouched() {
    presenter.transitionToRouteModule()
  }
  
  @IBAction func expandButtonTouched() {
    switch bestRoutesDropdownViewHeight.constant {
    case bestRoutesDropdownViewCollapsedHeight - (self.presenter.networkReachable ? 0 : 20):
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.3,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 1,
        options: .curveEaseIn,
        animations: {
          self.bestRoutesDropdownViewHeight.constant = self.bestRoutesDropdownViewExpandedHeight - (self.presenter.networkReachable ? 0 : 20)
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI * 0.5))
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
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
          self.bestRoutesDropdownViewHeight.constant = self.bestRoutesDropdownViewCollapsedHeight - (self.presenter.networkReachable ? 0 : 20)
          self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: 0)
          self.view.layoutIfNeeded()
      })
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
        self.bestRoutesDropdownViewHeight.constant = self.bestRoutesDropdownViewCollapsedHeight - (self.presenter.networkReachable ? 0 : 20)
        self.noRoutesViewWidth.constant = self.noRoutesViewInactiveWidth
        self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: 0)
        self.bestRoutesView.alpha = 0
        self.noRoutesLabel.alpha = 0
        self.noRoutesButton.alpha = 0
        self.priceButton.alpha = 0
        self.timeButton.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.bestRoutesView.isHidden = true
      self.noRoutesView.isHidden = true
      self.bestRoutesExpandButton.isEnabled = true
      self.priceButtonWidth.constant = self.activeButtonWidth
      self.priceButton.setTitleColor(UIColor.groupTableViewBackground, for: .normal)
      self.priceButton.titleLabel!.font = self.activeFont
      self.priceButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
      self.priceButton.layer.borderWidth = self.activeBorderWidth
      self.timeButtonWidth.constant = self.inactiveButtonWidth
      self.timeButton.setTitleColor(UIColor.lightGray, for: .normal)
      self.timeButton.titleLabel!.font = self.inactiveFont
      self.timeButton.layer.borderColor = UIColor.lightGray.cgColor
      self.timeButton.layer.borderWidth = self.inactiveBorderWidth
    }
  }
  
  @IBAction func closeButtonTouched() {
    whereToButton.alpha = 0
    whereToButton.titleLabel?.alpha = 0
    whereToButton.isHidden = false
    let originalTop = self.bestRoutesViewTop.constant
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.bestRoutesViewTop.constant = self.view.frame.height
        self.bestRoutesDropdownViewHeight.constant = self.bestRoutesDropdownViewCollapsedHeight - (self.presenter.networkReachable ? 0 : 20)
        self.noRoutesViewWidth.constant = self.noRoutesViewInactiveWidth
        self.bestRoutesExpandButton.transform = CGAffineTransform(rotationAngle: 0)
        self.noRoutesLabel.alpha = 0
        self.noRoutesButton.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.bestRoutesView.isHidden = true
      self.noRoutesView.isHidden = true
      self.bestRoutesViewTop.constant = originalTop
      self.priceButtonWidth.constant = self.activeButtonWidth
      self.priceButton.setTitleColor(UIColor.groupTableViewBackground, for: .normal)
      self.priceButton.titleLabel!.font = self.activeFont
      self.priceButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
      self.priceButton.layer.borderWidth = self.activeBorderWidth
      self.timeButtonWidth.constant = self.inactiveButtonWidth
      self.timeButton.setTitleColor(UIColor.lightGray, for: .normal)
      self.timeButton.titleLabel!.font = self.inactiveFont
      self.timeButton.layer.borderColor = UIColor.lightGray.cgColor
      self.timeButton.layer.borderWidth = self.inactiveBorderWidth
      self.bestRoutesView.alpha = 0
      self.priceButton.alpha = 0
      self.timeButton.alpha = 0
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
        self.whereToButton.titleLabel?.alpha = 1
        self.view.layoutIfNeeded()
    }) { _ in
      self.bestRoutesCollectionView.delegate = nil
      self.bestRoutesCollectionView.dataSource = nil
      self.presenter.trip = nil
    }
  }
  
  @IBAction func filterButtonTouched(_ sender: UIButton) {
    if sender.titleColor(for: .normal) != UIColor.groupTableViewBackground {
      let isPrice = sender == priceButton
      let priceButtonWidth = isPrice ? activeButtonWidth : inactiveButtonWidth
      let priceButtonColor = isPrice ? UIColor.groupTableViewBackground : UIColor.lightGray
      let priceButtonBorder = isPrice ? activeBorderWidth : inactiveBorderWidth
      let priceButtonFont = isPrice ? activeFont : inactiveFont
      let timeButtonWidth = isPrice ? inactiveButtonWidth : activeButtonWidth
      let timeButtonColor = isPrice ? UIColor.lightGray : UIColor.groupTableViewBackground
      let timeButtonBorder = isPrice ? inactiveBorderWidth : activeBorderWidth
      let timeButtonFont = isPrice ? inactiveFont : activeFont
      blurView.isHidden = false
      
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.07,
        delay: 0,
        options: .curveEaseIn,
        animations: {
          CALayer.noShadow(self.bestRoutesView)
          self.view.layoutIfNeeded()
      })
      
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.08,
        delay: 0.07,
        options: .curveEaseIn,
        animations: {
          self.blurView.effect = UIBlurEffect(style: .light)
          self.view.layoutIfNeeded()
      }) { _ in
        isPrice ? self.priceSort() : self.timeSort()
        self.bestRoutesCollectionView.reloadData()
      }
      
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.15,
        delay: 0,
        options: .curveEaseOut,
        animations: {
          self.priceButtonWidth.constant = priceButtonWidth
          self.priceButton.setTitleColor(priceButtonColor, for: .normal)
          self.priceButton.layer.borderColor = priceButtonColor.cgColor
          self.priceButton.layer.borderWidth = priceButtonBorder
          self.priceButton.titleLabel!.font = priceButtonFont
          self.timeButtonWidth.constant = timeButtonWidth
          self.timeButton.setTitleColor(timeButtonColor, for: .normal)
          self.timeButton.layer.borderColor = timeButtonColor.cgColor
          self.timeButton.layer.borderWidth = timeButtonBorder
          self.timeButton.titleLabel!.font = timeButtonFont
          self.view.layoutIfNeeded()
      })
      
      view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.2,
        delay: 0.1,
        options: .curveEaseOut,
        animations: {
          self.blurView.effect = nil
          CALayer.shadow(self.bestRoutesView)
          self.view.layoutIfNeeded()
      }) { _ in
        self.blurView.isHidden = true
      }
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

// Route sorting
private extension HomeViewController {
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
}

// View input
extension HomeViewController: HomeViewProtocol {
  func setInitialMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float) {
    DispatchQueue.main.async {
      self.mapView.camera = GMSCameraPosition.camera(withTarget: location, zoom: zoom)
    }
  }
  
  func zoomMapCamera(to location: CLLocationCoordinate2D, withZoom zoom: Float, completion: @escaping () -> Void) {
    DispatchQueue.main.async {
      CATransaction.begin()
      CATransaction.setAnimationDuration(0.4)
      CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut))
      CATransaction.setCompletionBlock {
        completion()
      }
      
      self.mapView.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: zoom))
      CATransaction.commit()
    }
  }
  
  func showNoRoutes() {
    noRoutesViewWidth.constant = self.noRoutesViewInactiveWidth
    noRoutesLabel.alpha = 0
    noRoutesButton.alpha = 0
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
    DispatchQueue.main.async {
      let isDropdown = self.bestRoutesDropdownViewHeight.constant > self.bestRoutesDropdownViewCollapsedHeight
      self.setNeedsStatusBarAppearanceUpdate()
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.25,
        delay: 0,
        options: [.curveEaseIn, .allowUserInteraction],
        animations: {
          self.reachabilityViewBottom.constant = networkReachable ? 0 : self.reachabilityView.frame.height
          self.bestRoutesViewTop.constant = networkReachable ? 28 : 8
          self.bestRoutesDropdownViewHeight.constant = (isDropdown ? self.bestRoutesDropdownViewExpandedHeight : self.bestRoutesDropdownViewCollapsedHeight) - (networkReachable ? 0 : 20)
          self.bestRoutesAddressViewHeight.constant = self.bestRoutesDropdownViewCollapsedHeight - (networkReachable ? 0 : 20)
          self.view.layoutIfNeeded()
      })
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
    view.frame = UIScreen.main.bounds
    
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    mapView.isIndoorEnabled = false
    mapView.isBuildingsEnabled = false
    mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: Bundle.main.url(forResource: "MapStyle", withExtension: "json")!)
    
    whereToButtonWidth.constant = view.frame.width - 50
    bestRoutesDropdownViewHeight.constant = bestRoutesDropdownViewCollapsedHeight
    bestRoutesAddressViewHeight.constant = bestRoutesDropdownViewCollapsedHeight
    bestRoutesAddressButton.titleLabel?.adjustsFontSizeToFitWidth = true
    
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    bestRoutesCollectionView.collectionViewLayout = layout
    bestRoutesCollectionView.backgroundColor = UIColor.clear
    bestRoutesCollectionView.register(UINib(nibName: "BestRouteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: BestRouteCell)
    blurView.effect = nil
    
    priceButton.layer.borderColor = UIColor.groupTableViewBackground.cgColor
    priceButton.layer.borderWidth = self.activeBorderWidth
    timeButton.layer.borderColor = UIColor.lightGray.cgColor
    timeButton.layer.borderWidth = self.inactiveBorderWidth
    noRoutesButton.layer.cornerRadius = noRoutesButton.frame.height / 2
    
    CALayer.shadow(whereToButton)
    CALayer.shadow(bestRoutesView)
    CALayer.shadow(bestRoutesDropdownView)
    CALayer.shadow(reachabilityView)
    CALayer.shadow(priceButton)
    CALayer.shadow(timeButton)
    CALayer.shadow(noRoutesView)
    CALayer.shadow(noRoutesButton)
    
    noRoutesViewActiveWidth = noRoutesView.frame.width
    noRoutesViewInactiveWidth = 0
    //    reachabilityViewActiveBottomConstant = reachabilityView.frame.height
    //    reachabilityViewInactiveTopConstant = reachabilityViewHeight.constant
    //
    //    settingsButtonActiveBottomConstant = settingsButtonBottom.constant
    //    settingsButtounInactiveBottomConstant = 0
    //
    //    whereToButtonActiveTopConstant = whereToButtonTop.constant
    //    whereToButtonInactiveTopConstant = 0
    //
    //    whereToButtonActiveWidthConstant = UIScreen.main.bounds.width - 40
    //    whereToButtonInactiveWidthConstant = UIScreen.main.bounds.width
    //
    //    whereToButtonActiveHeightConstant = whereToButtonHeight.constant
    //    whereToButtonInactiveHeightConstant = 200
  }
}



