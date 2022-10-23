#![allow(non_snake_case)]

use std::fmt::Debug;
use uuid::Uuid;
use itertools::Itertools;
use serde::{Serializer, Deserializer, Serialize, Deserialize};

type Bool = bool;
type Int = isize;
type Array<T> = Vec<T>;
type CGFloat = f64;

#[derive(Debug, Clone, Copy)]
struct CGPoint {
    x: CGFloat,
    y: CGFloat,
}

impl CGPoint {
    fn new(x: CGFloat, y: CGFloat) -> Self {
        CGPoint{x, y}
    }
}

fn min(x: f64, y: f64) -> f64 {
    if x < y {
        x 
    } else {
        y
    }
}

fn max(x: f64, y: f64) -> f64 {
    if x > y {
        x 
    } else {
        y
    }
}

fn modi(a: isize, n: isize) -> isize {
    // precondition(n > 0, "modulus must be positive")
    let r = a % n;
    if r >= 0 {r} else {r + n}
}


fn stride(from: usize, to: usize, by: usize) -> Vec<usize> {
    assert!(by == 1);
    (0..to).into_iter().collect::<Vec<_>>()
}

fn stride_float(from: f64, to: f64, by: f64) -> Vec<f64> {
    let mut i = from;
    let mut xs = Vec::new();
    while i <= to {
        xs.push(i);
        i += by;
    }
    return xs
}

fn slice<T: Clone>(xs: Array<T>, start: Int, end: Option<Int>) -> Array<T> {
    fn slice_impl<T: Clone>(xs: Array<T>, start: Int, end: Option<Int>) -> Array<T> {
        let mut results: Array<T> = Array::new();
        assert!(end.unwrap_or(0) >= 0);
        for (ix, x) in xs.clone().into_iter().enumerate() {
            let ix = ix as isize;
            if let Some(end) = end {
                if ix >= start && ix < end {
                    results.push(x);
                }
            } else {
                if ix >= start {
                    results.push(x);
                }
            }
        }
        return results
    }
    
    if start < 0 {
        return slice_impl(xs.clone(), modi(start, xs.len() as isize), end)
    }
    return slice_impl(xs, start, end)
}

// acc, curr
fn reduce<T, U>(xs: Array<T>, f: impl Fn(U, T) -> U, start: U) -> U {
    let mut current = start;
    for x in xs {
        current = f(current, x)
    }
    return current
}

fn cbool(x: Option<CGFloat>) -> Bool {
    if x.unwrap_or(0.0) == 0.0 {
        return false
    }
    return true
}

fn cor(x: Option<CGFloat>, y: CGFloat) -> CGFloat {
    if cbool(x) {
        return x.unwrap()
    }
    return y
}





/// Negate a vector.
fn neg(A: CGPoint) -> CGPoint {
    return CGPoint::new(-A.x, -A.y)
}

/// Add vectors.
fn add(A: CGPoint, B: CGPoint) -> CGPoint {
    return CGPoint::new(A.x + B.x, A.y + B.y)
}

/// Subtract vectors.
fn sub(A: CGPoint, B: CGPoint) -> CGPoint {
    return CGPoint::new(A.x - B.x, A.y - B.y)
}

/// Vector multiplication by scalar
fn mul(A: CGPoint, n: CGFloat) -> CGPoint {
    return CGPoint::new(A.x * n, A.y * n)
}

/// Vector division by scalar.
fn div(A: CGPoint, n: CGFloat) -> CGPoint {
    return CGPoint::new(A.x / n, A.y / n)
}

/// Perpendicular rotation of a vector A
fn per(A: CGPoint) -> CGPoint {
    return CGPoint::new(A.y, -A.x)
}

/// Dot product
fn dpr(A: CGPoint, B: CGPoint) -> CGFloat {
    return A.x * B.x + A.y * B.y
}

