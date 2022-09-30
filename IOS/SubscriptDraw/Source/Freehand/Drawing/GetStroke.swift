//
//  Freehand.swift
//  Superscript
//
//  Created by Colbyn Wadman on 11/11/21.
//

import Foundation
import CoreGraphics

/// Ensures correct modulo function.
fileprivate func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

fileprivate func slice<T>(_ xs: Array<T>, _ start: Int, _ end: Int? = .none) -> Array<T> {
    func sliceImpl<T>(_ xs: Array<T>, _ start: Int, _ end: Int? = .none) -> Array<T> {
        var results: Array<T> = []
        assert(end ?? 0 >= 0)
        for (ix, x) in xs.enumerated() {
            if let end = end {
                if ix >= start && ix < end {
                    results.append(x)
                }
            } else {
                if ix >= start {
                    results.append(x)
                }
            }
        }
        return results
    }
    
    if start < 0 {
        return sliceImpl(xs, mod(start, xs.count), end)
    }
    return sliceImpl(xs, start, end)
}

// acc, curr
fileprivate func reduce<T, U>(_ xs: Array<T>, _ f: (U, T) -> U, _ start: U) -> U {
    var current = start
    for x in xs {
        current = f(current, x)
    }
    return current
}

fileprivate func cbool(_ x: CGFloat?) -> Bool {
    if x == 0 || x == .none {
        return false
    }
    return true
}

fileprivate func cor(_ x: CGFloat?, _ y: CGFloat) -> CGFloat {
    if cbool(x) {
        return x!
    }
    return y
}





/// Negate a vector.
fileprivate func neg(_ A: CGPoint) -> CGPoint {
    return CGPoint(x: -A.x, y: -A.y)
}

/// Add vectors.
fileprivate func add(_ A: CGPoint, _ B: CGPoint) -> CGPoint {
    return CGPoint(x: A.x + B.x, y: A.y + B.y)
}

/// Subtract vectors.
fileprivate func sub(_ A: CGPoint, _ B: CGPoint) -> CGPoint {
    return CGPoint(x: A.x - B.x, y: A.y - B.y)
}

/// Vector multiplication by scalar
fileprivate func mul(_ A: CGPoint, _ n: CGFloat) -> CGPoint {
    return CGPoint(x: A.x * n, y: A.y * n)
}

/// Vector division by scalar.
fileprivate func div(_ A: CGPoint, _ n: CGFloat) -> CGPoint {
    return CGPoint(x: A.x / n, y: A.y / n)
}

/// Perpendicular rotation of a vector A
fileprivate func per(_ A: CGPoint) -> CGPoint {
    return CGPoint(x: A.y, y: -A.x)
}

/// Dot product
fileprivate func dpr(_ A: CGPoint, _ B: CGPoint) -> CGFloat {
    return A.x * B.x + A.y * B.y
}

/// Get whether two vectors are equal.
fileprivate func isEqual(_ A: CGPoint, _ B: CGPoint) -> Bool {
    return A.x == B.x && A.y == B.y
}

/// Length of the vector
fileprivate func len(_ A: CGPoint) -> CGFloat {
    return hypot(A.x, A.y)
}

/// Length of the vector squared
fileprivate func len2(_ A: CGPoint) -> CGFloat {
    return A.x * A.x + A.y * A.y
}

/// Dist length from A to B squared.
fileprivate func dist2(_ A: CGPoint, _ B: CGPoint) -> CGFloat {
    return len2(sub(A, B))
}

/// Get normalized / unit vector.
fileprivate func uni(_ A: CGPoint) -> CGPoint {
    return div(A, len(A))
}

/// Dist length from A to B
fileprivate func dist(_ A: CGPoint, _ B: CGPoint) -> CGFloat {
    return hypot(A.y - B.y, A.x - B.x)
}

/// Mean between two vectors or mid vector between two vectors
fileprivate func med(_ A: CGPoint, _ B: CGPoint) -> CGPoint {
    return mul(add(A, B), 0.5)
}

