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
    
    delegate = self
    
    border.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    border.borderWidth = width
    border.frame = CGRect(x: 0,
                          y: self.frame.size.height - width,
                          width:  self.frame.size.width,
                          height: self.frame.size.height)
    
    self.layer.addSublayer(border)
    self.layer.masksToBounds = true
  }
  
  override func draw(_ rect: CGRect) {
    border.frame = CGRect(x: 0,
                          y: self.frame.size.height - width,
                          width:  self.frame.size.width,
                          height: self.frame.size.height)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    border.frame = CGRect(x: 0,
                          y: self.frame.size.height - width,
                          width:  self.frame.size.width,
                          height: self.frame.size.height)
  }
}
