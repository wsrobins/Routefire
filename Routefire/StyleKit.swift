//
//  StyleKit.swift
//  ProjectName
//
//  Created by William Robinson on 6/10/17.
//  Copyright © 2017 WilliamRobinson. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class StyleKit : NSObject {

    //// Drawing Methods

    public dynamic class func drawRoutefireLogo(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 70, height: 70), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 70, height: 70), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 70, y: resizedFrame.height / 70)


        //// Color Declarations
        let white = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// RoutefireLogoShape Drawing
        let routefireLogoShapePath = UIBezierPath()
        routefireLogoShapePath.move(to: CGPoint(x: 22.4, y: 32.9))
        routefireLogoShapePath.addLine(to: CGPoint(x: 0, y: 32.9))
        routefireLogoShapePath.addLine(to: CGPoint(x: 0, y: 37.1))
        routefireLogoShapePath.addLine(to: CGPoint(x: 22.4, y: 37.1))
        routefireLogoShapePath.addLine(to: CGPoint(x: 22.4, y: 47.6))
        routefireLogoShapePath.addLine(to: CGPoint(x: 47.6, y: 47.6))
        routefireLogoShapePath.addLine(to: CGPoint(x: 47.6, y: 37.1))
        routefireLogoShapePath.addLine(to: CGPoint(x: 70, y: 37.1))
        routefireLogoShapePath.addLine(to: CGPoint(x: 70, y: 32.9))
        routefireLogoShapePath.addLine(to: CGPoint(x: 47.6, y: 32.9))
        routefireLogoShapePath.addLine(to: CGPoint(x: 47.6, y: 22.4))
        routefireLogoShapePath.addLine(to: CGPoint(x: 22.4, y: 22.4))
        routefireLogoShapePath.addLine(to: CGPoint(x: 22.4, y: 32.9))
        routefireLogoShapePath.close()
        routefireLogoShapePath.move(to: CGPoint(x: 0, y: 0))
        routefireLogoShapePath.addLine(to: CGPoint(x: 70, y: 0))
        routefireLogoShapePath.addLine(to: CGPoint(x: 70, y: 70))
        routefireLogoShapePath.addLine(to: CGPoint(x: 0, y: 70))
        routefireLogoShapePath.addLine(to: CGPoint(x: 0, y: 0))
        routefireLogoShapePath.close()
        routefireLogoShapePath.usesEvenOddFillRule = true
        white.setFill()
        routefireLogoShapePath.fill()
        
        context.restoreGState()

    }




    @objc(StyleKitResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
