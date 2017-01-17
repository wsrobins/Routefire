//
//  SettingsViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/12/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  // MARK: Presenter
  let presenter = SettingsPresenter()
  
  // MARK: View
  @IBOutlet weak var panel: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var pastRoutesButton: UIButton!
  @IBOutlet weak var reportDelaysButton: UIButton!
  @IBOutlet weak var profileButton: UIButton!
  
  // MARK: Gesture recognizers
  var panGestureRecognizer: UIPanGestureRecognizer!
  
  // MARK: Constraints
  @IBOutlet weak var panelTrailing: NSLayoutConstraint!
  @IBOutlet weak var panelWidth: NSLayoutConstraint!
  
  // MARK: Constraint constants
  var panelActiveTrailingConstant: CGFloat!
  var panelInactiveTrailingConstant: CGFloat!
  
  // MARK: Container view controller
  let containerVC = (UIApplication.shared.delegate as? AppDelegate)?.containerVC
  
  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: User interaction
  func viewPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began, .changed:
      let translation = gestureRecognizer.translation(in: view)
      guard panelTrailing.constant + translation.x > panelInactiveTrailingConstant else {
        panelTrailing.constant = panelInactiveTrailingConstant
        return
      }
      
      guard panelTrailing.constant + translation.x <= panelActiveTrailingConstant else {
        panelTrailing.constant = panelActiveTrailingConstant
        return
      }
      
      panelTrailing.constant += translation.x
      gestureRecognizer.setTranslation(CGPoint.zero, in: view)
    case .ended:
      if panelTrailing.constant <= panel.frame.width * 0.7 {
        slidePanelLeft()
      } else if panelTrailing.constant < panelActiveTrailingConstant {
        slidePanelRight()
      }
    default:
      return
    }
  }
  
  @IBAction func profileButtonTouched() {
    let profileVC = ProfileViewController()
    containerVC?.add(child: ProfileViewController(), .above)
    
    profileVC.view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 1,
      options: [.allowUserInteraction, .curveEaseOut],
      animations: {
        profileVC.whiteViewCenterX.constant = profileVC.whiteViewActiveCenterXConstant
        profileVC.view.layoutIfNeeded()
    }) { _ in
      self.containerVC?.removePreviousChild()
    }
  }
  
  @IBAction func backButtonTouched() {
    slidePanelLeft()
  }
}

// MARK: - Animate transitions
private extension SettingsViewController {
  func slidePanelLeft() {
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.14,
      delay: 0,
      options: .curveLinear,
      animations: {
        self.panelTrailing.constant = self.panelInactiveTrailingConstant
        self.view.layoutIfNeeded()
    }) { _ in
      let settingsVC = self.containerVC?.currentChild
      self.containerVC?.currentChild = self.containerVC?.previousChild
      self.containerVC?.previousChild = settingsVC
      self.containerVC?.removePreviousChild()
    }
  }
  
  func slidePanelRight() {
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        self.panelTrailing.constant = self.panelActiveTrailingConstant
        self.view.layoutIfNeeded()
    }, completion: nil)
  }
}

// MARK: - Configuration
private extension SettingsViewController {
  func configure() {
    
    // View
    CALayer.boldShadow(pastRoutesButton)
    pastRoutesButton.layer.cornerRadius = pastRoutesButton.frame.height * 0.5
    
    CALayer.boldShadow(reportDelaysButton)
    reportDelaysButton.layer.cornerRadius = reportDelaysButton.frame.height * 0.5
    
    CALayer.boldShadow(profileButton)
    profileButton.layer.cornerRadius = profileButton.frame.height * 0.5
    
    // Gesture recognizers
    panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(viewPanned(_:)))
    view.addGestureRecognizer(panGestureRecognizer)
    
    // Store constraint constants
    panelActiveTrailingConstant = UIScreen.main.bounds.width
    panelInactiveTrailingConstant = panelTrailing.constant
    
    // Configure initial constraints
    panelWidth.constant = UIScreen.main.bounds.width + 20
  }
}
