//
//  LaunchViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
  
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
    
    configureView()
  }
}

// View configuration
private extension LaunchViewController {
  func configureView() {
    
    // Frame
    view.frame = UIScreen.main.bounds
    
    // Setup
    whiteViewWidth.constant = view.frame.width
    whiteViewHeight.constant = view.frame.height
  }
}

// Transitioning delegate
extension LaunchViewController: UIViewControllerTransitioningDelegate {
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
}

// Transition to home module
extension LaunchViewController {
  func transitionToHomeModule() {
    let homeView = HomeViewController()
    let homePresenter = HomePresenter()
    let homeWireframe = HomeWireframe()
    homeView.presenter = homePresenter
    homeView.wireframe = homeWireframe
    homePresenter.view = homeView
    homePresenter.wireframe = homeWireframe
    homeWireframe.view = homeView
    homeWireframe.presenter = homePresenter
    
    homeView.transitioningDelegate = self
    present(homeView, animated: true)
  }
}

// Animated transitioning
extension LaunchViewController: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.65
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromVC = transitionContext.viewController(forKey: .from) as? LaunchViewController,
      let toVC = transitionContext.viewController(forKey: .to) as? HomeViewController else { return }
    let containerView = transitionContext.containerView
    let blurView = UIVisualEffectView(frame: toVC.view.frame)
    blurView.effect = UIBlurEffect(style: .dark)
    toVC.view.addSubview(blurView)
    containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        fromVC.titleLabelCenterX.constant = fromVC.view.frame.width
        containerView.layoutIfNeeded()
    })
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.3,
      delay: 0.2,
      options: .curveEaseInOut,
      animations: {
        fromVC.whiteViewTop.constant = toVC.whereToButtonTop.constant
        fromVC.whiteViewWidth.constant = toVC.whereToButton.frame.width
        fromVC.whiteViewHeight.constant = toVC.whereToButton.frame.height
        blurView.effect = nil
        containerView.layoutIfNeeded()
    }) { _ in
      blurView.removeFromSuperview()
    }
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0.5,
      options: .curveEaseOut,
      animations: {
        fromVC.whiteView.alpha = 0
        containerView.layoutIfNeeded()
    }) { _ in
      transitionContext.completeTransition(true)
    }
  }
}
