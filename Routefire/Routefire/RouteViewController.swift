//
//  RouteViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/8/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

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
  
  // Constants
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
    expandTableView()
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
  
  @IBAction func routeViewTouched(_ sender: UITapGestureRecognizer) {
    expandTableView()
  }
  
  func expandTableView() {
    let height = routeView.frame.height
    if destinationsTableViewHeight.constant != height {
      destinationsTableViewHeight.constant = height
      view.layoutIfNeeded()
      view.endEditing(true)
    }
  }
  
  func keyboardWillShow(notification: Notification) {
    guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else {
      return
    }
    
    let rowHeight = (view.frame.height - routeView.frame.height - keyboardSize.height) / 3
    if destinationsTableView.rowHeight != rowHeight {
      destinationsTableView.rowHeight = rowHeight
    }
    
    view.layoutIfNeeded()
  }
  
  func keyboardDidShow(notification: Notification) {
    let height = view.frame.height - destinationsTableView.rowHeight * 3
    if destinationsTableViewHeight.constant != height {
      destinationsTableViewHeight.constant = height
      view.layoutIfNeeded()
    }
  }
}

// Destinations table view delegate and data source
extension RouteViewController: UITableViewDelegate, UITableViewDataSource {
  
  // Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    expandTableView()
    
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
    
    // Observe keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    
    // Store constraint constants
    destinationsTableViewActiveTopConstant = UIScreen.main.bounds.height - destinationsTableViewHeight.constant
    destinationsTableViewInactiveTopConstant = destinationsTableViewTop.constant
    loadingViewActiveWidthConstant = loadingViewWidth.constant * 1.8
    loadingViewInactiveWidthConstant = loadingViewWidth.constant
    
    // View setup
    view.frame = UIScreen.main.bounds
    backButton.alpha = 0
    fieldStackView.alpha = 0
    currentLocationButton.layer.cornerRadius = currentLocationButton.frame.height * 0.5
    destinationField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    destinationField.autocorrectionType = .no
    destinationsTableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: DestinationCell)
    destinationsTableView.delegate = self
    destinationsTableView.dataSource = self
    blurView.effect = nil
    CALayer.lightShadow(routeView)
    CALayer.lightShadow(loadingView)
    
    // Initial configuration
    view.bringSubview(toFront: blurView)
    routeViewWidth.constant = view.frame.width
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

