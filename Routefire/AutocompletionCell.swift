//
//  AutocompletionCell.swift
//  Routefire
//
//  Created by William Robinson on 6/3/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import GooglePlaces
import Material
import SnapKit

protocol AutcompletionCellInput: class {
	func setUp(with autocompletion: Autocompletion, isDefault: Bool)
}

class AutocompletionCell: UICollectionViewCell {
	
	// MARK: Reuse identifier
	
	static let reuseID: String = "AutocompletionCell"
	
	// MARK: Subviews
	
	fileprivate lazy var bubbleView: UIView = {
		let bubbleView: UIView = UIView()
		bubbleView.cornerRadius = self.bubbleViewHeight * 0.5
		return bubbleView
	}()
	
	lazy var titleLabel: UILabel = {
		let titleLabel: UILabel = UILabel()
		titleLabel.font = RobotoFont.bold(with: 17)
		titleLabel.textColor = .white
		return titleLabel
	}()
	
	// MARK: Layout properties

	fileprivate let padding: CGFloat = 16
	fileprivate let bubbleViewHeight: CGFloat = 39
	
	// MARK: Initialization
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addSubviews()
		self.layout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError()
	}
	
	// MARK: Add subviews
	
	fileprivate func addSubviews() {
		self.contentView.addSubview(self.bubbleView)
		self.bubbleView.addSubview(self.titleLabel)
	}
	
	// MARK: Layout
	
	fileprivate func layout() {
		self.layoutBubbleView()
		self.layoutTitleLabel()
	}
	
	fileprivate func layoutBubbleView() {
		self.bubbleView.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.left.equalToSuperview()
			remake.right.lessThanOrEqualToSuperview()
			remake.centerY.equalToSuperview()
			remake.height.equalTo(self.bubbleViewHeight)
		}
	}
	
	fileprivate func layoutTitleLabel() {
		self.titleLabel.snp.remakeConstraints { (remake: ConstraintMaker) in
			remake.top.bottom.equalToSuperview()
			remake.left.equalToSuperview().inset(self.padding)
			remake.right.equalToSuperview().inset(self.padding).priority(999)
		}
	}
}

// MARK: - Autocompletion cell input
extension AutocompletionCell: AutcompletionCellInput {
	
	func setUp(with autocompletion: Autocompletion, isDefault: Bool) {
		guard !isDefault else {
			self.titleLabel.attributedText = autocompletion.title
			self.bubbleView.backgroundColor = #colorLiteral(red: 0.9209591746, green: 0.5387042761, blue: 0.5511635542, alpha: 1)
			return
		}
		let title: NSMutableAttributedString = autocompletion.title.mutableCopy() as! NSMutableAttributedString
		title.enumerateAttribute(kGMSAutocompleteMatchAttribute, in: NSMakeRange(0, title.length), options: []) { (value: Any?, range: NSRange, _) in
			let titleFont: UIFont = value != nil ? self.titleLabel.font : RobotoFont.regular(with: 17)
			let titleColor: UIColor = value != nil ? .groupTableViewBackground : .lightGray
			let attributes: [String : Any] = [NSFontAttributeName : titleFont, NSForegroundColorAttributeName : titleColor]
			title.addAttributes(attributes, range: range)
		}
		self.titleLabel.attributedText = title
		self.bubbleView.backgroundColor = .black
	}
}




