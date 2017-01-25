//
//  LaunchWireframe.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

// Custom animated transitioning protocol
protocol LaunchWireframeAnimatedTransitioning: UIViewControllerAnimatedTransitioning {}

class LaunchWireframe: NSObject {
  
  // View
  weak var view: LaunchViewController!
  
  func transitionToHomeModule() {
    let homeView = HomeViewController()
    let homePresenter = HomePresenter()
    let homeRouter = HomeWireframe()
    homeView.presenter = homePresenter
    homePresenter.view = homeView
    
    homeView.transitioningDelegate = view
    view.present(homeView, animated: true, completion: nil)
  }
}

// Animated transitioning
extension LaunchWireframe: LaunchWireframeAnimatedTransitioning {
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
    }, completion: nil)
    
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
