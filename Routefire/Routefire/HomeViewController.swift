//
//  HomeViewController.swift
//  Routefire
//
//  Created by William Robinson on 1/5/17.
//  Copyright © 2017 William Robinson. All rights reserved.
//

import UIKit
import GoogleMaps
import IQKeyboardManagerSwift

class HomeViewController: UIViewController {
  
  // MARK: Views
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var buttonStackView: UIStackView!
  @IBOutlet weak var firstRecentDestinationButton: UIButton!
  @IBOutlet weak var secondRecentDestinationButton: UIButton!
  @IBOutlet weak var thirdRecentDestinationButton: UIButton!
  @IBOutlet weak var upperView: UIView!
  @IBOutlet weak var whereToButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var fieldStackView: UIStackView!
  @IBOutlet weak var locationField: UITextField!
  @IBOutlet weak var destinationField: UITextField!
  @IBOutlet weak var destinationTableView: UITableView!
  @IBOutlet weak var destinationTableViewBlurView: UIVisualEffectView!
  @IBOutlet weak var settingsView: UIView!
  @IBOutlet weak var settingsBlurView: UIVisualEffectView!
  @IBOutlet weak var settingsMenuView: UIView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var pastRoutesButton: UIButton!
  @IBOutlet weak var reportDelaysButton: UIButton!
  @IBOutlet weak var profileButton: UIButton!
  @IBOutlet weak var slideView: UIView!
  @IBOutlet weak var profileView: UIView!
  
  // MARK: Gesture recognizers
  @IBOutlet var settingsViewPanGestureRecognizer: UIPanGestureRecognizer!
  
  // MARK: Constraints
  @IBOutlet weak var settingsButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var upperViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var upperViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var upperViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var backButtonTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var fieldStackViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var fieldStackViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var destinationTableViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var destinationTableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var settingsMenuViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var slideViewTrailingConstraint: NSLayoutConstraint!
  
  // MARK: Constraint constants
  var settingsButtonVisibleBottomConstant: CGFloat!
  var settingsButtonHiddenBottomConstant: CGFloat!
  
  var upperViewVisibleTopConstant: CGFloat!
  var upperViewHiddenTopConstant: CGFloat!
  
  var upperViewVisibleWidthConstant: CGFloat!
  var upperViewHiddenWidthConstant: CGFloat!
  
  var upperViewVisibleHeightConstant: CGFloat!
  var upperViewHiddenHeightConstant: CGFloat!
  
  var backButtonVisibleTrailingConstant: CGFloat!
  var backButtonHiddenTrailingConstant: CGFloat!
  
  var fieldStackViewVisibleLeadingConstant: CGFloat!
  var fieldStackViewHiddenLeadingConstant: CGFloat!
  
  var destinationTableViewVisibleTopConstant: CGFloat!
  var destinationTableViewHiddenTopConstant: CGFloat!
  
  var settingsMenuViewVisibleTrailingConstant: CGFloat!
  var settingsMenuViewHiddenTrailingConstant: CGFloat!
  
  var slideViewVisibleTrailingConstant: CGFloat!
  var slideViewHiddenTrailingConstant: CGFloat!
  
  // MARK: Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configure()
  }
}

// MARK: - Table view data source
extension HomeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.destinationCell) as? DestinationTableViewCell else {
      return UITableViewCell()
    }
    
    switch indexPath.row {
    case 0: cell.destinationLabel.text = "Home"
    case 1: cell.destinationLabel.text = "Work"
    case 2: cell.destinationLabel.text = "Gym"
    case 3: cell.destinationLabel.text = "Pablo's"
    case 4: cell.destinationLabel.text = "McDanks"
    default:
      break
    }
    
    return cell
  }
}

