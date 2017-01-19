//
//  HomeRouter.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

protocol HomeRouterProtocol: UIViewControllerAnimatedTransitioning {
  func transitionToRouteModule(_ homeView: HomeViewController)
}

class HomeRouter: NSObject, HomeRouterProtocol {
  let duration = 0.7
  
  func transitionToRouteModule(_ homeView: HomeViewController) {
    let routeView = RouteViewController()
    let routePresenter = RoutePresenter()
    let routeRouter = RouteRouter()
    
    routeView.presenter = routePresenter
    
    routeView.transitioningDelegate = homeView
    homeView.present(routeView, animated: true, completion: nil)
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let fromVC = transitionContext.viewController(forKey: .from) as! HomeViewController
    let toVC = transitionContext.viewController(forKey: .to) as! RouteViewController
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
      transitionContext.completeTransition(true)
    }
  }
}
