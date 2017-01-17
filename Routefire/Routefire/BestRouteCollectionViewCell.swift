//
//  BestRouteCollectionViewCell.swift
//  Routefire
//
//  Created by William Robinson on 1/11/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class BestRouteCollectionViewCell: UICollectionViewCell {
  
  // MARK: Views
  @IBOutlet weak var view: UIView!
    @IBOutlet weak var routeTypeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
		
  // MARK: Initialization
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // Clear labels
    routeTypeLabel.text = ""
    priceLabel.text = ""
//    timeLabel.text = ""
  }
}