// MARK: - Handle user interaction
private extension HomeViewController {
  @IBAction func whereToButtonTouched() {
    let (keyframeAnimations, animations, keyframeCompletion, completion) = whereToButtonTouchedAnimations()
    view.layoutIfNeeded()
    UIView.animateKeyframes(withDuration: 0.35,
                            delay: 0,
                            options: UIViewKeyframeAnimationOptions(animationOptions: .curveEaseInOut),
                            animations: keyframeAnimations,
                            completion: keyframeCompletion)
    UIView.animate(withDuration: 0.2,
                   delay: 0.2,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 1,
                   options: .curveEaseOut,
                   animations: animations,
                   completion: completion)
  }
  
  
  @IBAction func backButtonTouched() {
    let (animations, completion) = backButtonTouchedAnimations()
    IQKeyboardManager.sharedManager().resignFirstResponder()
    view.layoutIfNeeded()
    UIView.animateKeyframes(withDuration: 0.27,
                            delay: 0,
                            options: UIViewKeyframeAnimationOptions(animationOptions: .curveEaseInOut),
                            animations: animations,
                            completion: completion)
  }
  
  
  @IBAction func settingsButtonTouched() {
    let animations = settingsButtonTouchedAnimations()
    self.settingsView.isUserInteractionEnabled = true
    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.65,
                   delay: 0,
                   usingSpringWithDamping: 0.75,
                   initialSpringVelocity: 1,
                   options: [.allowUserInteraction, .curveEaseOut],
                   animations: animations,
                   completion: nil)
  }
  
  @IBAction func settingsViewPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began, .changed:
      let translation = gestureRecognizer.translation(in: settingsView)
      guard settingsMenuViewTrailingConstraint.constant + translation.x > settingsMenuViewHiddenTrailingConstant else {
        settingsMenuViewTrailingConstraint.constant = settingsMenuViewHiddenTrailingConstant
        slideViewTrailingConstraint.constant = slideViewHiddenTrailingConstant
        
        return
      }
      
      guard settingsMenuViewTrailingConstraint.constant + translation.x <= settingsMenuViewVisibleTrailingConstant else {
        settingsMenuViewTrailingConstraint.constant = settingsMenuViewVisibleTrailingConstant
        
        if slideViewTrailingConstraint.constant > slideViewHiddenTrailingConstant {
          slideViewTrailingConstraint.constant = slideViewVisibleTrailingConstant
        }
        
        return
      }
      
      settingsMenuViewTrailingConstraint.constant += translation.x
      
      if slideViewTrailingConstraint.constant > slideViewHiddenTrailingConstant {
        slideViewTrailingConstraint.constant += translation.x
      }
      
      gestureRecognizer.setTranslation(CGPoint.zero, in: settingsView)
      
    case .ended:
      if settingsMenuViewTrailingConstraint.constant <= settingsMenuView.frame.width * 0.65 {
        let (animations, completion) = settingsViewSlideLeftAnimations()
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.13, delay: 0, options: .curveLinear, animations: animations,completion: completion)
      } else if settingsMenuViewTrailingConstraint.constant < settingsMenuViewVisibleTrailingConstant {
        let animations = settingsViewSlideRightAnimations()
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: animations, completion: nil)
      }
      
    default:
      return
    }
  }
  
  @IBAction func profileButtonTouched() {
    let animations = profileButtonTouchedAnimations()
    slideView.layer.sublayers?.last?.opacity = 0
    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 1,
                   options: [.allowUserInteraction, .curveEaseOut],
                   animations: animations, completion: nil)
  }
  
  @IBAction func profileBackButtonTouched() {
    let (animations, completion) = profileBackButtonTouchedAnimations()
    view.layoutIfNeeded()
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: animations, completion: completion)
  }
}

