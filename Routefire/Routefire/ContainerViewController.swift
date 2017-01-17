//
//  ContainerViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/6/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import SnapKit

final class ContainerViewController: UIViewController {
  
  // MARK: Child view position
  enum Position {
    case above, below
  }
  
  // MARK: Child iew controllers
  var currentChild: UIViewController?
  var previousChild: UIViewController?
  
  // MARK: Child view onstraints
  var currentChildEdges: Constraint?
  var previousChildEdges: Constraint?
  
  // MARK: Add child
  func add(child: UIViewController, _ position: Position) {
    previousChild = currentChild
    previousChildEdges = currentChildEdges
    currentChild = child
    
    addChildViewController(child)
    switch position {
    case .above:
      view.addSubview(child.view)
    case .below:
      guard let previousChild = previousChild else { return }
      view.insertSubview(child.view, belowSubview: previousChild.view)
    }
    
    child.view.snp.makeConstraints {
      self.currentChildEdges = $0.edges.equalToSuperview().constraint
    }
    
    child.didMove(toParentViewController: self)
  }
  
  // MARK: Remove child
  func removePreviousChild() {
    previousChild?.willMove(toParentViewController: nil)
    previousChild?.view.removeFromSuperview()
    previousChildEdges = nil
    previousChild?.removeFromParentViewController()
  }
}

