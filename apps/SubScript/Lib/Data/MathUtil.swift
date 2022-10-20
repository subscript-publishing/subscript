//
//  MathUtil.swift
//  AcademicML
//
//  Created by Colbyn Wadman on 8/16/22.
//


import Foundation

struct MathUtil {
    @inline(__always)
    static func newLinearScale(domain: (CGFloat, CGFloat), range: (CGFloat, CGFloat)) -> (CGFloat) -> CGFloat {
        return { value in
            let min_domain = domain.0;
            let max_domain = domain.1;
            let min_range = range.0;
            let max_range = range.1;
            return (max_range - min_range) * (value - min_domain) / (max_domain - min_domain) + min_range
        }
    }
}


struct MathUtils {
    @inline(__always)
    static func newLinearScale(domain: (CGFloat, CGFloat), range: (CGFloat, CGFloat)) -> (CGFloat) -> CGFloat {
        return { value in
            let min_domain = domain.0;
            let max_domain = domain.1;
            let min_range = range.0;
            let max_range = range.1;
            return (max_range - min_range) * (value - min_domain) / (max_domain - min_domain) + min_range
        }
    }
    static func threeWayAngle(
        left: CGPoint,
        center: CGPoint,
        right: CGPoint
    ) -> CGFloat {
        let l = atan2(right.y - left.y, right.x - left.x)
        let r = atan2(center.y - left.y, center.x - left.x)
        return l - r
    }
}