// MARK: - Animation configurations
private extension HomeViewController {
  func whereToButtonTouchedAnimations() -> (() -> Void, () -> Void, (Bool) -> Void, (Bool) -> Void) {
    let upperViewExpansion = {
      self.lightShadow(self.upperView)
      self.upperViewTopConstraint.constant = self.upperViewVisibleTopConstant
      self.upperViewWidthConstraint.constant = self.upperViewVisibleWidthConstant
      self.upperViewHeightConstraint.constant = self.upperViewVisibleHeightConstant
      self.view.layoutIfNeeded()
    }
    
    let destinationTableViewSlideUp = {
      self.destinationTableViewTopConstraint.constant = self.destinationTableViewVisibleTopConstant
      self.view.layoutIfNeeded()
    }
    
    let settingsButtonFadeOutSlideUp = {
      self.settingsButton.alpha = 0
      self.settingsButtonBottomConstraint.constant = self.settingsButtonHiddenBottomConstant
      self.view.layoutIfNeeded()
    }
    
    let whereToButtonFadeOut = {
      self.whereToButton.alpha = 0
      self.view.layoutIfNeeded()
    }
    
    let destinationTableViewBlurViewFadeOut = {
      self.destinationTableViewBlurView.effect = nil
      self.view.layoutIfNeeded()
    }
    
    let backButtonFadeInSlideRight = {
      self.backButton.alpha = 1
      self.backButtonTrailingConstraint.constant = self.backButtonVisibleTrailingConstant
      self.view.layoutIfNeeded()
    }
    
    let keyframeAnimations = {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6, animations: upperViewExpansion)
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6, animations: destinationTableViewSlideUp)
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4, animations: settingsButtonFadeOutSlideUp)
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: whereToButtonFadeOut)
      UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: destinationTableViewBlurViewFadeOut)
      UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3, animations: backButtonFadeInSlideRight)
    }
    
    let animations = {
      self.fieldStackView.alpha = 1
      self.fieldStackViewLeadingConstraint.constant = self.fieldStackViewVisibleLeadingConstant
      self.view.layoutIfNeeded()
    }
    
    let keyframeCompletion: (Bool) -> Void = { success in
      if success {
        self.whereToButton.isEnabled = false
      }
    }
    
    let completion: (Bool) -> Void = { success in
      if success {
        self.destinationField.becomeFirstResponder()
      }
    }
    
    return (keyframeAnimations, animations, keyframeCompletion, completion)
  }
  
  func backButtonTouchedAnimations() -> (() -> Void, (Bool) -> Void) {
    let fieldStackViewFadeOutSlideRight = {
      self.fieldStackView.alpha = 0
      self.fieldStackViewLeadingConstraint.constant = self.fieldStackViewHiddenLeadingConstant
      self.view.layoutIfNeeded()
    }
    
    let destinationTableViewBlurViewFadeIn = {
      self.destinationTableViewBlurView.effect = UIBlurEffect(style: .extraLight)
      self.view.layoutIfNeeded()
    }
    
    let backButtonFadeOutSlideLeft = {
      self.backButton.alpha = 0
      self.backButtonTrailingConstraint.constant = self.backButtonHiddenTrailingConstant
      self.view.layoutIfNeeded()
    }
    
    let destinationTableViewSlideDown = {
      self.destinationTableViewTopConstraint.constant = self.destinationTableViewHiddenTopConstant
      self.view.layoutIfNeeded()
    }
    
    let upperViewCompression = {
      self.boldShadow(self.upperView)
      self.upperViewTopConstraint.constant = self.upperViewHiddenTopConstant
      self.upperViewWidthConstraint.constant = self.upperViewHiddenWidthConstant
      self.upperViewHeightConstraint.constant = self.upperViewHiddenHeightConstant
      self.view.layoutIfNeeded()
    }
    
    let settingsButtonFadeInSlideDown = {
      self.settingsButton.alpha = 1
      self.settingsButtonBottomConstraint.constant = self.settingsButtonVisibleBottomConstant
      self.view.layoutIfNeeded()
    }
    
    let whereToButtonFadeIn = {
      self.whereToButton.alpha = 1
      self.view.layoutIfNeeded()
    }
    
    let animations = {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: fieldStackViewFadeOutSlideRight)
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3, animations: destinationTableViewBlurViewFadeIn)
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2, animations: backButtonFadeOutSlideLeft)
      UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.9, animations: destinationTableViewSlideDown)
      UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7, animations: upperViewCompression)
      UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6, animations: settingsButtonFadeInSlideDown)
      UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: whereToButtonFadeIn)
    }
    
    let completion: (Bool) -> Void = { success in
      if success {
        self.whereToButton.isEnabled = true
      }
    }
    
    return (animations, completion)
  }
  
  func settingsButtonTouchedAnimations() -> () -> Void {
    let animations = {
      self.settingsBlurView.effect = UIBlurEffect(style: .light)
      self.settingsMenuViewTrailingConstraint.constant = self.settingsMenuViewVisibleTrailingConstant
      self.view.layoutIfNeeded()
    }
    
    return animations
  }
  
  func settingsViewSlideLeftAnimations() -> (() -> Void, (Bool) -> Void) {
    let animations = {
      self.settingsBlurView.effect = nil
      self.settingsMenuViewTrailingConstraint.constant = self.settingsMenuViewHiddenTrailingConstant
      
      self.noShadow(self.profileView)
      self.slideViewTrailingConstraint.constant = self.slideViewHiddenTrailingConstant
      
      self.view.layoutIfNeeded()
    }
    
    let completion: (Bool) -> Void = { success in
      if success {
        self.settingsView.isUserInteractionEnabled = false
        self.slideView.layer.sublayers?.last?.opacity = 1
      }
    }
    
    return (animations, completion)
  }

  func settingsViewSlideRightAnimations() -> () -> Void {
    let animations = {
      self.settingsMenuViewTrailingConstraint.constant = self.settingsMenuViewVisibleTrailingConstant
      
      if self.slideViewTrailingConstraint.constant > self.slideViewHiddenTrailingConstant {
        self.slideViewTrailingConstraint.constant = self.slideViewVisibleTrailingConstant
      }
      
      self.view.layoutIfNeeded()
    }
    
    return animations
  }
  
  func profileButtonTouchedAnimations() -> () -> Void {
    let animations = {
      self.settingsBlurView.effect = UIBlurEffect(style: .dark)
      self.slideViewTrailingConstraint.constant = self.slideViewVisibleTrailingConstant
      self.view.layoutIfNeeded()
    }
    
    return animations
  }
  
  func profileBackButtonTouchedAnimations() -> (() -> Void, (Bool) -> Void) {
    let animations = {
      self.settingsBlurView.effect = UIBlurEffect(style: .light)
      self.noShadow(self.profileView)
      self.slideViewTrailingConstraint.constant = self.slideViewHiddenTrailingConstant
      self.view.layoutIfNeeded()
    }
    
    let completion: (Bool) -> Void = { success in
      if success {
        self.slideView.layer.sublayers?.last?.opacity = 1
      }
    }
    
    return (animations, completion)
  }
}

