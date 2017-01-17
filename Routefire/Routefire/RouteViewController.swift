//
//  RouteViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/8/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class RouteViewController: UIViewController {
  
  // MARK: Presenter
  let presenter = RoutePresenter()
  
  // MARK: Views
  @IBOutlet weak var destinationsTableView: UITableView!
  @IBOutlet weak var routeView: UIView!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var fieldStackView: UIStackView!
  @IBOutlet weak var currentLocationButton: UIButton!
  @IBOutlet weak var destinationField: BottomBorderTextField!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var loadingView: UIView!
  
  // MARK: Constraints
  @IBOutlet weak var destinationsTableViewTop: NSLayoutConstraint!
  @IBOutlet weak var destinationsTableViewHeight: NSLayoutConstraint!
  @IBOutlet weak var loadingViewWidth: NSLayoutConstraint!
  
  // MARK: Constraint constants
  var destinationsTableViewActiveTopConstant: CGFloat!
  var destinationsTableViewInactiveTopConstant: CGFloat!
  
  var loadingViewActiveWidthConstant: CGFloat!
  var loadingViewInactiveWidthConstant: CGFloat!
  
  // MARK: Container view controller
  let containerVC = (UIApplication.shared.delegate as? AppDelegate)?.containerVC
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: User interaction
  @IBAction func backButtonTouched() {
    guard let homeVC = containerVC?.previousChild as? HomeViewController else { return }
    if homeVC.whereToButton.titleLabel?.text == "Where to?" {
      transition(to: homeVC)
    } else {
      bestRoutesTransition(to: homeVC)
    }
  }
  
  @objc func textDidChange(_ textField: UITextField) {
    guard let text = textField.text else { return }
    presenter.autocomplete(text) {
      DispatchQueue.main.async {
        self.destinationsTableView.reloadData()
      }
    }
  }
}

// MARK: Destinations table view delegate and data source
extension RouteViewController: UITableViewDelegate, UITableViewDataSource {
  
  // Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let homeVC = self.containerVC?.previousChild as? HomeViewController else { return }
    blurFadeIn()
    
    let timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        options: .curveEaseIn,
        animations: {
          self.loadingViewWidth.constant = self.loadingViewActiveWidthConstant
          self.view.layoutIfNeeded()
      }, completion: nil)
      
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.3,
        delay: 0.4,
        options: .curveEaseOut,
        animations: {
          self.loadingViewWidth.constant = self.loadingViewInactiveWidthConstant
          self.view.layoutIfNeeded()
      }, completion: nil)
    }
    
    presenter.selectedDestination(at: indexPath) { destinationName, routes in
      DispatchQueue.main.async {
        self.containerVC?.add(child: homeVC, .below)
        
        self.view.layoutIfNeeded()
        UIView.animate(
          withDuration: 0.1,
          delay: 0,
          options: .curveEaseIn,
          animations: {
            self.loadingView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
          timer.invalidate()
        }
        
        if routes.count > 0 {
          homeVC.settingsButtonBottom.constant = homeVC.settingsButtonInactiveBottomConstant
          homeVC.settingsButton.alpha = 0
          homeVC.whereToButton.isHidden = true
          homeVC.presenter.bestRoutes = routes.sorted { $0.price < $1.price }
          homeVC.bestRoutesCollectionView.reloadData()
          homeVC.bestRoutesView.alpha = 0
          homeVC.bestRoutesView.isHidden = false
          homeVC.bestRoutesAddressButton.setTitle(destinationName, for: .normal)
          
          self.view.layoutIfNeeded()
          UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: .curveEaseIn,
            animations: {
              self.blurView.effect = nil
              self.view.layoutIfNeeded()
          }) { _ in
            self.blurView.isHidden = true
            self.containerVC?.removePreviousChild()
          }
          
          self.view.layoutIfNeeded()
          UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
              self.routeView.alpha = 0
              self.view.layoutIfNeeded()
          }) { _ in
            self.destinationsTableViewTop.constant = self.destinationsTableViewInactiveTopConstant
            self.routeView.backgroundColor = UIColor.clear
          }
          
          homeVC.view.layoutIfNeeded()
          UIView.animate(
            withDuration: 0.2,
            delay: 0.2,
            options: .curveEaseOut,
            animations: {
              homeVC.bestRoutesView.alpha = 1
              homeVC.view.layoutIfNeeded()
          }, completion: nil)
        } else {
          homeVC.bestRoutesView.isHidden = true
          
          self.transition(to: homeVC)
          self.view.layoutIfNeeded()
          UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations: {
              self.blurView.effect = nil
              self.view.layoutIfNeeded()
          }) { _ in
            self.blurView.isHidden = true
          }
        }
      }
    }
  }
  
  // Data source
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.autocompleteResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = destinationsTableView.dequeueReusableCell(withIdentifier: Constants.destinationCell, for: indexPath) as? DestinationTableViewCell else {
      return UITableViewCell()
    }
    
    cell.destinationLabel.attributedText = presenter.locationName(indexPath)
    
    return cell
  }
}