/// Get whether two vectors are equal.
fn isEqual(A: CGPoint, B: CGPoint) -> Bool {
    return A.x == B.x && A.y == B.y
}

/// Length of the vector
fn len(A: CGPoint) -> CGFloat {
    return hypot(A.x, A.y)
}

/// Length of the vector squared
fn len2(A: CGPoint) -> CGFloat {
    return A.x * A.x + A.y * A.y
}

/// Dist length from A to B squared.
fn dist2(A: CGPoint, B: CGPoint) -> CGFloat {
    return len2(sub(A, B))
}

/// Get normalized / unit vector.
fn uni(A: CGPoint) -> CGPoint {
    return div(A.clone(), len(A.clone()))
}

fn hypot(x: CGFloat, y: CGFloat) -> CGFloat {
    CGFloat::sqrt(x*x + y*y)
}

/// Dist length from A to B
fn dist(A: CGPoint, B: CGPoint) -> CGFloat {
    return hypot(A.y - B.y, A.x - B.x)
}

/// Mean between two vectors or mid vector between two vectors
fn med(A: CGPoint, B: CGPoint) -> CGPoint {
    return mul(add(A, B), 0.5)
}

/// Rotate a vector around another vector by r (radians)
fn rotAround(A: CGPoint, C: CGPoint, r: CGFloat) -> CGPoint {
    let s = f64::sin(r);
    let c = f64::cos(r);
    
    let px = A.x - C.x;
    let py = A.y - C.y;
    
    let nx = px * c - py * s;
    let ny = px * s + py * c;
    
    return CGPoint::new(nx + C.x, ny + C.y)
}

/// Interpolate vector A to B with a scalar t
fn lrp_point(A: CGPoint, B: CGPoint, t: CGFloat) -> CGPoint {
    return add(A.clone(), mul(sub(B, A), t))
}


/// Project a point A in the direction B by a scalar c
fn prj(A: CGPoint, B: CGPoint, c: CGFloat) -> CGPoint {
    return add(A, mul(B, c))
}

#[derive(Debug, Clone)]
struct SamplePoint {
    point: CGPoint,
    pressure: CGFloat,
}

impl SamplePoint {
    fn new(point: CGPoint) -> Self {
        SamplePoint{point, pressure: 0.5}
    }
}

/// Interpolate vector A to B with a scalar t
fn lrp(A: SamplePoint, B: SamplePoint, t: CGFloat) -> SamplePoint {
    let newPoint = add(A.clone().point, mul(sub(B.point, A.clone().point), t));
    return SamplePoint::new(newPoint)
}

/// Add vectors.
fn add_sample_point(A: SamplePoint, B: SamplePoint) -> SamplePoint {
    let newPoint = CGPoint::new(A.point.x + B.point.x, A.point.y + B.point.y);
    return SamplePoint::new(newPoint)
}

impl std::ops::Add for SamplePoint {
    type Output = SamplePoint;
    fn add(self, rhs: SamplePoint) -> SamplePoint {
        add_sample_point(self, rhs)
    }
}


/// The options object for `getStroke` or `getStrokePoints`.
#[derive(Debug, Clone)]
struct GetStrokeOptions {
    /// The base size (diameter) of the stroke.
    size: CGFloat,
    /// The effect of pressure on the stroke's size.
    thinning: CGFloat,
    /// How much to soften the stroke's edges.
    smoothing: CGFloat,
    /// TODO
    streamline: CGFloat,
    /// An easing function to apply to each point's pressure.
    easing: super::pen_style::Easing,
    /// Whether to simulate pressure based on velocity.
    simulatePressure: bool,
    /// Cap, taper and easing for the start of the line.
    start: super::pen_style::StartCap,
    /// Cap, taper and easing for the end of the line.
    end: super::pen_style::EndCap,
    /// Whether to handle the points as a completed stroke.
    last: bool,
}

