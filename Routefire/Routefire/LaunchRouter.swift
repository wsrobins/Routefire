//
//  LaunchRouter.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import SnapKit

// MARK: Launch router protocol
protocol LaunchRouterProtocol: UIViewControllerAnimatedTransitioning {
  func transitionToHomeModule(_ launchView: LaunchViewController)
}

class LaunchRouter: NSObject, LaunchRouterProtocol {
  
  // MARK: Transition properties
  let duration = 0.9
  
  // MARK: Custom transition to home module
  func transitionToHomeModule(_ launchView: LaunchViewController) {
    let homeView = HomeViewController()
    let homePresenter = HomePresenter()
    let homeRouter = HomeRouter()
    homeView.presenter = homePresenter
    homeView.router = homeRouter
    homePresenter.view = homeView
    
    homeView.transitioningDelegate = launchView
    launchView.present(homeView, animated: true, completion: nil)
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let fromVC = transitionContext.viewController(forKey: .from) as! LaunchViewController
    let toVC = transitionContext.viewController(forKey: .to) as! HomeViewController
    let blurView = UIVisualEffectView(frame: toVC.view.frame)
    blurView.effect = UIBlurEffect(style: .dark)
    toVC.view.addSubview(blurView)
    containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
  
    containerView.layoutIfNeeded()
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0,
      options: UIViewKeyframeAnimationOptions(.curveEaseInOut),
      animations: {
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3) {
          fromVC.titleLabelCenterX.constant = fromVC.view.frame.width
          containerView.layoutIfNeeded()
        }
        
        UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.5) {
          fromVC.whiteViewTop.constant = toVC.whereToButtonTop.constant
          fromVC.whiteViewWidth.constant = toVC.whereToButtonWidth.constant
          fromVC.whiteViewHeight.constant = toVC.whereToButtonHeight.constant
          blurView.effect = nil
          containerView.layoutIfNeeded()
        }
        
        UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
          fromVC.whiteView.alpha = 0
          toVC.settingsButtonBottom.constant = toVC.settingsButton.frame.height + UIApplication.shared.statusBarFrame.height
          containerView.layoutIfNeeded()
        }
    }) { _ in
      blurView.removeFromSuperview()
      transitionContext.completeTransition(true)
    }
  }
}
