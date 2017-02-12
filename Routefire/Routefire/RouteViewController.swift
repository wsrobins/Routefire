//
//  RouteViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/8/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

protocol RouteViewProtocol: class {
  func setName(_ name: String)
  func getTextInput() -> String
  func refresh()
  func loading() -> Timer
  func doneLoading(_ success: Bool)
  func networkUnreachableAlert()
}

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
  @IBOutlet weak var routeViewHeight: NSLayoutConstraint!
  @IBOutlet var destinationsTableViewVisibleTop: NSLayoutConstraint!
  @IBOutlet var destinationsTableViewHiddenTop: NSLayoutConstraint!
  @IBOutlet weak var destinationsTableViewHeight: NSLayoutConstraint!
  @IBOutlet weak var loadingViewWidth: NSLayoutConstraint!
  
  // Constants
  var loadingViewActiveWidth: CGFloat!
  var loadingViewInactiveWidth: CGFloat!
  
  // Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
    presenter.observeReachability()
  }
  
  // Overrides
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    if currentLocationButton.layer.cornerRadius != currentLocationButton.frame.height * 0.5 {
      currentLocationButton.layer.cornerRadius = currentLocationButton.frame.height * 0.5
    }
  }
  
  // User interaction
  @objc func textDidChange(_ textField: UITextField) {
    presenter.autocomplete()
  }
  
  @IBAction func backButtonTouched() {
    view.endEditing(true)
    presenter.transitionToHomeModule()
  }
  
  @IBAction func routeViewTouched(_ sender: UITapGestureRecognizer) {
    view.endEditing(true)
  }
  
  func keyboardChanged(notification: Notification) {
    switch notification.name {
    case Notification.Name.UIKeyboardWillShow:
      let keyboardHeight = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height
      let rowHeight = (view.frame.height - routeView.frame.height - keyboardHeight) / 3
      if destinationsTableView.rowHeight != rowHeight {
        destinationsTableView.rowHeight = rowHeight
      }
    case Notification.Name.UIKeyboardDidShow:
      let height = view.frame.height - destinationsTableView.rowHeight * 3
      if destinationsTableViewHeight.constant != height {
        destinationsTableViewHeight.constant = height
      }
    case Notification.Name.UIKeyboardWillHide:
      if destinationsTableViewHeight.constant != routeView.frame.height {
        destinationsTableViewHeight.constant = routeView.frame.height
      }
    default:
      break
    }
    view.layoutIfNeeded()
  }
}

// View input
extension RouteViewController: RouteViewProtocol {
  func setName(_ name: String) {
    destinationField.text = name
    view.layoutIfNeeded()
  }
  
  func getTextInput() -> String {
    return destinationField.text ?? ""
  }
  
  func refresh() {
    destinationsTableView.reloadData()
  }
  
  func loading() -> Timer {
    let timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.4,
        delay: 0,
        options: .curveEaseIn,
        animations: {
          self.loadingViewWidth.constant = self.loadingViewActiveWidth
          self.view.layoutIfNeeded()
      })
      
      self.view.layoutIfNeeded()
      UIView.animate(
        withDuration: 0.3,
        delay: 0.4,
        options: .curveEaseOut,
        animations: {
          self.loadingViewWidth.constant = self.loadingViewInactiveWidth
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
    
    return timer
  }
  
  func doneLoading(_ success: Bool) {
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        self.loadingView.alpha = 0
        self.view.layoutIfNeeded()
    }) { _ in
      self.loadingView.isHidden = true
    }
    
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.35,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        self.blurView.effect = nil
        self.view.layoutIfNeeded()
    }) { _ in
      self.blurView.isHidden = true
      guard success else {
        self.networkUnreachableAlert()
        return
      }
    }
  }
  
  func networkUnreachableAlert() {
    let alert = UIAlertController(title: "We can't reach our network right now", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
    alert.view.layoutIfNeeded()
    present(alert, animated: true)
  }
}

// Destinations table view delegate and data source
extension RouteViewController: UITableViewDelegate, UITableViewDataSource {
  
  // Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    view.endEditing(true)
    presenter.selectedDestination(at: indexPath)
  }
  
  // Data source
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter.autocompleteResults.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = destinationsTableView.dequeueReusableCell(withIdentifier: destinationCell, for: indexPath) as? DestinationTableViewCell else {
      return UITableViewCell()
    }
    
    cell.destinationLabel.attributedText = presenter.locationName(for: indexPath, withFontSize: cell.destinationLabel.font.pointSize)
    
    return cell
  }
}

// View configuration
private extension RouteViewController {
  func configureView() {
    
    // Frame
    view.frame = UIScreen.main.bounds
    
    // Initialize constants
    loadingViewActiveWidth = loadingViewWidth.constant * 1.8
    loadingViewInactiveWidth = loadingViewWidth.constant
    
    // Setup
    view.bringSubview(toFront: blurView)
    backButton.alpha = 0
    fieldStackView.alpha = 0
    destinationField.autocorrectionType = .no
    destinationField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    destinationsTableView.rowHeight = view.frame.height - routeView.frame.height
    destinationsTableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: destinationCell)
    destinationsTableView.delegate = self
    destinationsTableView.dataSource = self
    blurView.effect = nil
    
    // Shadowing
    CALayer.lightShadow(routeView)
    CALayer.lightShadow(loadingView)
    
    // Observe keyboard
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: .UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged), name: .UIKeyboardWillHide, object: nil)
  }
}

