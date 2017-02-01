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
  
  // Subviews
  @IBOutlet weak var destinationsTableView: UITableView!
  @IBOutlet weak var routeView: UIView!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var fieldStackView: UIStackView!
  @IBOutlet weak var currentLocationButton: UIButton!
  @IBOutlet weak var destinationField: BottomBorderTextField!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var loadingView: UIView!
  
  // Constraints
  @IBOutlet weak var routeViewTop: NSLayoutConstraint!
  @IBOutlet weak var routeViewWidth: NSLayoutConstraint!
  @IBOutlet weak var routeViewHeight: NSLayoutConstraint!
  @IBOutlet weak var destinationsTableViewTop: NSLayoutConstraint!
  @IBOutlet weak var destinationsTableViewHeight: NSLayoutConstraint!
  @IBOutlet weak var loadingViewWidth: NSLayoutConstraint!
  
  // Constraint constants
  var destinationsTableViewActiveTopConstant: CGFloat!
  var destinationsTableViewInactiveTopConstant: CGFloat!
  var loadingViewActiveWidthConstant: CGFloat!
  var loadingViewInactiveWidthConstant: CGFloat!
  
  
  // Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
  }
  
  // User interaction
  @IBAction func backButtonTouched() {
    presenter.transitionToHomeModule()
  }
  
  @objc func textDidChange(_ textField: UITextField) {
    guard let text = textField.text else {
      return
    }
    
    presenter.autocomplete(text) {
      DispatchQueue.main.async {
        self.destinationsTableView.reloadData()
      }
    }
  }
}

// Destinations table view delegate and data source
extension RouteViewController: UITableViewDelegate, UITableViewDataSource {
  
  // Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        options: .curveEaseIn,
        animations: {
          self.loadingViewWidth.constant = self.loadingViewActiveWidthConstant
          self.view.layoutIfNeeded()
      })
      
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.3,
        delay: 0.4,
        options: .curveEaseOut,
        animations: {
          self.loadingViewWidth.constant = self.loadingViewInactiveWidthConstant
          self.view.layoutIfNeeded()
      })
    }
    
    blurView.isHidden = false
    loadingView.isHidden = false
    self.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveEaseInOut,
      animations: {
        self.blurView.effect = UIBlurEffect(style: .light)
        self.loadingView.alpha = 1
        self.view.layoutIfNeeded()
    })
    
    presenter.selectedDestination(at: indexPath, timer: timer)
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

// View configuration
private extension RouteViewController {
  func configureView() {
    
    // View setup
    view.bringSubview(toFront: blurView)
    backButton.alpha = 0
    fieldStackView.alpha = 0
    currentLocationButton.layer.cornerRadius = currentLocationButton.frame.height * 0.5
    destinationField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    destinationField.autocorrectionType = .no
    destinationsTableView.delegate = self
    destinationsTableView.dataSource = self
    destinationsTableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: DestinationCell)
    blurView.effect = nil
    CALayer.lightShadow(routeView)
    CALayer.lightShadow(loadingView)
    
    // Store constraint constants
    destinationsTableViewActiveTopConstant = UIScreen.main.bounds.height - destinationsTableViewHeight.constant
    destinationsTableViewInactiveTopConstant = destinationsTableViewTop.constant
    loadingViewActiveWidthConstant = loadingViewWidth.constant * 1.8
    loadingViewInactiveWidthConstant = loadingViewWidth.constant
    
    if let name = presenter.trip?.name {
      self.destinationField.text = name
      self.presenter.autocomplete(destinationField.text!) {
        DispatchQueue.main.async {
          self.destinationsTableView.reloadData()
        }
      }
    }
  }
}

