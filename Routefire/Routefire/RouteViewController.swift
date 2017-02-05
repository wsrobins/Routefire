//
//  RouteViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/8/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

protocol RouteViewProtocol: class {
  func setTrip(_ name: String)
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
  @IBOutlet weak var destinationsTableViewTop: NSLayoutConstraint!
  @IBOutlet weak var destinationsTableViewHeight: NSLayoutConstraint!
  @IBOutlet weak var loadingViewWidth: NSLayoutConstraint!
  
  // Constants
  var destinationsTableViewActiveTop: CGFloat!
  var destinationsTableViewInactiveTop: CGFloat!
  var loadingViewActiveWidth: CGFloat!
  var loadingViewInactiveWidth: CGFloat!
  
  // Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
  }
  
  // User interaction
  @objc func textDidChange(_ textField: UITextField) {
    guard let text = textField.text else {
      return
    }
    
    presenter.autocomplete(text) {
      self.destinationsTableView.reloadData()
    }
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
        destinationsTableView.reloadData()
      }
    case Notification.Name.UIKeyboardDidShow:
      let height = view.frame.height - destinationsTableView.rowHeight * 3
      if destinationsTableViewHeight.constant != height {
        destinationsTableViewHeight.constant = height
      }
    default:
      if destinationsTableViewHeight.constant != routeView.frame.height {
        destinationsTableViewHeight.constant = routeView.frame.height
      }
    }
    view.layoutIfNeeded()
  }
}

// View input
extension RouteViewController: RouteViewProtocol {
  func setTrip(_ name: String) {
    destinationField.text = name
    destinationsTableView.reloadData()
  }
}

// Destinations table view delegate and data source
extension RouteViewController: UITableViewDelegate, UITableViewDataSource {
  
  // Delegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    view.endEditing(true)
    
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
    
    // Frame
    view.frame = UIScreen.main.bounds
    
    // Initialize constants
    destinationsTableViewActiveTop = view.frame.height - routeView.frame.height
    destinationsTableViewInactiveTop = destinationsTableViewTop.constant
    loadingViewActiveWidth = loadingViewWidth.constant * 1.8
    loadingViewInactiveWidth = loadingViewWidth.constant
    
    // Setup
    view.bringSubview(toFront: blurView)
    backButton.alpha = 0
    fieldStackView.alpha = 0
    currentLocationButton.layer.cornerRadius = currentLocationButton.frame.height * 0.5
    destinationField.autocorrectionType = .no
    destinationField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    destinationsTableView.register(UINib(nibName: "DestinationTableViewCell", bundle: nil), forCellReuseIdentifier: DestinationCell)
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

