//
//  ProfileViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/15/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  
  // MARK: Presenter
  
  
  // MARK: View
  @IBOutlet weak var whiteView: UIView!
  
  // MARK: Constraints
  @IBOutlet weak var whiteViewCenterX: NSLayoutConstraint!
  
  // MARK: Constraint constants
  var whiteViewActiveCenterXConstant: CGFloat!
  var whiteViewInactiveCenterXConstant: CGFloat!
  
  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  // MARK: User interaction
  @IBAction func backButtonTouched() {
    
  }
  
  
  
  
}

// MARK: - Animate transitions
private extension ProfileViewController {
  func slidePanelLeft() {
    view.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.18,
      delay: 0,
      options: .curveLinear,
      animations: {
        self.whiteViewCenterX.constant = self.whiteViewInactiveCenterXConstant
        self.view.layoutIfNeeded()
    }) { _ in
//      let profileVC = self.containerVC?.currentChild
//      self.containerVC?.currentChild = self.containerVC?.previousChild
//      self.containerVC?.previousChild = profileVC
//      self.containerVC?.removePreviousChild()
    }
  }
}


// MARK: - Configuration
private extension ProfileViewController {
  func configure() {
    
    // Presenter
    
    
    // View
    
    
    // Store constraint constants
    whiteViewActiveCenterXConstant = 0
    whiteViewInactiveCenterXConstant = UIScreen.main.bounds.width
    
    // Set up initial constraints
    whiteViewCenterX.constant = whiteViewInactiveCenterXConstant
  }
}



