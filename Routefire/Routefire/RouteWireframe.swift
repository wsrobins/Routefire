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
  func transitionToHomeModule(timer: Timer?)
}

class RouteWireframe: NSObject, RouteWireframeProtocol {
  weak var view: RouteViewController!
  weak var presenter: RoutePresenterProtocol!
  
  func transitionToHomeModule(timer: Timer?) {
    timer?.invalidate()
    NotificationCenter.default.removeObserver(view)
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
    
    if let trip = presenter.trip {
      toVC.presenter.trip = trip
      toVC.bestRoutesAddressButton.setTitle(trip.name, for: .normal)
      toVC.bestRoutesView.alpha = 0
      toVC.whereToButton.isHidden = true
      toVC.bestRoutesCollectionView.isHidden = trip.routes.isEmpty
      toVC.bestRoutesView.isHidden = false
      if !trip.routes.isEmpty {
        toVC.bestRoutesCollectionView.delegate = toVC
        toVC.bestRoutesCollectionView.dataSource = toVC
        toVC.bestRoutesExpandButton.isEnabled = true
        toVC.bestRoutesCollectionView.setContentOffset(CGPoint.zero, animated: false)
        toVC.bestRoutesCollectionView.reloadData()
      } else {
        toVC.bestRoutesExpandButton.isEnabled = false
      }
    } else {
      toVC.whereToButton.isHidden = false
      toVC.bestRoutesView.isHidden = true
    }
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.3,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        fromVC.blurView.effect = nil
    }) { _ in
      fromVC.blurView.isHidden = true
    }
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.15,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        fromVC.loadingView.alpha = 0
    }) { _ in
      fromVC.loadingView.isHidden = true
    }
    
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
        fromVC.destinationsTableViewTop.constant = 0
        toVC.whereToButtonTop.constant = 80
        toVC.whereToButtonWidth.constant = toVC.view.frame.width - 50
        toVC.whereToButtonHeight.constant = 60
        toVC.reachabilityViewBottom.constant = toVC.presenter.networkReachable ? 0 : toVC.reachabilityView.frame.height
        toVC.bestRoutesViewTop.constant = toVC.presenter.networkReachable ? 28 : 8
        toVC.bestRoutesDropdownViewHeight.constant = toVC.bestRoutesDropdownViewCollapsedHeight - (toVC.presenter.networkReachable ? 0 : 20)
        toVC.bestRoutesAddressViewHeight.constant = toVC.bestRoutesDropdownViewCollapsedHeight - (toVC.presenter.networkReachable ? 0 : 20)
        containerView.layoutIfNeeded()
    })
    
    containerView.layoutIfNeeded()
    UIView.animate(
      withDuration: 0.25,
      delay: 0.2,
      options: .curveEaseInOut,
      animations: {
        toVC.whereToButton.titleLabel?.alpha = 1
        toVC.bestRoutesView.alpha = 1
        containerView.layoutIfNeeded()
    }) { _ in
      toVC.presenter.observeReachability()
      transitionContext.completeTransition(true)
    }
  }
}