// MARK: - Toggle shadow
private extension HomeViewController {
  func boldShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.2
    view.layer.shadowRadius = 10
    view.layer.shadowOffset = CGSize(width: 0, height: 5)
  }
  
  func lightShadow(_ view: UIView) {
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.09
    view.layer.shadowRadius = 6
    view.layer.shadowOffset = CGSize(width: 0, height: 2)
  }
  
  func noShadow(_ view: UIView) {
    view.layer.shadowOpacity = 0
  }
}

// MARK: View configuration
private extension HomeViewController {
  func configure() {
    configureView()
    configureConstraints()
  }
  
  func configureView() {
    boldShadow(upperView)
    boldShadow(firstRecentDestinationButton)
    boldShadow(secondRecentDestinationButton)
    boldShadow(thirdRecentDestinationButton)
    
    firstRecentDestinationButton.layer.cornerRadius = firstRecentDestinationButton.frame.height / 2
    secondRecentDestinationButton.layer.cornerRadius = secondRecentDestinationButton.frame.height / 2
    thirdRecentDestinationButton.layer.cornerRadius = thirdRecentDestinationButton.frame.height / 2
    
    let bottomBorder = CALayer()
    bottomBorder.backgroundColor = UIColor.white.cgColor
    bottomBorder.frame = CGRect(x: 0, y: userNameLabel.frame.height - 1, width: userNameLabel.frame.width, height: 1)
    userNameLabel.layer.addSublayer(bottomBorder)
    
    pastRoutesButton.layer.cornerRadius = pastRoutesButton.frame.height * 0.5
    reportDelaysButton.layer.cornerRadius = reportDelaysButton.frame.height * 0.5
    profileButton.layer.cornerRadius = profileButton.frame.height * 0.5
    
    settingsBlurView.effect = nil
    
    let bounceLayer = CALayer()
    bounceLayer.backgroundColor = UIColor.black.cgColor
    bounceLayer.frame = CGRect(x: slideView.frame.width - 60, y: 0, width: 60, height: slideView.frame.height)
    slideView.layer.addSublayer(bounceLayer)
    
    let layer = CAShapeLayer()
    layer.bounds = self.profileView.frame
    layer.position = self.profileView.center
    layer.path = UIBezierPath(roundedRect: self.profileView.bounds, byRoundingCorners: [.topRight , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
    profileView.layer.mask = layer
  }
  
  func configureConstraints() {
    storeConstants()
    initializeConstraints()
  }
  
  func storeConstants() {
    settingsButtonVisibleBottomConstant = UIApplication.shared.statusBarFrame.height + settingsButton.frame.height
    settingsButtonHiddenBottomConstant = 0
    
    upperViewVisibleTopConstant = 0
    upperViewHiddenTopConstant = upperViewTopConstraint.constant
    
    upperViewVisibleWidthConstant = 0
    upperViewHiddenWidthConstant = upperViewWidthConstraint.constant
    
    upperViewVisibleHeightConstant = 200
    upperViewHiddenHeightConstant = upperViewHeightConstraint.constant
    
    backButtonVisibleTrailingConstant = backButton.frame.width + 5
    backButtonHiddenTrailingConstant = backButtonTrailingConstraint.constant
    
    fieldStackViewVisibleLeadingConstant = view.frame.width
    fieldStackViewHiddenLeadingConstant = fieldStackViewLeadingConstraint.constant
    
    destinationTableViewVisibleTopConstant = view.frame.height - upperViewVisibleHeightConstant
    destinationTableViewHiddenTopConstant = destinationTableViewTopConstraint.constant
    
    settingsMenuViewVisibleTrailingConstant = settingsMenuView.frame.width
    settingsMenuViewHiddenTrailingConstant = settingsMenuViewTrailingConstraint.constant
    
    slideViewVisibleTrailingConstant = slideView.frame.width
    slideViewHiddenTrailingConstant = slideViewTrailingConstraint.constant
  }
  
  func initializeConstraints() {
    settingsButtonBottomConstraint.constant = settingsButtonVisibleBottomConstant
    fieldStackViewTopConstraint.constant = upperViewVisibleHeightConstant * 0.57
    destinationTableViewHeightConstraint.constant = upperViewVisibleHeightConstant
  }
}
