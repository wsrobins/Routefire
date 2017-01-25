//
//  LaunchViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
  
  // Presenter
  var presenter: LaunchPresenterProtocol!
  
  // Wireframe
  var wireframe: LaunchWireframeAnimatedTransitioning!
  
  // Subviews
  @IBOutlet weak var whiteView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  
  // Constraints
  @IBOutlet weak var whiteViewTop: NSLayoutConstraint!
  @IBOutlet weak var whiteViewWidth: NSLayoutConstraint!
  @IBOutlet weak var whiteViewHeight: NSLayoutConstraint!
  @IBOutlet weak var titleLabelCenterX: NSLayoutConstraint!
  
  // Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    presenter.showHomeModule()
  }
}

// View configuration
private extension LaunchViewController {
  func configure() {
    whiteViewWidth.constant = view.frame.width
    whiteViewHeight.constant = view.frame.height
  }
}

// Transitioning delegate
extension LaunchViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return wireframe
  }
}

