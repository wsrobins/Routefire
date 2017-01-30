//
//  Animations.swift
//  Routefire
//
//  Created by William Robinson on 1/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

extension UIViewKeyframeAnimationOptions {
  init(_ animationOptions: UIViewAnimationOptions) {
    rawValue = animationOptions.rawValue
  }
}