// MARK: Animate transitions
private extension RouteViewController {
  
  // Transition to home view controller
  func transition(to homeVC: HomeViewController) {
    
    // Setup
    containerVC?.add(child: homeVC, .below)
    IQKeyboardManager.sharedManager().resignFirstResponder()
    routeView.backgroundColor = UIColor.clear
    
    // Route view controller
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.backButton.alpha = 0
        self.fieldStackView.alpha = 0
        self.view.layoutIfNeeded()
    }, completion: nil)
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.05,
      options: .curveEaseInOut,
      animations: {
        self.destinationsTableViewTop.constant = self.destinationsTableViewInactiveTopConstant
        self.view.layoutIfNeeded()
    }, completion: nil)
    
    // Home view controller
    homeVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.05,
      options: .curveEaseInOut,
      animations: {
        homeVC.settingsButtonBottom.constant = homeVC.settingsButtonActiveBottomConstant
        homeVC.whereToButtonTop.constant = homeVC.whereToButtonActiveTopConstant
        homeVC.whereToButtonWidth.constant = homeVC.whereToButtonActiveWidthConstant
        homeVC.whereToButtonHeight.constant = homeVC.whereToButtonActiveHeightConstant
        homeVC.settingsButton.alpha = 1
        homeVC.view.layoutIfNeeded()
    }) { _ in
      self.containerVC?.removePreviousChild()
    }
    
    homeVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.2,
      options: .curveEaseInOut,
      animations: {
        homeVC.whereToButton.titleLabel?.alpha = 1
        homeVC.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  func bestRoutesTransition(to homeVC: HomeViewController) {
    
    // Setup
    containerVC?.add(child: homeVC, .below)
    IQKeyboardManager.sharedManager().resignFirstResponder()
    routeView.backgroundColor = UIColor.clear
    
    // Route view controller
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        self.backButton.alpha = 0
        self.fieldStackView.alpha = 0
        self.view.layoutIfNeeded()
    }, completion: nil)
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.05,
      options: .curveEaseInOut,
      animations: {
        self.destinationsTableViewTop.constant = self.destinationsTableViewInactiveTopConstant
        self.view.layoutIfNeeded()
    }) { _ in
      self.containerVC?.removePreviousChild()
    }
    
    // Home view controller
    homeVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.35,
      delay: 0.05,
      options: .curveEaseInOut,
      animations: {
        homeVC.whereToButton.backgroundColor = UIColor.themeBlue
        homeVC.bestRoutesView.alpha = 1
        homeVC.view.layoutIfNeeded()
    }, completion: nil)
    
    homeVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.2,
      options: .curveEaseInOut,
      animations: {
        homeVC.whereToButton.titleLabel?.alpha = 1
        homeVC.view.layoutIfNeeded()
    }, completion: nil)
  }
  
  func blurFadeIn() {
    blurView.isHidden = false
    self.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.blurView.effect = UIBlurEffect(style: .light)
        self.loadingView.alpha = 1
        self.view.layoutIfNeeded()
    }, completion: nil)
  }
}

// MARK: - Configuration
private extension RouteViewController {
  func configure() {
    
    // View
    CALayer.lightShadow(routeView)
    CALayer.lightShadow(loadingView)

    backButton.alpha = 0
    fieldStackView.alpha = 0
    currentLocationButton.layer.cornerRadius = currentLocationButton.frame.height * 0.5
    destinationField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    destinationsTableView.delegate = self
    destinationsTableView.dataSource = self
    destinationsTableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.destinationCell)
    blurView.effect = nil
    
    // Store constraint constants
    destinationsTableViewActiveTopConstant = UIScreen.main.bounds.height - destinationsTableViewHeight.constant
    destinationsTableViewInactiveTopConstant = destinationsTableViewTop.constant
    
    loadingViewActiveWidthConstant = loadingViewWidth.constant * 1.8
    loadingViewInactiveWidthConstant = loadingViewWidth.constant
  }
}

