//
//  Shadows.swift
//  Routefire
//
//  Created by William Robinson on 1/9/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

extension CALayer {
  static func shadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.28
    view.layer.shadowRadius = 10
    view.layer.shadowOffset = CGSize(width: 2, height: 5)
  }
  
  static func lightShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.12
    view.layer.shadowRadius = 6
    view.layer.shadowOffset = CGSize(width: 1, height: 3)
  }
  
  static func noShadow(_ view: UIView) {
    view.layer.shadowOpacity = 0
  }
}
