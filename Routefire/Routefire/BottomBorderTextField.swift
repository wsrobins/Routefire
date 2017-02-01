//
//  BottomBorderTextField.swift
//  Routefire
//
//  Created by William Robinson on 1/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class BottomBorderTextField: UITextField , UITextFieldDelegate {
  let border = CALayer()
  let width: CGFloat = 1
  
  required init?(coder aDecoder: (NSCoder!)) {
    super.init(coder: aDecoder)
    
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: width)
    border.borderWidth = width
    border.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
    layer.addSublayer(border)
    layer.masksToBounds = true
    delegate = self
  }
  
  override func draw(_ rect: CGRect) {
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: width)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
  }
  
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(10, 15, 8, 15))
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(10, 15, 8, 15))
  }
}
