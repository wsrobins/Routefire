//
//  RouteWireframe.swift
//  Routefire
//
//  Created by William Robinson on 1/19/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

// Custom animated transitioning protocol
protocol RouteWireframeAnimatedTransitioning: UIViewControllerAnimatedTransitioning {}

protocol RouteRouterProtocol {
  func back(_ routeView: RouteViewController)
  func showBestRoutes(_ routeView: RouteViewController, routes: [Route], destinationName: String)
}

class RouteWireframe: NSObject, RouteRouterProtocol {
  func back(_ routeView: RouteViewController) {
    routeView.dismiss(animated: true, completion: nil)
  }
  
  func showBestRoutes(_ routeView: RouteViewController, routes: [Route], destinationName: String) {
    let homeView = routeView.presentingViewController as! HomeViewController
    homeView.presenter?.bestRoutes = routes
    homeView.bestRoutesAddressButton.setTitle(destinationName, for: .normal)
    homeView.bestRoutesView.isHidden = false
    homeView.bestRoutesCollectionView.reloadData()
    routeView.dismiss(animated: true, completion: nil)
  }
}

// Animated transitioning
extension RouteWireframe: RouteWireframeAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.45
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let fromVC = transitionContext.viewController(forKey: .from) as! RouteViewController
    let toVC = transitionContext.viewController(forKey: .to) as! HomeViewController
    containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
    IQKeyboardManager.sharedManager().resignFirstResponder()
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        fromVC.routeView.alpha = 0
        containerView.layoutIfNeeded()
    }, completion: nil)
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.05,
      options: .curveEaseInOut,
      animations: {
        fromVC.destinationsTableViewTop.constant = 0
        toVC.whereToButtonTop.constant = 100
        toVC.whereToButtonWidth.constant = toVC.view.frame.width - 80
        toVC.whereToButtonHeight.constant = 60
        containerView.layoutIfNeeded()
    }, completion: nil)
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.2,
      options: .curveEaseInOut,
      animations: {
        toVC.whereToButton.titleLabel?.alpha = 1
        containerView.layoutIfNeeded()
    }) { _ in
      transitionContext.completeTransition(true)
    }
  }
}
