//
//  LinearAlgebra.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/22/22.
//

import Foundation
//import CoreGraphics

extension Double {
    static var tau: Double {Double.pi * 2.0}
    /// A ratio of a circle. So `radiansToRatio(π) = 0.5`, `radiansToRatio(¼𝜏) = 0.25` just as `radiansToRatio(¼2π) = 0.25`.
    func radiansToRatio() -> Double {self/Double.tau}
}

extension CGFloat {
    static var tau: CGFloat {CGFloat.pi * 2.0}
    /// A ratio of a circle. So `radiansToRatio(π) = 0.5`, `radiansToRatio(¼𝜏) = 0.25` just as `radiansToRatio(¼2π) = 0.25`.
    func radiansToRatio() -> CGFloat {self/CGFloat.tau}
}


extension CGPoint {
    var len: CGFloat {
        return sqrt(pow(self.x, 2) + pow(self.y, 2))
    }
    
    var magnitude: CGFloat {
        return self.len
    }
    
    func lengthBetween(other: CGPoint) -> CGFloat {
        return sqrt(pow(other.x - self.x, 2) + pow(other.y - self.y, 2))
    }
    
    func rightTriangle(other: CGPoint) -> CGPoint {
        let dx = other.x - self.x
        let dy = other.y - self.y
        return CGPoint(x: dx, y: dy)
    }
    
    func angle(other: CGPoint) -> CGFloat {
        let num = self.dpr(other: other)
        let den = self.magnitude * other.magnitude
        let theta = acos(num / den)
        return theta
    }
    
    /// Mean between two vectors or mid vector between two vectors
    func mean(other: CGPoint) -> CGPoint {
        return (self + other) / 2
    }
    
    func midpoint(_ other: CGPoint) -> CGPoint {
        self.mean(other: other)
    }
    
    /// Perpendicular rotation
    func per() -> CGPoint {
        return CGPoint(x: self.y, y: -self.x)
    }
    
    /// Negate a vector
    func neg() -> CGPoint {
        return self * -1.0
    }
    
    /// Rotate a vector around another vector by r (radians)
    func rotate(other: CGPoint, r: CGFloat) -> CGPoint {
        let s = sin(r)
        let c = cos(r)
        let px = self.x - other.x
        let py = self.y - other.y
        let nx = px * c - py * s
        let ny = px * s + py * c
        return CGPoint(x: nx + other.x, y: ny + other.y)
    }
    
    /// Interpolate vector A to B with a scalar t
    func lrp(other: CGPoint, t: CGFloat) -> CGPoint {
        return self + ((other - self) * t)
    }
    
    /// Project a point A in the direction B by a scalar c
    func project(other: CGPoint, c: CGFloat) -> CGPoint {
        return self + (other * c)
    }
    
    /// Dot product
    func dpr(other: CGPoint) -> CGFloat {
        (self.x * other.x) + (self.y * other.y)
    }
    
    /// Unit vector
    func unit() -> CGPoint {
        return self / self.len
    }
    
    func addX(value: CGFloat) -> CGPoint {CGPoint(x: self.x + value, y: self.y)}
    func addY(value: CGFloat) -> CGPoint {CGPoint(x: self.x, y: self.y + value)}
    func mulX(value: CGFloat) -> CGPoint {CGPoint(x: self.x * value, y: self.y)}
    func mulY(value: CGFloat) -> CGPoint {CGPoint(x: self.x, y: self.y * value)}
    
    func mapY(_ f: (CGFloat) -> CGFloat) -> CGPoint {
        CGPoint(x: self.x, y: f(self.y))
    }
    
    func atan2() -> CGFloat {
        CoreGraphics.atan2(self.y, self.x)
    }
    func offset(distance: CGFloat, degrees: CGFloat) -> CGPoint {
        let radians = (degrees - 90) * .pi / 180
        let vertical = sin(radians) * distance
        let horizontal = cos(radians) * distance
        let transform = CGAffineTransform(translationX:horizontal, y:vertical)
        return self.applying(transform)
    }
    func offset(distance: CGFloat, radians: CGFloat) -> CGPoint {
        let horizontal = cos(radians) * distance
        let vertical = sin(radians) * distance
        let transform = CGAffineTransform(translationX: horizontal, y: vertical)
        return self.applying(transform)
    }
}

extension CGPoint {
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    static func *(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }
    static func /(left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x / right.x, y: left.y / right.y)
    }

    static func +(left: CGPoint, constant: CGFloat) -> CGPoint {
        return CGPoint(x: left.x + constant, y: left.y + constant)
    }
    static func -(left: CGPoint, constant: CGFloat) -> CGPoint {
        return CGPoint(x: left.x - constant, y: left.y - constant)
    }
    static func *(left: CGPoint, constant: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * constant, y: left.y * constant)
    }
    static func /(left: CGPoint, constant: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / constant, y: left.y / constant)
    }
}





