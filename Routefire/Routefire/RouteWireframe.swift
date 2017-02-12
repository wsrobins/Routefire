//
//  RouteWireframe.swift
//  Routefire
//
//  Created by William Robinson on 1/19/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import ReachabilitySwift

// Custom animated transitioning protocol
protocol RouteWireframeAnimatedTransitioning: UIViewControllerAnimatedTransitioning {}

protocol RouteWireframeProtocol {
  func transitionToHomeModule()
}

class RouteWireframe: NSObject, RouteWireframeProtocol {
  weak var view: RouteViewController!
  weak var presenter: RoutePresenterProtocol!
  weak var homePresenter: HomePresenterRouteModuleProtocol!
  
  func transitionToHomeModule() {
    NotificationCenter.default.removeObserver(view)
    homePresenter.setTrip(presenter.trip)
    view.dismiss(animated: true)
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
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        fromVC.routeView.alpha = 0
        containerView.layoutIfNeeded()
    })
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.05,
      options: .curveEaseInOut,
      animations: {
        fromVC.destinationsTableViewVisibleTop.isActive = false
        fromVC.destinationsTableViewHiddenTop.isActive = true
        toVC.whereToButtonTop.constant = toVC.whereToButtonActiveTop
        toVC.whereToButtonExpandedWidth.isActive = false
        toVC.whereToButtonCondensedWidth.isActive = true
        toVC.whereToButtonHeight.constant = toVC.whereToButtonActiveHeight
        toVC.toggleReachabilityView()
        containerView.layoutIfNeeded()
    })
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.2,
      options: .curveEaseInOut,
      animations: {
        toVC.whereToButton.titleLabel!.alpha = 1
        toVC.routesView.alpha = 1
        containerView.layoutIfNeeded()
    }) { _ in
      toVC.presenter.observeReachability()
      transitionContext.completeTransition(true)
    }
  }
}