impl GetStrokeOptions {
    fn new(
        size: CGFloat,
        thinning: CGFloat,
        smoothing: CGFloat,
        streamline: CGFloat,
        easing: super::pen_style::Easing,
        simulatePressure: Bool,
        start: super::pen_style::StartCap,
        end: super::pen_style::EndCap,
    ) -> Self {
        GetStrokeOptions {
            size: size,
            thinning: thinning,
            smoothing: smoothing,
            streamline: streamline,
            easing: easing,
            simulatePressure: simulatePressure,
            start: start,
            end: end,
            last: false,
        }
    }
}


/// The points returned by `getStrokePoints`, and the input for `getStrokeOutlinePoints`.
#[derive(Debug, Clone)]
struct StrokePoint {
    point: CGPoint,
    pressure: CGFloat,
    distance: CGFloat,
    vector: CGPoint,
    runningLength: CGFloat,
}

impl StrokePoint {
    fn new(
        point: CGPoint,
        distance: CGFloat,
        runningLength: CGFloat,
    ) -> Self {
        StrokePoint {
            point: point,
            pressure: 0.5,
            distance: distance,
            vector: CGPoint::new(0.0, 0.0),
            runningLength: runningLength,
        }
    }
}


/// This is the rate of change for simulated pressure. It could be an option.
static RATE_OF_PRESSURE_CHANGE: CGFloat = 0.275;