/// Rotate a vector around another vector by r (radians)
fileprivate func rotAround(_ A: CGPoint, _ C: CGPoint, _ r: CGFloat) -> CGPoint {
    let s = sin(r)
    let c = cos(r)
    
    let px = A.x - C.x
    let py = A.y - C.y
    
    let nx = px * c - py * s
    let ny = px * s + py * c
    
    return CGPoint(x: nx + C.x, y: ny + C.y)
}

/// Interpolate vector A to B with a scalar t
fileprivate func lrp(_ A: CGPoint, _ B: CGPoint, _ t: CGFloat) -> CGPoint {
    return add(A, mul(sub(B, A), t))
}


/// Project a point A in the direction B by a scalar c
fileprivate func prj(_ A: CGPoint, _ B: CGPoint, _ c: CGFloat) -> CGPoint {
    return add(A, mul(B, c))
}

fileprivate struct SamplePoint {
    let point: CGPoint
    var pressure: CGFloat = 0.5
}

/// Interpolate vector A to B with a scalar t
fileprivate func lrp(_ A: SamplePoint, _ B: SamplePoint, _ t: CGFloat) -> SamplePoint {
    let newPoint = add(A.point, mul(sub(B.point, A.point), t))
    return SamplePoint(point: newPoint)
}

/// Add vectors.
fileprivate func add(_ A: SamplePoint, _ B: SamplePoint) -> SamplePoint {
    let newPoint = CGPoint(x: A.point.x + B.point.x, y: A.point.y + B.point.y)
    return SamplePoint(point: newPoint)
}


/// The options object for `getStroke` or `getStrokePoints`.
fileprivate struct GetStrokeOptions {
    /// The base size (diameter) of the stroke.
    var size: CGFloat
    /// The effect of pressure on the stroke's size.
    var thinning: CGFloat
    /// How much to soften the stroke's edges.
    var smoothing: CGFloat
    /// TODO
    var streamline: CGFloat
    /// An easing function to apply to each point's pressure.
    var easing: SS.Stroke.Options.Easing
    /// Whether to simulate pressure based on velocity.
    var simulatePressure: Bool
    /// Cap, taper and easing for the start of the line.
    var start: SS.Stroke.Options.StartCap
    /// Cap, taper and easing for the end of the line.
    var end: SS.Stroke.Options.EndCap
    /// Whether to handle the points as a completed stroke.
    let last: Bool = false
    
    init(fromStroke stroke: SS.Stroke) {
        self.size = stroke.options.size
        self.thinning = stroke.options.thinning
        self.smoothing = stroke.options.smoothing
        self.streamline = stroke.options.streamline
        self.easing = stroke.options.easing
        self.simulatePressure = stroke.options.simulatePressure
        self.start = stroke.options.start
        self.end = stroke.options.end
    }
}


/// The points returned by `getStrokePoints`, and the input for `getStrokeOutlinePoints`.
fileprivate struct StrokePoint {
    let point: CGPoint
    var pressure: CGFloat = 0.5
    let distance: CGFloat
    var vector: CGPoint = CGPoint(x: 0, y: 0)
    let runningLength: CGFloat
}



/// Get an array of points describing a polygon that surrounds the input points.
fileprivate func getStroke(_ points: Array<SamplePoint>, _ options: GetStrokeOptions) -> Array<CGPoint> {
    return getStrokeOutlinePoints(getStrokePoints(points, options), options)
}



/// This is the rate of change for simulated pressure. It could be an option.
let RATE_OF_PRESSURE_CHANGE: CGFloat = 0.275

