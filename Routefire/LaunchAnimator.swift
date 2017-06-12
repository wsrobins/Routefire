//
//  LaunchAnimator.swift
//  Routefire
//
//  Created by William Robinson on 6/10/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class LaunchAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 1
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let containerView: UIView = transitionContext.containerView
		let fromViewController: LaunchViewController = transitionContext.viewController(forKey: .from) as! LaunchViewController
		let toViewController: HomeViewController = transitionContext.viewController(forKey: .to) as! HomeViewController
		containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
		UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: { 
			fromViewController.view.alpha = 0
		}) { _ in
			transitionContext.completeTransition(true)
		}
	}
}
