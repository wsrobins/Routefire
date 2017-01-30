//
//  HomeWireframe.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

// Custom animated transitioning protocol
protocol HomeWireframeAnimatedTransitioning: UIViewControllerAnimatedTransitioning {}

protocol HomeWireframeProtocol: UIViewControllerAnimatedTransitioning {
  func transitionToRouteModule()
}

class HomeWireframe: NSObject, HomeWireframeProtocol {
  weak var view: HomeViewController!
  weak var presenter: HomePresenter!
  
  func transitionToRouteModule() {
    NotificationCenter.default.removeObserver(presenter)
    let routeView = RouteViewController()
    let routePresenter = RoutePresenter()
    let routeWireframe = RouteWireframe()
    routeView.presenter = routePresenter
    routeView.wireframe = routeWireframe
    routePresenter.view = routeView
    routePresenter.wireframe = routeWireframe
    routeWireframe.view = routeView
    
    routeView.transitioningDelegate = view
    view.present(routeView, animated: true, completion: nil)
  }
}

// Animated transitioning
extension HomeWireframe: HomeWireframeAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView
    let fromVC =  transitionContext.viewController(forKey: .from) as! HomeViewController
    let toVC = transitionContext.viewController(forKey: .to) as! RouteViewController
    containerView.addSubview(toVC.view)
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.8,
      initialSpringVelocity: 1,
      options: .curveEaseIn,
      animations: {
        toVC.destinationsTableViewTop.constant = toVC.destinationsTableView.frame.height
        containerView.layoutIfNeeded()
    }) { _ in
      transitionContext.completeTransition(true)
    }
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.1,
      delay: 0,
      options: .curveEaseIn,
      animations: {
        fromVC.whereToButton.titleLabel?.alpha = 0
        containerView.layoutIfNeeded()
    }) { _ in
      toVC.destinationField.becomeFirstResponder()
    }
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.26,
      delay: 0.04,
      options: .curveEaseInOut,
      animations: {
        fromVC.whereToButtonTop.constant = 0
        fromVC.whereToButtonWidth.constant = toVC.routeView.frame.width
        fromVC.whereToButtonHeight.constant = toVC.routeView.frame.height
        fromVC.reachabilityViewBottom.constant = 0
        containerView.layoutIfNeeded()
    }) { _ in
      toVC.routeView.backgroundColor = UIColor.white
    }
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0.15,
      options: .curveEaseOut,
      animations: {
        toVC.backButton.alpha = 1
        toVC.fieldStackView.alpha = 1
        containerView.layoutIfNeeded()
    }, completion: nil)
  }
}
