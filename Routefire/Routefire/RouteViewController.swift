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
  
  // Presenter
  var presenter: RoutePresenterProtocol!
  
  // Wireframe
  var wireframe: RouteWireframeAnimatedTransitioning!
  
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
  @IBOutlet weak var routeViewTop: NSLayoutConstraint!
  @IBOutlet weak var routeViewWidth: NSLayoutConstraint!
  @IBOutlet weak var routeViewHeight: NSLayoutConstraint!
  @IBOutlet weak var destinationsTableViewTop: NSLayoutConstraint!
  @IBOutlet weak var destinationsTableViewHeight: NSLayoutConstraint!
  @IBOutlet weak var loadingViewWidth: NSLayoutConstraint!
  
  // MARK: Constraint constants
  var destinationsTableViewActiveTopConstant: CGFloat!
  var destinationsTableViewInactiveTopConstant: CGFloat!
  
  var loadingViewActiveWidthConstant: CGFloat!
  var loadingViewInactiveWidthConstant: CGFloat!
  
  
  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
  }
  
  // MARK: User interaction
  @IBAction func backButtonTouched() {
    presenter.transitionToHomeModule(routing: nil)
  }
  
  @objc func textDidChange(_ textField: UITextField) {
    guard let text = textField.text else {
      return
    }
    
    presenter.autocomplete(text) {
      self.destinationsTableView.reloadData()
    }
  }
}

// MARK: Destinations table view delegate and data source
extension RouteViewController: UITableViewDelegate, UITableViewDataSource {
  
  // Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    presenter.selectedDestination(at: indexPath) {
      timer.invalidate()
    }
    //    { destinationName, routes in
    //      self.view.layoutIfNeeded()
    //      UIView.animate(
    //        withDuration: 0.1,
    //        delay: 0,
    //        options: .curveEaseIn,
    //        animations: {
    //          self.loadingView.alpha = 0
    //          self.view.layoutIfNeeded()
    //      }) { _ in
    //        timer.invalidate()
    //      }
    //    }
  }
  
  // Data source
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.autocompleteResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = destinationsTableView.dequeueReusableCell(withIdentifier: DestinationCell, for: indexPath) as? DestinationTableViewCell else {
      return UITableViewCell()
    }
    
    cell.destinationLabel.attributedText = presenter.locationName(indexPath)
    
    return cell
  }
}

// MARK: Animate transitions
private extension RouteViewController {
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

// View configuration
private extension RouteViewController {
  func configureView() {
    
    // View
    CALayer.lightShadow(routeView)
    CALayer.lightShadow(loadingView)
    
    backButton.alpha = 0
    fieldStackView.alpha = 0
    currentLocationButton.layer.cornerRadius = currentLocationButton.frame.height * 0.5
    destinationField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    destinationsTableView.delegate = self
    destinationsTableView.dataSource = self
    destinationsTableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: DestinationCell)
    blurView.effect = nil
    
    // Store constraint constants
    destinationsTableViewActiveTopConstant = UIScreen.main.bounds.height - destinationsTableViewHeight.constant
    destinationsTableViewInactiveTopConstant = destinationsTableViewTop.constant
    
    loadingViewActiveWidthConstant = loadingViewWidth.constant * 1.8
    loadingViewInactiveWidthConstant = loadingViewWidth.constant
  }
}