/// Get an array of points describing a polygon that surrounds the input
/// points. I.e. Get an array of points (as `[x, y]`) representing the
/// outline of a stroke.
fn getStrokeOutlinePoints(inputs: Array<StrokePoint>, options: &GetStrokeOptions) -> Array<CGPoint> {
    let mut points = inputs;
    
    // We can't do anything with an empty array or a stroke with negative size.
    if (points.len() == 0 || options.size <= 0.0) {
        return Vec::new()
    }
    
    // The total length of the line
    let totalLength = points[points.len() - 1].runningLength;
    
    // The minimum allowed distance between points (squared)
    let minDistance = (options.size * options.smoothing) * (options.size * options.smoothing);
    
    // Our collected left and right points
    let mut leftPts: Array<CGPoint> = Vec::new();
    let mut rightPts: Array<CGPoint> = Vec::new();
    
    // Previous pressure (start with average of first five pressures,
    // in order to prevent fat starts for every line. Drawn lines
    // almost always start slow!
    let mut prevPressure: CGFloat = {
        let xs: Array<StrokePoint> = slice(points.clone(), 0, Some(10));
        let f = {
            let options1 = options.clone();
            move |acc: CGFloat, curr: StrokePoint| -> CGFloat{
                let options1 = options1.clone();
                let mut pressure = curr.pressure;
                
                if (options1.simulatePressure) {
                    // Speed of change - how fast should the the pressure changing?
                    let sp = min(1.0, curr.distance / options1.size);
                    // Rate of change - how much of a change is there?
                    let rp = min(1.0, 1.0 - sp);
                    // Accelerate the pressure
                    pressure = min(1.0, acc + (rp - acc) * (sp * RATE_OF_PRESSURE_CHANGE));
                }
                (acc + pressure) / 2.0
            }
        };
        reduce(xs.clone(), f, (points.clone())[0].pressure.clone())
    };
    
    // The current radius
    let mut radius = getStrokeRadius(
        options.clone().size,
        options.clone().thinning,
        points[points.len() - 1].pressure,
        options.clone().easing.to_function()
    );
    
    // The radius of the first saved point
    let mut firstRadius: Option<CGFloat> = None;
    
    // Previous vector
    let mut prevVector = (points[0].vector);
    
    // Previous left and right points
    let mut pl = points[0].point;
    let mut pr = pl;
    
    // Temporary left and right points
    let mut tl = pl;
    let mut tr = pr;
    
    // let short = true
    
    // Find the outline's left and right points
    // Iterating through the points and populate the rightPts and leftPts arrays,
    // skipping the first and last pointsm, which will get caps later on.
    
    //  for (let i = 0; i < points.length; i++)
    
    for i in stride(0, points.len(), 1) {
        // Removes noise from the end of the line
        if (i < points.len() - 1 && totalLength - points[i].runningLength < 3.0) {
            continue
        }
        
        // Calculate the radius
        // If not thinning, the current point's radius will be half the size; or
        // otherwise, the size will be based on the current (real or simulated)
        // pressure.
        if (cbool(Some(options.thinning))) {
            if (options.simulatePressure) {
                // If we're simulating pressure, then do so based on the distance
                // between the current point and the previous point, and the size
                // of the stroke. Otherwise, use the input pressure.
                let sp = min(1.0, points[i].distance / options.size);
                let rp = min(1.0, 1.0 - sp);
                points[i].pressure = min(
                    1.0,
                    prevPressure + (rp - prevPressure) * (sp * RATE_OF_PRESSURE_CHANGE)
                )
            }
            radius = getStrokeRadius(
                options.size,
                options.thinning,
                points[i].pressure,
                options.easing.to_function()
            )
        } else {
            radius = options.size / 2.0
        }
        
        if (!cbool(firstRadius)) {
            firstRadius = Some(radius)
        }
        
        // Apply tapering
        // If the current length is within the taper distance at either the
        // start or the end, calculate the taper strengths. Apply the smaller
        // of the two taper strengths to the radius.
        let ts: CGFloat = {
            if (points[i].runningLength < options.start.taper) {
                options.start.easing.to_function()(points[i].runningLength / options.start.taper)
            } else {
                1.0
            }
        };
        
        let te: CGFloat = {
            if totalLength - points[i].runningLength < options.end.taper {
                options.end.easing.to_function()((totalLength - points[i].runningLength) / options.end.taper)
            } else {
                1.0
            }
        };
        
        radius = max(0.01, radius * min(ts, te));
        
        // Add points to left and right
        
        // Handle the last point
        if (i == points.len() - 1) {
            let offset = mul(per(points[i].vector), radius);
            leftPts.push(sub(points[i].point, offset));
            rightPts.push(add(points[i].point, offset));
            continue
        }
        
        let mut nextVector = points[i + 1].vector;
        
        let mut nextDpr = dpr(points[i].vector, nextVector);
//        let nextAngle = points[i].vector.angle(other: nextVector).radiansToRatio()
        
        // Handle sharp corners
        // Find the difference (dot product) between the current and next vector.
        // If the next vector is at more than a right angle to the current vector,
        // draw a cap at the current point.
//        if (nextAngle < 0.20)
        if (nextDpr < 0.0) {
            // It's a sharp corner. Draw a rounded cap and move on to the next point
            // Considering saving these and drawing them later? So that we can avoid
            // crossing future points.
            
            let offset = mul(per(prevVector), radius);
            
            //      for (let step = 1 / 13, t = 0; t <= 1; t += step)
            let step: CGFloat = 1.0 / 13.0;
            for t in stride_float(0.0, 1.0 + step, step) {
                tl = rotAround(sub(points[i].point, offset), points[i].point, std::f64::consts::PI * t);
                leftPts.push(tl);
                
                tr = rotAround(add(points[i].point, offset), points[i].point, std::f64::consts::PI * -t);
                rightPts.push(tr);
            }
            
            pl = tl;
            pr = tr;
            
            continue
        }
        
        // Add regular points
        // Project points to either side of the current point, using the
        // calculated size as a distance. If a point's distance to the
        // previous point on that side greater than the minimum distance
        // (or if the corner is kinda sharp), add the points to the side's
        // points array.
        
        let offset = mul(per(lrp_point(nextVector, points[i].vector, nextDpr)), radius);
        
        tl = sub(points[i].point, offset);
        
        if (i <= 1 || dist2(pl, tl) > minDistance) {
            leftPts.push(tl);
            pl = tl;
        }
        
        tr = add(points[i].point, offset);
        
        if (i <= 1 || dist2(pr, tr) > minDistance) {
            rightPts.push(tr);
            pr = tr;
        }
        
        // Set letiables for next iteration
        prevPressure = points[i].pressure;
        prevVector = points[i].vector;
    }
    
    // Drawing caps
    //
    // Now that we have our points on either side of the line, we need to
    // draw caps at the start and end. Tapered lines don't have caps, but
    // may have dots for very short lines.
    let firstPoint = points[0].point;
    
    let lastPoint: CGPoint = {
        if points.len() > 1 {
            points[points.len() - 1].point
        } else {
            add(points[0].point, CGPoint::new(1.0, 1.0))
        }
    };
    
    let mut startCap: Array<CGPoint> = Vec::new();
    let mut endCap: Array<CGPoint> = Vec::new();
    
    // Draw a dot for very short or completed strokes
    //
    // If the line is too short to gather left or right points and if the line is
    // not tapered on either side, draw a dot. If the line is tapered, then only
    // draw a dot if the line is both very short and complete. If we draw a dot,
    // we can just return those points.
    
    if (points.len() == 1) {
        if (!(cbool(Some(options.start.taper)) || cbool(Some(options.end.taper))) || options.last) {
            let start = prj(
                firstPoint,
                uni(per(sub(firstPoint, lastPoint))),
                -(cor(firstRadius, radius))
            );
            let mut dotPts: Array<CGPoint> = Vec::new();
            //            for (let step = 1 / 13, t = step; t <= 1; t += step)
            let step: CGFloat = 1.0 / 13.0;
            for t in stride_float(step, 1.0 + step, step) {
                dotPts.push(rotAround(start, firstPoint, std::f64::consts::PI * 2.0 * t));
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
        
        if (cbool(Some(options.start.taper)) || (cbool(Some(options.end.taper)) && points.len() == 1)) {
            // The start point is tapered, noop
        } else if (options.start.cap) {
            // Draw the round cap - add thirteen points rotating the right point around the start point to the left point
            //      for (let step = 1 / 13, t = step; t <= 1; t += step)
            let step: CGFloat = 1.0 / 13.0;
            for t in stride_float(step, 1.1, step) {
                let pt = rotAround(rightPts[0], firstPoint, std::f64::consts::PI * t);
                startCap.push(pt);
            }
        } else {
            // Draw the flat cap - add a point to the left and right of the start point
            let cornersVector = sub(leftPts[0], rightPts[0]);
            let offsetA = mul(cornersVector, 0.5);
            let offsetB = mul(cornersVector, 0.51);

            startCap.extend([
                sub(firstPoint, offsetA),
                sub(firstPoint, offsetB),
                add(firstPoint, offsetB),
                add(firstPoint, offsetA)
            ]);
        }
        
        // Draw an end cap
        //
        // If the line does not have a tapered end, and unless the line has a tapered
        // start and the line is very short, draw a cap around the last point. Finally,
        // remove the last left and right points. Otherwise, add the last point. Note
        // that This cap is a full-turn-and-a-half: this prevents incorrect caps on
        // sharp end turns.
        
        let direction = per(neg(points[points.len() - 1].vector));

        if (cbool(Some(options.end.taper)) || (cbool(Some(options.start.taper)) && points.len() == 1)) {
            // Tapered end - push the last point to the line
            endCap.push(lastPoint);
        } else if (options.end.cap) {
            // Draw the round end cap
            let start = prj(lastPoint, direction, radius);
            //        for (let step = 1 / 29, t = step; t < 1; t += step)

            let step: CGFloat = 1.0 / 29.0;
            for t in stride_float(step, 1.0 + step, step) {
                endCap.push(rotAround(start, lastPoint, std::f64::consts::PI * 3.0 * t));
            }
        } else {
            // Draw the flat end cap
            endCap.extend([
                add(lastPoint, mul(direction, radius)),
                add(lastPoint, mul(direction, radius * 0.99)),
                sub(lastPoint, mul(direction, radius * 0.99)),
                sub(lastPoint, mul(direction, radius))
            ]);
        }
    }
    
    // Return the points in the correct winding order: begin on the left side, then
    // continue around the end cap, then come back along the right side, and finally
    // complete the start cap.
    //    return leftPts.concat(endCap, rightPts.reverse(), startCap)
    leftPts.extend(endCap);
    leftPts.extend(rightPts.clone().into_iter().rev().collect::<Vec<_>>());
    leftPts.extend(startCap);
    return leftPts
}

/// Get an array of points as objects with an adjusted point, pressure, vector, distance, and runningLength.
fn getStrokePoints(points: Array<SamplePoint>, options: &GetStrokeOptions) -> Array<StrokePoint> {
    if points.len() < 3 {
        return Vec::new();
    }
    //  const { streamline = 0.5, size = 16, last: isComplete = false } = options
    
    // If we don't have any points, return an empty array.
    if (points.len() == 0) {return Vec::new()}
    
    // Find the interpolation level between points.
    let t = 0.15 + (1.0 - options.streamline) * 0.85;
    
    // Whatever the input is, make sure that the points are in numberVec::new()Vec::new().
    let mut pts = points;
    //  let pts = Array.isArray(points[0])
    //    ? (points as TVec::new())
    //    : (points as KVec::new()).map(({ x, y, pressure = 0.5 }) => [x, y, pressure])
    
    // Add extra points between the two, to help avoid "dash" lines
    // for strokes with tapered start and ends. Don't mutate the
    // input array!
    if (pts.len() == 2) {
        let last = pts[1].clone();
        pts = slice(pts, 0, Some(-1));
        //        for (let i = 1; i < 5; i++)
        for i in stride_float(1.0, 5.0, 1.0) {
            pts.push(
                lrp(pts[0].clone(), last.clone(), i / 4.0)
            );
        }
    }
    
    // If there's only one point, add another point at a 1pt offset.
    // Don't mutate the input array!
    if (pts.len() == 1) {
        // OLD
        //        pts = [...pts, [...add(pts[0], [1, 1]), ...pts[0].slice(2)]]
        //        let following = [...add(pts[0], [1, 1]), ...pts[0].slice(2)]

        // unimplemented!()
        pts.push({
            let a = &pts[0];
            let b = SamplePoint::new(CGPoint::new(1.0, 1.0));
            add_sample_point(a.clone(), b)
        });
        pts.push({
            let x = &pts[0];
            x.to_owned()
        });
    }
    
    // The strokePoints array will hold the points for the stroke.
    // Start it out with the first point, which needs no adjustment.
    let mut strokePoints: Array<StrokePoint> = vec![
        // StrokePoint(
        //     point: pts[0].point,
        //     pressure: pts[0].pressure >= 0 ? pts[0].pressure : 0.25,
        //     distance: 0,
        //     vector: CGPoint(x: 1, y: 1),
        //     runningLength: 0
        // )
        StrokePoint{
            point: pts[0].point.clone(),
            pressure: if pts[0].pressure >= 0.0 {pts[0].pressure} else {0.25},
            distance: 0.0,
            vector: CGPoint::new(1.0, 1.0),
            runningLength: 0.0
        }
    ];
    
    // A flag to see whether we've already reached out minimum length
    let mut hasReachedMinimumLength = false;
    
    // We use the runningLength to keep track of the total distance
    let mut runningLength: CGFloat = 0.0;
    
    // We're set this to the latest point, so we can use it to calculate
    // the distance and vector of the next point.
    let mut prev = strokePoints.clone()[0].clone();
    
    let max = pts.len() - 1;
    
    // Iterate through all of the points, creating StrokePoints.
    //  for (let i = 1; i < pts.len(); i++)
    for i in stride(1, pts.len(), 1) {
        let point: CGPoint = {
            if options.last && i == max {
                // If we're at the last point, and `options.last` is true,
                // then add the actual input point.
                pts[i].point.clone()
            } else {
                // Otherwise, using the t calculated from the streamline
                // option, interpolate a new point between the previous
                // point the current point.
                lrp_point(prev.clone().point, pts[i].point.clone(), t)
            }
        };
        
        // If the new point is the same as the previous point, skip ahead.
        if (isEqual(prev.clone().point, point.clone())) {continue}
        
        // How far is the new point from the previous point?
        let distance = dist(point.clone(), prev.clone().point);
        
        // Add this distance to the total "running length" of the line.
        runningLength += distance.clone();
        
        // At the start of the line, we wait until the new point is a
        // certain distance away from the original point, to avoid noise
        if (i < max && !hasReachedMinimumLength) {
            if (runningLength < options.size) {continue}
            hasReachedMinimumLength = true;
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
            let mut pressure: CGFloat = {
                if pts[i].pressure >= 0.0 {
                    pts[i].pressure
                } else {
                    0.5
                }
            };
            StrokePoint{
                point: point.clone(),
                pressure: pressure,
                distance: distance,
                vector: uni(sub(prev.clone().point, point.clone())),
                runningLength: runningLength
            }
        };
        
        // Push it to the strokePoints array.
        strokePoints.push(prev.clone());
    }
    
    // Set the vector of the first point to be the same as the second point.
    
    if strokePoints.len() >= 2 {
        strokePoints[0].vector = strokePoints[1].vector.clone();
    }
    
    return strokePoints
}




/// Compute a radius based on the pressure.
fn getStrokeRadius(
    size: CGFloat,
    thinning: CGFloat,
    pressure: CGFloat,
    easing: impl Fn(CGFloat) -> CGFloat,
) -> CGFloat {
    return size * easing(0.5 - thinning * (0.5 - pressure))
}


// extension SS.Stroke {
//     func vectorOutlinePoints() -> Array<CGPoint> {
//         if samples.len() < 3 {
//             return Vec::new()
//         }
//         let points = samples.map({sample in
//             SamplePoint(point: sample.point, pressure: sample.pressure)
//         })
//         let options = GetStrokeOptions(fromStroke: self)
//         let outlinePoints = getStroke(points, options)
//         return outlinePoints
//     }
// }

pub fn vector_outline_points_for_stroke(stroke: &super::StrokeCmd) -> Array<[f64; 2]> {
    vector_outline_points(&stroke.device_input, &stroke.stroke_style)
}


pub fn vector_outline_points(
    sample_points: &super::SamplePoints,
    stroke_style: &super::StrokeStyle
) -> Array<[f64; 2]> {
    if sample_points.0.len() < 3 {
        return Vec::new()
    }
    let points = sample_points.0
        .iter()
        .map(|sample| {
            SamplePoint {
                point: CGPoint { x: sample.point[0], y: sample.point[1] },
                pressure: {
                    if sample.has_force {
                        sample.force
                    } else {
                        0.5
                    }
                },
            }
        })
        .collect::<Vec<_>>();
    let options = GetStrokeOptions {
        size: stroke_style.size,
        thinning: stroke_style.thinning,
        smoothing: stroke_style.smoothing,
        streamline: stroke_style.streamline,
        easing: stroke_style.easing,
        simulatePressure: stroke_style.simulate_pressure,
        start: stroke_style.start.clone(),
        end: stroke_style.end.clone(),
        last: false,
    };
    getStrokeOutlinePoints(getStrokePoints(points, &options), &options)
        .into_iter()
        .map(|point| {
            [point.x, point.y]
        })
        .collect::<Vec<_>>()
}