/// Get an array of points (as `[x, y]`) representing the outline of a stroke.
fileprivate func getStrokeOutlinePoints(_ inputs: Array<StrokePoint>, _ options: GetStrokeOptions) -> Array<CGPoint> {
    var points = inputs
    
    // We can't do anything with an empty array or a stroke with negative size.
    if (points.count == 0 || options.size <= 0) {
        return []
    }
    
    // The total length of the line
    let totalLength = points[points.count - 1].runningLength
    
    // The minimum allowed distance between points (squared)
    let minDistance = pow(options.size * options.smoothing, 2)
    
    // Our collected left and right points
    var leftPts: Array<CGPoint> = []
    var rightPts: Array<CGPoint> = []
    
    // Previous pressure (start with average of first five pressures,
    // in order to prevent fat starts for every line. Drawn lines
    // almost always start slow!
    var prevPressure: CGFloat = {
        let xs: Array<StrokePoint> = slice(points, 0, 10)
        let f: (CGFloat, StrokePoint) -> CGFloat = {(acc, curr) in
            var pressure = curr.pressure
            
            if (options.simulatePressure) {
                // Speed of change - how fast should the the pressure changing?
                let sp = min(1, curr.distance / options.size)
                // Rate of change - how much of a change is there?
                let rp = min(1, 1 - sp)
                // Accelerate the pressure
                pressure = min(1, acc + (rp - acc) * (sp * RATE_OF_PRESSURE_CHANGE))
            }
            
            return (acc + pressure) / 2
        }
        return reduce(xs, f, points[0].pressure)
    }()
    
    // The current radius
    var radius = getStrokeRadius(
        size: options.size,
        thinning: options.thinning,
        pressure: points[points.count - 1].pressure,
        easing: options.easing.toFunction()
    )
    
    // The radius of the first saved point
    var firstRadius: CGFloat? = nil
    
    // Previous vector
    var prevVector = points[0].vector
    
    // Previous left and right points
    var pl = points[0].point
    var pr = pl
    
    // Temporary left and right points
    var tl = pl
    var tr = pr
    
    // let short = true
    
    // Find the outline's left and right points
    // Iterating through the points and populate the rightPts and leftPts arrays,
    // skipping the first and last pointsm, which will get caps later on.
    
    //  for (let i = 0; i < points.length; i++)
    
    for i in stride(from: 0, to: points.count, by: 1) {
        // Removes noise from the end of the line
        if (i < points.count - 1 && totalLength - points[i].runningLength < 3) {
            continue
        }
        
        // Calculate the radius
        // If not thinning, the current point's radius will be half the size; or
        // otherwise, the size will be based on the current (real or simulated)
        // pressure.
        if (cbool(options.thinning)) {
            if (options.simulatePressure) {
                // If we're simulating pressure, then do so based on the distance
                // between the current point and the previous point, and the size
                // of the stroke. Otherwise, use the input pressure.
                let sp = min(1, points[i].distance / options.size)
                let rp = min(1, 1 - sp)
                points[i].pressure = min(
                    1,
                    prevPressure + (rp - prevPressure) * (sp * RATE_OF_PRESSURE_CHANGE)
                )
            }
            radius = getStrokeRadius(
                size: options.size,
                thinning: options.thinning,
                pressure: points[i].pressure,
                easing: options.easing.toFunction()
            )
        } else {
            radius = options.size / 2
        }
        
        if (!cbool(firstRadius)) {
            firstRadius = radius
        }
        
        // Apply tapering
        // If the current length is within the taper distance at either the
        // start or the end, calculate the taper strengths. Apply the smaller
        // of the two taper strengths to the radius.
        let ts: CGFloat = {
            if (points[i].runningLength < options.start.taper) {
                return options.start.easing.toFunction()(points[i].runningLength / options.start.taper)
            } else {
                return 1
            }
        }()
        
        let te: CGFloat = {
            if totalLength - points[i].runningLength < options.end.taper {
                return options.end.easing.toFunction()((totalLength - points[i].runningLength) / options.end.taper)
            } else {
                return 1
            }
        }()
        
        radius = max(0.01, radius * min(ts, te))
        
        // Add points to left and right
        
        // Handle the last point
        if (i == points.count - 1) {
            let offset = mul(per(points[i].vector), radius)
            leftPts.append(sub(points[i].point, offset))
            rightPts.append(add(points[i].point, offset))
            continue
        }
        
        let nextVector = points[i + 1].vector
        
        let nextDpr = dpr(points[i].vector, nextVector)
//        let nextAngle = points[i].vector.angle(other: nextVector).radiansToRatio()
        
        // Handle sharp corners
        // Find the difference (dot product) between the current and next vector.
        // If the next vector is at more than a right angle to the current vector,
        // draw a cap at the current point.
//        if (nextAngle < 0.20)
        if (nextDpr < 0)
        {
            // It's a sharp corner. Draw a rounded cap and move on to the next point
            // Considering saving these and drawing them later? So that we can avoid
            // crossing future points.
            
            let offset = mul(per(prevVector), radius)
            
            //      for (let step = 1 / 13, t = 0; t <= 1; t += step)
            let step: CGFloat = 1 / 13
            for t in stride(from: CGFloat(0.0), to: CGFloat(1 + step), by: step) {
                tl = rotAround(sub(points[i].point, offset), points[i].point, CGFloat.pi * t)
                leftPts.append(tl)
                
                tr = rotAround(add(points[i].point, offset), points[i].point, CGFloat.pi * -t)
                rightPts.append(tr)
            }
            
            pl = tl
            pr = tr
            
            continue
        }
        
        // Add regular points
        // Project points to either side of the current point, using the
        // calculated size as a distance. If a point's distance to the
        // previous point on that side greater than the minimum distance
        // (or if the corner is kinda sharp), add the points to the side's
        // points array.
        
        let offset = mul(per(lrp(nextVector, points[i].vector, nextDpr)), radius)
        
        tl = sub(points[i].point, offset)
        
        if (i <= 1 || dist2(pl, tl) > minDistance) {
            leftPts.append(tl)
            pl = tl
        }
        
        tr = add(points[i].point, offset)
        
        if (i <= 1 || dist2(pr, tr) > minDistance) {
            rightPts.append(tr)
            pr = tr
        }
        
        // Set variables for next iteration
        prevPressure = points[i].pressure
        prevVector = points[i].vector
    }
    
    // Drawing caps
    //
    // Now that we have our points on either side of the line, we need to
    // draw caps at the start and end. Tapered lines don't have caps, but
    // may have dots for very short lines.
    let firstPoint = points[0].point
    
    let lastPoint: CGPoint = {
        if points.count > 1 {
            return points[points.count - 1].point
        } else {
            return add(points[0].point, CGPoint(x: 1, y: 1))
        }
    }()
    
    var startCap: Array<CGPoint> = []
    var endCap: Array<CGPoint> = []
    
    // Draw a dot for very short or completed strokes
    //
    // If the line is too short to gather left or right points and if the line is
    // not tapered on either side, draw a dot. If the line is tapered, then only
    // draw a dot if the line is both very short and complete. If we draw a dot,
    // we can just return those points.
    
    if (points.count == 1) {
        if (!(cbool(options.start.taper) || cbool(options.end.taper)) || options.last) {
            let start = prj(
                firstPoint,
                uni(per(sub(firstPoint, lastPoint))),
                -(cor(firstRadius, radius))
            )
            var dotPts: Array<CGPoint> = []
            //            for (let step = 1 / 13, t = step; t <= 1; t += step)
            let step: CGFloat = 1 / 13
            for t in stride(from: step, to: CGFloat(1 + step), by: step)
            {
                dotPts.append(rotAround(start, firstPoint, CGFloat.pi * 2 * t))
            }
            return dotPts
        }
    } else {
        // Draw a start cap
        //
        // Unless the line has a tapered start, or unless the line has a tapered end
        // and the line is very short, draw a start cap around the first point. Use
        // the distance between the second left and right point for the cap's radius.
        // Finally remove the first left and right points. :psyduck:
        
        if (cbool(options.start.taper) || (cbool(options.end.taper) && points.count == 1)) {
            // The start point is tapered, noop
        } else if (options.start.cap) {
            // Draw the round cap - add thirteen points rotating the right point around the start point to the left point
            //      for (let step = 1 / 13, t = step; t <= 1; t += step)
            let step: CGFloat = 1 / 13
            for t in stride(from: CGFloat(step), to: CGFloat(1.1), by: CGFloat(step)) {
                let pt = rotAround(rightPts[0], firstPoint, CGFloat.pi * t)
                startCap.append(pt)
            }
        } else {
            // Draw the flat cap - add a point to the left and right of the start point
            let cornersVector = sub(leftPts[0], rightPts[0])
            let offsetA = mul(cornersVector, 0.5)
            let offsetB = mul(cornersVector, 0.51)

            startCap.append(contentsOf: [
                sub(firstPoint, offsetA),
                sub(firstPoint, offsetB),
                add(firstPoint, offsetB),
                add(firstPoint, offsetA)
            ])
        }
        
        // Draw an end cap
        //
        // If the line does not have a tapered end, and unless the line has a tapered
        // start and the line is very short, draw a cap around the last point. Finally,
        // remove the last left and right points. Otherwise, add the last point. Note
        // that This cap is a full-turn-and-a-half: this prevents incorrect caps on
        // sharp end turns.
        
        let direction = per(neg(points[points.count - 1].vector))

        if (cbool(options.end.taper) || (cbool(options.start.taper) && points.count == 1)) {
            // Tapered end - push the last point to the line
            endCap.append(lastPoint)
        } else if (options.end.cap) {
            // Draw the round end cap
            let start = prj(lastPoint, direction, radius)
            //        for (let step = 1 / 29, t = step; t < 1; t += step)

            let step: CGFloat = 1 / 29
            for t in stride(from: CGFloat(step), to: CGFloat(1 + step), by: CGFloat(step))
            {
                endCap.append(rotAround(start, lastPoint, CGFloat.pi * 3 * t))
            }
        } else {
            // Draw the flat end cap
            endCap.append(contentsOf: [
                add(lastPoint, mul(direction, radius)),
                add(lastPoint, mul(direction, radius * 0.99)),
                sub(lastPoint, mul(direction, radius * 0.99)),
                sub(lastPoint, mul(direction, radius))
            ])
        }
    }
    
    // Return the points in the correct winding order: begin on the left side, then
    // continue around the end cap, then come back along the right side, and finally
    // complete the start cap.
    //    return leftPts.concat(endCap, rightPts.reverse(), startCap)
    leftPts.append(contentsOf: endCap)
    leftPts.append(contentsOf: rightPts.reversed())
    leftPts.append(contentsOf: startCap)
    return leftPts
}

