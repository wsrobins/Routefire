//
//  HomeRouter.swift
//  Routefire
//
//  Created by William Robinson on 1/17/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol HomeRouterProtocol: UIViewControllerAnimatedTransitioning {
  var presenting: Bool { get set }
  func transitionToRouteModule(_ homeView: HomeViewController)
}

class HomeRouter: NSObject, HomeRouterProtocol {
  var presenting = true
  
  func transitionToRouteModule(_ homeView: HomeViewController) {
    let routeView = RouteViewController()
    let routePresenter = RoutePresenter()
    routeView.presenter = routePresenter
    routeView.router = RouteRouter()
    routePresenter.view = routeView
    routePresenter.interactor = RouteInteractor()
    
    routeView.transitioningDelegate = homeView
    homeView.present(routeView, animated: true, completion: nil)
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    if presenting {
      return 0.5
    } else {
      return 0.45
    }
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    if presenting {
      presentingTransition(transitionContext)
    } else {
      dismissingTransition(transitionContext)
    }
  }
  
  func presentingTransition(_ context: UIViewControllerContextTransitioning) {
    let containerView = context.containerView
    let fromVC =  context.viewController(forKey: .from) as! HomeViewController
    let toVC = context.viewController(forKey: .to) as! RouteViewController
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
      context.completeTransition(true)
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
        fromVC.settingsButtonBottom.constant = 0
        fromVC.settingsButton.alpha = 0
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
  
  func dismissingTransition(_ context: UIViewControllerContextTransitioning) {
    let containerView = context.containerView
    let fromVC = context.viewController(forKey: .from) as! RouteViewController
    let toVC = context.viewController(forKey: .to) as! HomeViewController
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
        toVC.whereToButtonWidth.constant = toVC.view.frame.width - 40
        toVC.whereToButtonHeight.constant = 60
        toVC.settingsButtonBottom.constant = toVC.settingsButton.frame.height + UIApplication.shared.statusBarFrame.height
        toVC.settingsButton.alpha = 1
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
      context.completeTransition(true)
    }
  }
}
