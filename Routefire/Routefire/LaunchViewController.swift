//
//  LaunchViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
  
  // MARK: VIPER
  var router: LaunchRouterProtocol!
  
  // MARK: Subviews
  @IBOutlet weak var whiteView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  
  // MARK: Constraints
  @IBOutlet weak var whiteViewTop: NSLayoutConstraint!
  @IBOutlet weak var whiteViewWidth: NSLayoutConstraint!
  @IBOutlet weak var whiteViewHeight: NSLayoutConstraint!
  @IBOutlet weak var titleLabelCenterX: NSLayoutConstraint!
  
  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    router.transitionToHomeModule(self)
  }
}

// MARK: - Transitioning delegate
extension LaunchViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return router
  }
}

// MARK: - Configuration
private extension LaunchViewController {
  func configure() {
    whiteViewWidth.constant = view.frame.width
    whiteViewHeight.constant = view.frame.height
  }
}

