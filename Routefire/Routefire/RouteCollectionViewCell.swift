//
//  RouteCollectionViewCell.swift
//  Routefire
//
//  Created by William Robinson on 1/11/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit

class RouteCollectionViewCell: UICollectionViewCell {
  
  // Subviews
  @IBOutlet weak var view: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
		
  // Initialization
  override func awakeFromNib() {
    super.awakeFromNib()
    
    nameLabel.text = ""
    timeLabel.text = ""
    priceLabel.text = ""
  }
  
  // Add content to display
  func addContent(for route: Route, best: Bool) {
    nameLabel.font = UIFont.systemFont(ofSize: (best ? 32 : 21), weight: UIFontWeightBlack)
    timeLabel.font = UIFont.systemFont(ofSize: (best ? 15 : 14), weight: UIFontWeightThin)
    priceLabel.font = UIFont.systemFont(ofSize: (best ? 18 : 16), weight: UIFontWeightBlack)
    nameLabel.text = route.name
    timeLabel.text = route.arrival
    priceLabel.text = route.lowPrice == route.highPrice ? "$\(route.lowPrice)" : "$\(route.lowPrice)-\(route.highPrice)"
  }
}