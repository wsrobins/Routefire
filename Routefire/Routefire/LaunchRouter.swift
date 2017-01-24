//
//  LaunchRouter.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

protocol LaunchRouterProtocol: UIViewControllerAnimatedTransitioning {
  func transitionToHomeModule(_ launchView: LaunchViewController)
}

class LaunchRouter: NSObject, LaunchRouterProtocol {
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
    return 0.65
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
      delay: 0.35,
      options: .curveEaseInOut,
      animations: {
        toVC.settingsButtonBottom.constant = toVC.settingsButton.frame.height + UIApplication.shared.statusBarFrame.height
        toVC.settingsButton.alpha = 1
        containerView.layoutIfNeeded()
    }, completion: nil)
    
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