/// Get an array of points as objects with an adjusted point, pressure, vector, distance, and runningLength.
fileprivate func getStrokePoints(_ points: Array<SamplePoint>, _ options: GetStrokeOptions) -> Array<StrokePoint> {
    if points.count < 3 {
        return []
    }
    //  const { streamline = 0.5, size = 16, last: isComplete = false } = options
    
    // If we don't have any points, return an empty array.
    if (points.count == 0) {return []}
    
    // Find the interpolation level between points.
    let t = 0.15 + (1 - options.streamline) * 0.85
    
    // Whatever the input is, make sure that the points are in number[][].
    var pts = points
    //  let pts = Array.isArray(points[0])
    //    ? (points as T[])
    //    : (points as K[]).map(({ x, y, pressure = 0.5 }) => [x, y, pressure])
    
    // Add extra points between the two, to help avoid "dash" lines
    // for strokes with tapered start and ends. Don't mutate the
    // input array!
    if (pts.count == 2) {
        let last = pts[1]
        pts = slice(pts, 0, -1)
        //        for (let i = 1; i < 5; i++)
        for i in stride(from: CGFloat(1), to: CGFloat(5), by: CGFloat(1)) {
            pts.append(
                lrp(pts[0], last, i / 4)
            )
        }
    }
    
    // If there's only one point, add another point at a 1pt offset.
    // Don't mutate the input array!
    if (pts.count == 1) {
        //        pts = [...pts, [...add(pts[0], [1, 1]), ...pts[0].slice(2)]]
        //        let following = [...add(pts[0], [1, 1]), ...pts[0].slice(2)]
        pts.append(add(pts[0], SamplePoint(point: CGPoint(x: 1, y: 1))))
        pts.append(pts[0])
    }
    
    // The strokePoints array will hold the points for the stroke.
    // Start it out with the first point, which needs no adjustment.
    var strokePoints: Array<StrokePoint> = [
        StrokePoint(
            point: pts[0].point,
            pressure: pts[0].pressure >= 0 ? pts[0].pressure : 0.25,
            distance: 0,
            vector: CGPoint(x: 1, y: 1),
            runningLength: 0
        )
    ]
    
    // A flag to see whether we've already reached out minimum length
    var hasReachedMinimumLength = false
    
    // We use the runningLength to keep track of the total distance
    var runningLength: CGFloat = 0
    
    // We're set this to the latest point, so we can use it to calculate
    // the distance and vector of the next point.
    var prev = strokePoints[0]
    
    let max = pts.count - 1
    
    // Iterate through all of the points, creating StrokePoints.
    //  for (let i = 1; i < pts.count; i++)
    for i in stride(from: 1, to: pts.count, by: 1) {
        let point: CGPoint = {
            if options.last && i == max {
                // If we're at the last point, and `options.last` is true,
                // then add the actual input point.
                return pts[i].point
            } else {
                // Otherwise, using the t calculated from the streamline
                // option, interpolate a new point between the previous
                // point the current point.
                return lrp(prev.point, pts[i].point, t)
            }
        }()
        
        // If the new point is the same as the previous point, skip ahead.
        if (isEqual(prev.point, point)) {continue}
        
        // How far is the new point from the previous point?
        let distance = dist(point, prev.point)
        
        // Add this distance to the total "running length" of the line.
        runningLength += CGFloat(distance)
        
        // At the start of the line, we wait until the new point is a
        // certain distance away from the original point, to avoid noise
        if (i < max && !hasReachedMinimumLength) {
            if (runningLength < options.size) {continue}
            hasReachedMinimumLength = true
            // TODO: Backfill the missing points so that tapering works correctly.
        }
        
        
        // Create a new strokepoint (it will be the new "previous" one).
        //    prev = {
        //      // The adjusted point
        //      point,
        //      // The input pressure (or .5 if not specified)
        //      pressure: pts[i][2] >= 0 ? pts[i][2] : 0.5,
        //      // The vector from the current point to the previous point
        //      vector: uni(sub(prev.point, point)),
        //      // The distance between the current point and the previous point
        //      distance,
        //      // The total distance so far
        //      runningLength,
        //    }
        prev = {
            let pressure: CGFloat
            if pts[i].pressure >= 0 {
                pressure = pts[i].pressure
            } else {
                pressure = 0.5
            }
            return StrokePoint(
                point: point,
                pressure: pressure,
                distance: distance,
                vector: uni(sub(prev.point, point)),
                runningLength: runningLength
            )
        }()
        
        // Push it to the strokePoints array.
        strokePoints.append(prev)
    }
    
    // Set the vector of the first point to be the same as the second point.
    
    if strokePoints.count >= 2 {
        strokePoints[0].vector = strokePoints[1].vector
    }
    
    return strokePoints
}




/// Compute a radius based on the pressure.
fileprivate func getStrokeRadius(
    size: CGFloat,
    thinning: CGFloat,
    pressure: CGFloat,
    easing: (CGFloat) -> CGFloat = {x in x}
) -> CGFloat {
    return size * easing(0.5 - thinning * (0.5 - pressure))
}


extension SS.Stroke {
    func vectorOutlinePoints() -> Array<CGPoint> {
        if samples.count < 3 {
            return []
        }
        let points = samples.map({sample in
            SamplePoint(point: sample.point, pressure: sample.pressure)
        })
        let options = GetStrokeOptions(fromStroke: self)
        let outlinePoints = getStroke(points, options)
        return outlinePoints
    }
}


