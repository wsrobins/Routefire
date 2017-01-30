//
//  Shadows.swift
//  Routefire
//
//  Created by William Robinson on 1/9/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

extension CALayer {
  static func darkShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.25
    view.layer.shadowRadius = 15
    view.layer.shadowOffset = CGSize(width: 0, height: 1)
  }
  
  static func boldShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.25
    view.layer.shadowRadius = 10
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
  }
  
  static func lightShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.09
    view.layer.shadowRadius = 6
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
  }
  
  static func leftShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.2
    view.layer.shadowRadius = 6
    view.layer.shadowOffset = CGSize(width: -6, height: 0)
  }

  static func rightShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.2
    view.layer.shadowRadius = 6
    view.layer.shadowOffset = CGSize(width: 6, height: 0)
  }
  
  static func noShadow(_ view: UIView) {
    view.layer.shadowOpacity = 0
  }
}
