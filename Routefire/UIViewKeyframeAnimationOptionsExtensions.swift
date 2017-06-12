//
//  UIViewKeyframeAnimationOptionsExtensions.swift
//  Routefire
//
//  Created by William Robinson on 6/10/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

extension UIViewKeyframeAnimationOptions {
	
	// MARK: Animation options
	
	static let curveEaseIn: UIViewKeyframeAnimationOptions = UIViewKeyframeAnimationOptions(animationOptions: .curveEaseIn)
	static let curveEaseOut: UIViewKeyframeAnimationOptions = UIViewKeyframeAnimationOptions(animationOptions: .curveEaseOut)
	static let curveEaseInOut: UIViewKeyframeAnimationOptions = UIViewKeyframeAnimationOptions(animationOptions: .curveEaseInOut)
	
	// MARK: Initialization
	
	init(animationOptions: UIViewAnimationOptions) {
		self.rawValue = animationOptions.rawValue
	}
}
