#![allow(non_snake_case)]

// import { getStrokeRadius } from './getStrokeRadius'
// import type { StrokeOptions, StrokePoint } from './types'
use crate::data::{graphics::Point};

/// Iterator type for floating-point range iterator
struct FRange {
    val: f32,
    end: f32,
    incr: f32,
}

/// generates an iterator between `x1` and `x2`, step `skip`
/// over floating point numbers.
/// Similar to `linspace` in the **itertools-num** crate
fn range(x1: f32, x2: f32, skip: f32) -> FRange {
    FRange {val: x1, end: x2, incr: skip}
}

impl Iterator for FRange {
    type Item = f32;

    fn next(&mut self) -> Option<Self::Item> {
        let res = self.val;
        if res >= self.end {
            None
        } else {
            self.val += self.incr;
            Some(res)
        }
    }
}


/// The options object for `getStroke` or `getStrokePoints`.
#[derive(Debug, Clone)]
struct GetStrokeOptions {
    /// The base size (diameter) of the stroke.
    size: f32,
    /// The effect of pressure on the stroke's size.
    thinning: f32,
    /// How much to soften the stroke's edges.
    smoothing: f32,
    /// TODO
    streamline: f32,
    /// An easing function to apply to each point's pressure.
    easing: super::stroke_style::Easing,
    /// Whether to simulate pressure based on velocity.
    simulatePressure: bool,
    /// Cap, taper and easing for the start of the line.
    start: super::stroke_style::StrokeCap,
    /// Cap, taper and easing for the end of the line.
    end: super::stroke_style::StrokeCap,
    /// Whether to handle the points as a completed stroke.
    last: bool,
}

impl GetStrokeOptions {
    fn new(
        size: f32,
        thinning: f32,
        smoothing: f32,
        streamline: f32,
        easing: super::stroke_style::Easing,
        simulatePressure: bool,
        start: super::stroke_style::StrokeCap,
        end: super::stroke_style::StrokeCap,
    ) -> Self {
        GetStrokeOptions {
            size,
            thinning,
            smoothing,
            streamline,
            easing,
            simulatePressure,
            start,
            end,
            last: false,
        }
    }
}

fn is_truthy(x: f32) -> bool {
  x.is_finite() && !x.is_sign_negative() && x > 0.0
}


/// The points returned by `getStrokePoints`, and the input for `getStrokeOutlinePoints`.
#[derive(Debug, Clone, Copy)]
struct StrokePoint {
    point: Point,
    pressure: f32,
    distance: f32,
    vector: Point,
    runningLength: f32,
}

impl StrokePoint {
    fn new(
        point: Point,
        distance: f32,
        runningLength: f32,
    ) -> Self {
        StrokePoint {
            point: point,
            pressure: 0.5,
            distance: distance,
            vector: Point::new(0.0, 0.0),
            runningLength: runningLength,
        }
    }
}


struct Math {}

impl Math {
  fn max<T: PartialOrd>(a: T, b: T) -> T {
    if a > b {
      a
    } else {
      b
    }
  }
  fn min<T: PartialOrd>(a: T, b: T) -> T {
    if a < b {
      a
    } else {
      b
    }
  }
  fn hypot(a: f32, b: f32) -> f32 {
    a.hypot(b)
  }
  fn pow(a: f32, b: f32) -> f32 {
    a.powf(b)
  }
}

// import {
//   add,
//   dist2,
//   dpr,
//   lrp,
//   mul,
//   neg,
//   per,
//   prj,
//   rotAround,
//   sub,
//   uni,
// } from './vec'


/**
 * Negate a vector.
 * @param A
 * @internal
 */
fn neg(A: Point) -> Point {
  return [-A.x, -A.y].into()
}

/**
 * Add vectors.
 * @param A
 * @param B
 * @internal
 */
fn add(A: Point, B: Point) -> Point {
  return [A.x + B.x, A.y + B.y].into()
}

/**
 * Subtract vectors.
 * @param A
 * @param B
 * @internal
 */
fn sub(A: Point, B: Point) -> Point {
    return [A.x - B.x, A.y - B.y].into()
}

/**
 * Vector multiplication by scalar
 * @param A
 * @param n
 * @internal
 */
fn mul(A: Point, n: f32) -> Point {
  return [A.x * n, A.y * n].into()
}

/**
 * Vector division by scalar.
 * @param A
 * @param n
 * @internal
 */
fn div(A: Point, n: f32) -> Point {
  return [A.x / n, A.y / n].into()
}

/**
 * Perpendicular rotation of a vector A
 * @param A
 * @internal
 */
fn per(A: Point) -> Point {
  return [A.y, -A.x].into()
}

/**
 * Dot product
 * @param A
 * @param B
 * @internal
 */
fn dpr(A: Point, B: Point) -> f32 {
  return A.x * B.x + A.y * B.y
}

/**
 * Get whether two vectors are equal.
 * @param A
 * @param B
 * @internal
 */
fn isEqual(A: Point, B: Point) -> bool {
  return A.x == B.x && A.y == B.y
}

/**
 * Length of the vector
 * @param A
 * @internal
 */
fn len(A: Point) -> f32 {
    return Math::hypot(A.x, A.y)
}

/**
 * Length of the vector squared
 * @param A
 * @internal
 */
fn len2(A: Point) -> f32 {
  return A.x * A.x + A.y * A.y
}

/**
 * Dist length from A to B squared.
 * @param A
 * @param B
 * @internal
 */
fn dist2(A: Point, B: Point) -> f32 {
  return len2(sub(A, B))
}

/**
 * Get normalized / unit vector.
 * @param A
 * @internal
 */
fn uni(A: Point) -> Point {
    return div(A, len(A))
}

/**
 * Dist length from A to B
 * @param A
 * @param B
 * @internal
 */
fn dist(A: Point, B: Point) -> f32 {
    return Math::hypot(A.y - B.y, A.x - B.x)
}

/**
 * Mean between two vectors or mid vector between two vectors
 * @param A
 * @param B
 * @internal
 */
fn med(A: Point, B: Point) -> Point {
    return mul(add(A, B), 0.5)
}

/**
 * Rotate a vector around another vector by r (radians)
 * @param A vector
 * @param C center
 * @param r rotation in radians
 * @internal
 */
fn rotAround(A: Point, C: Point, r: f32) -> Point {
    let s = f32::sin(r);
    let c = f32::cos(r);

    let px = A.x - C.x;
    let py = A.y - C.y;

    let nx = px * c - py * s;
    let ny = px * s + py * c;

    return [nx + C.x, ny + C.y].into();
}

/**
 * Interpolate vector A to B with a scalar t
 * @param A
 * @param B
 * @param t scalar
 * @internal
 */
fn lrp(A: Point, B: Point, t: f32) -> Point {
    return add(A, mul(sub(B, A), t))
}

/**
 * Project a point A in the direction B by a scalar c
 * @param A
 * @param B
 * @param c
 * @internal
 */
fn prj(A: Point, B: Point, c: f32) -> Point {
    return add(A, mul(B, c))
}

/**
 * Compute a radius based on the pressure.
 * @param size
 * @param thinning
 * @param pressure
 * @param easing
 * @internal
 */
fn getStrokeRadius(
    size: f32,
    thinning: f32,
    pressure: f32,
    easing: fn(f32) -> f32
) -> f32 {
    // fn default_easing(t: f32) -> f32 {t}
    return size * (easing)(0.5 - thinning * (0.5 - pressure))
}

// const { min, PI } = Math

// This is the rate of change for simulated pressure. It could be an option.
const RATE_OF_PRESSURE_CHANGE: f32 = 0.275;

// Browser strokes seem to be off if PI is regular, a tiny offset seems to fix it
// const FIXED_PI: f32 = PI + 0.0001;
const FIXED_PI: f32 = std::f32::consts::PI + 0.0001;

fn getStrokePoints(points: Vec<StrokePoint>, options: GetStrokeOptions) -> Vec<StrokePoint> {
  // const { streamline = 0.5, size = 16, last: isComplete = false } = options;
  let mut streamline = options.streamline;
  let mut size = options.size;
  let mut isComplete = options.last;
  fn lrp(A: Point, B: Point, t: f32) -> StrokePoint {
      let newPoint = add(A.clone(), mul(sub(B, A.clone()), t));
      return StrokePoint {
            point: newPoint,
            pressure: 0.5,
            distance: 0.0,
            vector: Point::new(0.0, 0.0),
            runningLength: 0.0,
        }
  }


  // If we don't have any points, return an empty array.
  if (points.len() == 0) {
    return Vec::new()
  }

  // Find the interpolation level between points.
  let t = 0.15 + (1.0 - streamline) * 0.85;

  // Whatever the input is, make sure that the points are in number[][].
  // let mut pts = Array.isArray(points[0])
  //   ? (points as T[])
  //   : (points as K[]).map(({ x, y, pressure = 0.5 }) => [x, y, pressure]);
  let mut pts = {
    points
  };

  // Add extra points between the two, to help avoid "dash" lines
  // for strokes with tapered start and ends. Don't mutate the
  // input array!
  if (pts.len() == 2) {
    let last = pts[1];
    // pts = pts.slice(0, -1);
    pts = pts[0..pts.len() - 1].to_vec();
    // for (let mut i = 1; i < 5; i++)
    for i in 1..5
    {
      // pts.push(lrp(pts[0].point, last.point, i as f32 / 4.0));
      let x = lrp(pts[0].point, last.point, i as f32 / 4.0);
      unimplemented!();
    }
  }

  // If there's only one point, add another point at a 1pt offset.
  // Don't mutate the input array!
  if (pts.len() == 1) {
    // pts = [...pts, [...add(pts[0], [1, 1]), ...pts[0].slice(2)]];
    // pts = pts;
    pts.push(StrokePoint {
      point: add(pts[0].point, [1.0, 1.0].into()),
      pressure: 0.5,
      distance: 0.0,
      vector: Point { x: 0.0, y: 0.0 },
      runningLength: 0.0,
    });

    eprintln!("Should we add another point here?");

    
    // [...pts, [...add(pts[0], [1, 1]), ...pts[0].slice(2)]];
    // unimplemented!();
  }

  // The strokePoints array will hold the points for the stroke.
  // Start it out with the first point, which needs no adjustment.
  // let strokePoints: Vec<StrokePoint> = [
  //   {
  //     point: [pts[0][0], pts[0][1]],
  //     pressure: pts[0][2] >= 0 ? pts[0][2] : 0.25,
  //     vector: [1, 1],
  //     distance: 0,
  //     runningLength: 0,
  //   },
  // ];
  let mut strokePoints: Vec<StrokePoint> = vec![
    StrokePoint {
      point: pts[0].point,
      pressure: if pts[0].pressure >= 0.0 {pts[0].pressure} else {0.25},
      vector: [1.0, 1.0].into(),
      distance: 0.0,
      runningLength: 0.0,
    }
  ];

  // A flag to see whether we've already reached out minimum length
  let mut hasReachedMinimumLength = false;

  // We use the runningLength to keep track of the total distance
  let mut runningLength = 0.0;

  // We're set this to the latest point, so we can use it to calculate
  // the distance and vector of the next point.
  let mut prev = strokePoints[0];

  let max = pts.len() - 1;

  // Iterate through all of the points, creating StrokePoints.
  // for (let mut i = 1; i < pts.len(); i++)
  for i in 1..pts.len()
  {
    // let point =
    //   isComplete && i == max
    //     ? // If we're at the last point, and `options.last` is true,
    //       // then add the actual input point.
    //       pts[i].slice(0, 2)
    //     : // Otherwise, using the t calculated from the streamline
    //       // option, interpolate a new point between the previous
    //       // point the current point.
    //       lrp(prev.point, pts[i], t);
    let point = {
      if isComplete && i == max {
        // If we're at the last point, and `options.last` is true,
        // then add the actual input point.
        pts[i].point
      } else {
        // Otherwise, using the t calculated from the streamline
        // option, interpolate a new point between the previous
        // point the current point.
        lrp(prev.point, pts[i].point, t).point
      }
    };

    // If the new point is the same as the previous point, skip ahead.
    if (isEqual(prev.point, point)) {continue};

    // How far is the new point from the previous point?
    let distance = dist(point, prev.point);

    // Add this distance to the total "running length" of the line.
    runningLength += distance;

    // At the start of the line, we wait until the new point is a
    // certain distance away from the original point, to avoid noise
    if (i < max && !hasReachedMinimumLength) {
      if (runningLength < size) {continue};
      hasReachedMinimumLength = true;
      // TODO: Backfill the missing points so that tapering works correctly.
    }
    // Create a new strokepoint (it will be the new "previous" one).
    // prev = {
    //   // The adjusted point
    //   point,
    //   // The input pressure (or .5 if not specified)
    //   pressure: pts[i][2] >= 0 ? pts[i][2] : 0.5,
    //   // The vector from the current point to the previous point
    //   vector: uni(sub(prev.point, point)),
    //   // The distance between the current point and the previous point
    //   distance,
    //   // The total distance so far
    //   runningLength,
    // };
    prev = StrokePoint{
      // The adjusted point
      point,
      // The input pressure (or .5 if not specified)
      pressure: {
        if pts[i].pressure >= 0.0 {pts[i].pressure} else {0.5}
      },
      // The vector from the current point to the previous point
      vector: uni(sub(prev.point, point)),
      // The distance between the current point and the previous point
      distance,
      // The total distance so far
      runningLength,
    };

    // Push it to the strokePoints array.
    strokePoints.push(prev);
  }

  // Set the vector of the first point to be the same as the second point.
  
  // strokePoints[0].vector = strokePoints[1]?.vector || [0, 0];
  strokePoints[0].vector = strokePoints[1].vector;

  return strokePoints
}

/**
 * ## getStrokeOutlinePoints
 * @description Get an array of points (as `[x, y]`) representing the outline of a stroke.
 * @param points An array of StrokePoints as returned from `getStrokePoints`.
 * @param options (optional) An object with options.
 * @param options.size	The base size (diameter) of the stroke.
 * @param options.thinning The effect of pressure on the stroke's size.
 * @param options.smoothing	How much to soften the stroke's edges.
 * @param options.easing	An easing function to apply to each point's pressure.
 * @param options.simulatePressure Whether to simulate pressure based on velocity.
 * @param options.start Cap, taper and easing for the start of the line.
 * @param options.end Cap, taper and easing for the end of the line.
 * @param options.last Whether to handle the points as a completed stroke.
 */
fn getStrokeOutlinePoints(
    points: Vec<StrokePoint>,
    options: GetStrokeOptions
) -> Vec<Point> {
//   const {
//     size = 16,
//     smoothing = 0.5,
//     thinning = 0.5,
//     simulatePressure = true,
//     easing = (t) => t,
//     start = {},
//     end = {},
//     last: isComplete = false,
//   } = options

  let size = options.size.clone();
  let smoothing = options.smoothing.clone();
  let thinning = options.thinning.clone();
  let simulatePressure = options.simulatePressure.clone();
  let easing = options.easing.clone();
  let start = options.start.clone();
  let end = options.end.clone();
  let isComplete = options.last.clone();

//   const { cap: capStart = true, easing: taperStartEase = (t) => t * (2 - t) } = start
  let capStart = start.cap;
  let taperStartEase = start.easing;

//   const { cap: capEnd = true, easing: taperEndEase = (t) => --t * t * t + 1 } = end
  let capEnd = end.cap;
  let taperEndEase = end.easing;

  // We can't do anything with an empty array or a stroke with negative size.
  if (points.len() == 0 || size <= 0.0) {
    return Vec::new();
  }

  // The total length of the line
  // const totalLength = points[points.len() - 1].runningLength;
  let totalLength = points[points.len() - 1].runningLength;

//   const taperStart =
//     start.taper == false
//       ? 0
//       : start.taper == true
//       ? Math.max(size, totalLength)
//       : (start.taper as number)
  let taperStart = {
    if is_truthy(start.taper) == false {
      0.0
    } else {
      if is_truthy(start.taper) == true {
        Math::max(size, totalLength)
      } else {
        (start.taper as f32)
      }
    }
  };

  // const taperEnd =
  //   end.taper == false
  //     ? 0
  //     : end.taper == true
  //     ? Math.max(size, totalLength)
  //     : (end.taper as number)
  let taperEnd = {
    if is_truthy(end.taper) == false {0.0} else {
      if is_truthy(end.taper) == true {
        Math::max(size, totalLength)
      } else {
        (end.taper as f32)
      }
    }
  };

  // The minimum allowed distance between points (squared)
  let minDistance = Math::pow(size * smoothing, 2.0);

  // Our collected left and right points
  let mut leftPts: Vec<Point> = Vec::new();
  let mut rightPts: Vec<Point> = Vec::new();

  // Previous pressure (start with average of first five pressures,
  // in order to prevent fat starts for every line. Drawn lines
  // almost always start slow!
  // let mut prevPressure = points.slice(0 .. 10).reduce((acc, curr) => {
  //   let mut pressure = curr.pressure;

  //   if (simulatePressure) {
  //     // Speed of change - how fast should the the pressure changing?
  //     const sp = min(1, curr.distance / size);
  //     // Rate of change - how much of a change is there?
  //     const rp = min(1, 1 - sp);
  //     // Accelerate the pressure
  //     pressure = min(1, acc + (rp - acc) * (sp * RATE_OF_PRESSURE_CHANGE));
  //   }

  //   return (acc + pressure) / 2;
  // }, points[0].pressure);

  let mut prevPressure = points[0 .. Math::min(points.len(), 10)].iter().fold(points[0].pressure, |acc, curr| {
    let mut pressure = curr.pressure;
    if (simulatePressure) {
      // Speed of change - how fast should the the pressure changing?
      let sp = Math::min(1.0, curr.distance / size);
      // Rate of change - how much of a change is there?
      let rp = Math::min(1.0, 1.0 - sp);
      // Accelerate the pressure
      pressure = Math::min(1.0, acc + (rp - acc) * (sp * RATE_OF_PRESSURE_CHANGE));
    }
    return (acc + pressure) / 2.0;
  });

  // The current radius
  let mut radius = getStrokeRadius(
    size,
    thinning,
    points[points.len() - 1].pressure,
    easing.to_function()
  );

  // The radius of the first saved point
  // let mut firstRadius: Option<f32> = None;

  // // Previous vector
  let mut firstRadius: Option<f32> = None;

  // Previous vector
  let mut prevVector = points[0].vector;

  // Previous left and right points
  let mut pl = points[0].point;
  let mut pr = pl;

  // Temporary left and right points
  let mut tl = pl;
  let mut tr = pr;

  // Keep track of whether the previous point is a sharp corner
  // ... so that we don't detect the same corner twice
  let mut isPrevPointSharpCorner = false;

  // let mut short = true

  /*
    Find the outline's left and right points
    Iterating through the points and populate the rightPts and leftPts arrays,
    skipping the first and last pointsm, which will get caps later on.
  */

  for i in 0..points.len() {
    let mut pressure = points[i].pressure;
    // let { point, vector, distance, runningLength } = points[i];
    let point = points[i].point;
    let vector = points[i].vector;
    let distance = points[i].distance;
    let runningLength = points[i].runningLength;

    // Removes noise from the end of the line
    if (i < points.len() - 1 && totalLength - runningLength < 3.0) {
      continue
    }

    /*
      Calculate the radius
      If not thinning, the current point's radius will be half the size; or
      otherwise, the size will be based on the current (real or simulated)
      pressure. 
    */

    if (is_truthy(thinning)) {
      if (simulatePressure) {
        // If we're simulating pressure, then do so based on the distance
        // between the current point and the previous point, and the size
        // of the stroke. Otherwise, use the input pressure.
        let sp = Math::min(1.0, distance / size);
        let rp = Math::min(1.0, 1.0 - sp);
        pressure = Math::min(1.0, prevPressure + (rp - prevPressure) * (sp * RATE_OF_PRESSURE_CHANGE));
      }

      radius = getStrokeRadius(size, thinning, pressure, easing.to_function());
    } else {
      radius = size / 2.0;
    }

    // if (firstRadius == undefined) {
    //   firstRadius = radius;
    // }
    if (firstRadius.is_none()) {
      firstRadius = Some(radius);
    }

    /*
      Apply tapering
      If the current length is within the taper distance at either the
      start or the end, calculate the taper strengths. Apply the smaller 
      of the two taper strengths to the radius.
    */

    // let ts =
    //   runningLength < taperStart
    //     ? taperStartEase(runningLength / taperStart)
    //     : 1;
    let ts = {
      if runningLength < taperStart {(taperStartEase.to_function())(runningLength / taperStart)} else {1.0}
    };

    // let te =
    //   totalLength - runningLength < taperEnd
    //     ? taperEndEase((totalLength - runningLength) / taperEnd)
    //     : 1;
    let te = {
      if totalLength - runningLength < taperEnd {(taperEndEase.to_function())((totalLength - runningLength) / taperEnd)} else {1.0}
    };

    // radius = Math.max(0.01, radius * Math.min(ts, te));
    radius = {
      Math::max(0.01, radius * Math::min(ts, te))
    };

    /* Add points to left and right */

    /*
      Handle sharp corners
      Find the difference (dot product) between the current and next vector.
      If the next vector is at more than a right angle to the current vector,
      draw a cap at the current point.
    */

    // let nextVector = (i < points.len() - 1 ? points[i + 1] : points[i]).vector;
    // let nextDpr = i < points.len() - 1 ? dpr(vector, nextVector) : 1.0;
    // let prevDpr = dpr(vector, prevVector);

    let nextVector = {if i < points.len() - 1 {points[i + 1].clone()} else {points[i].clone()}}.vector;
    let nextDpr = if i < points.len() - 1 {dpr(vector, nextVector)} else {1.0};
    let prevDpr = dpr(vector, prevVector);

    let isPointSharpCorner = prevDpr < 0.0 && !isPrevPointSharpCorner;
    let isNextPointSharpCorner = nextDpr.is_finite() && nextDpr < 0.0;

    if (isPointSharpCorner || isNextPointSharpCorner) {
      // It's a sharp corner. Draw a rounded cap and move on to the next point
      // Considering saving these and drawing them later? So that we can avoid
      // crossing future points.

      let offset = mul(per(prevVector), radius);

      // for (let mut step = 1 / 13, t = 0; t <= 1; t += step)
      for t in range(1.0 / 13.0, 1.0, 1.0 / 13.0)
      {
        tl = rotAround(sub(point, offset), point, FIXED_PI * t);
        leftPts.push(tl);

        tr = rotAround(add(point, offset), point, FIXED_PI * -t);
        rightPts.push(tr);
      }

      pl = tl;
      pr = tr;

      if (isNextPointSharpCorner) {
        isPrevPointSharpCorner = true;
      }
      continue
    }

    isPrevPointSharpCorner = false;

    // Handle the last point
    if (i == points.len() - 1) {
      let offset = mul(per(vector), radius);
      leftPts.push(sub(point, offset));
      rightPts.push(add(point, offset));
      continue
    }

    /* 
      Add regular points
      Project points to either side of the current point, using the
      calculated size as a distance. If a point's distance to the 
      previous point on that side greater than the minimum distance
      (or if the corner is kinda sharp), add the points to the side's
      points array.
    */

    let offset = mul(per(lrp(nextVector, vector, nextDpr)), radius);

    tl = sub(point, offset);

    if (i <= 1 || dist2(pl, tl) > minDistance) {
      leftPts.push(tl);
      pl = tl;
    }

    tr = add(point, offset);

    if (i <= 1 || dist2(pr, tr) > minDistance) {
      rightPts.push(tr);
      pr = tr;
    }

    // Set variables for next iteration
    prevPressure = pressure;
    prevVector = vector;
  }

  /*
    Drawing caps
    
    Now that we have our points on either side of the line, we need to
    draw caps at the start and end. Tapered lines don't have caps, but
    may have dots for very short lines.
  */

  // let firstPoint = points[0].point.slice(0, 2);
  let firstPoint = points[0].point;

  // let lastPoint =
  //   points.len() > 1
  //     ? points[points.len() - 1].point.slice(0, 2)
  //     : add(points[0].point, [1, 1]);
  let lastPoint = {
    if points.len() > 1 {points[points.len() - 1].point} else {add(points[0].point, [1.0, 1.0].into())}
  };

  let mut startCap: Vec<Point> = Vec::new();

  let mut endCap: Vec<Point> = Vec::new();

  /* 
    Draw a dot for very short or completed strokes
    
    If the line is too short to gather left or right points and if the line is
    not tapered on either side, draw a dot. If the line is tapered, then only
    draw a dot if the line is both very short and complete. If we draw a dot,
    we can just return those points.
  */

  if (points.len() == 1) {
    if (!(is_truthy(taperStart) || is_truthy(taperEnd)) || isComplete) {
      // let start = prj(
      //   firstPoint,
      //   uni(per(sub(firstPoint, lastPoint))),
      //   -(firstRadius || radius)
      // );
      let start = prj(
        firstPoint,
        uni(per(sub(firstPoint, lastPoint))),
        -(firstRadius.unwrap_or(radius))
      );


      let mut dotPts: Vec<Point> = Vec::new();
      // for (let mut step = 1 / 13, t = step; t <= 1; t += step)
      for t in range(1.0 / 13.0, 1.0, 1.0 / 13.0)
      {
        dotPts.push(rotAround(start, firstPoint, FIXED_PI * 2.0 * t));
      }
      return dotPts;
    }
  } else {
    /*
    Draw a start cap
    Unless the line has a tapered start, or unless the line has a tapered end
    and the line is very short, draw a start cap around the first point. Use
    the distance between the second left and right point for the cap's radius.
    Finally remove the first left and right points. :psyduck:
  */

    if (is_truthy(taperStart) || (is_truthy(taperEnd) && points.len() == 1)) {
      // The start point is tapered, noop
    } else if (capStart) {
      // Draw the round cap - add thirteen points rotating the right point around the start point to the left point
      // for (let mut step = 1 / 13, t = step; t <= 1; t += step)
      for t in range(1.0 / 13.0, 1.0, 1.0 / 13.0)
      {
        let pt = rotAround(rightPts[0], firstPoint, FIXED_PI * t);
        startCap.push(pt);
      }
    } else {
      // Draw the flat cap - add a point to the left and right of the start point
      let cornersVector = sub(leftPts[0], rightPts[0]);
      let offsetA = mul(cornersVector, 0.5);
      let offsetB = mul(cornersVector, 0.51);

      startCap.extend(&[
        sub(firstPoint, offsetA),
        sub(firstPoint, offsetB),
        add(firstPoint, offsetB),
        add(firstPoint, offsetA)
      ]);
    }

    /*
    Draw an end cap
    If the line does not have a tapered end, and unless the line has a tapered
    start and the line is very short, draw a cap around the last point. Finally,
    remove the last left and right points. Otherwise, add the last point. Note
    that This cap is a full-turn-and-a-half: this prevents incorrect caps on
    sharp end turns.
  */

    let direction = per(neg(points[points.len() - 1].vector));

    if (is_truthy(taperEnd) || (is_truthy(taperStart) && points.len() == 1)) {
      // Tapered end - push the last point to the line
      endCap.push(lastPoint);
    } else if (capEnd) {
      // Draw the round end cap
      let start = prj(lastPoint, direction, radius);
      // for (let mut step = 1 / 29, t = step; t < 1; t += step)
      for t in range(1.0 / 29.0, 1.0, 1.0 / 29.0)
      {
        endCap.push(rotAround(start, lastPoint, FIXED_PI * 3.0 * t));
      }
    } else {
      // Draw the flat end cap

      endCap.extend(&[
        add(lastPoint, mul(direction, radius)),
        add(lastPoint, mul(direction, radius * 0.99)),
        sub(lastPoint, mul(direction, radius * 0.99)),
        sub(lastPoint, mul(direction, radius))
      ]);
    }
  }

  /*
    Return the points in the correct winding order: begin on the left side, then 
    continue around the end cap, then come back along the right side, and finally 
    complete the start cap.
  */

  // return leftPts.concat(endCap, rightPts.reverse(), startCap);
  rightPts.reverse();
  leftPts.extend(endCap);
  leftPts.extend(rightPts);
  leftPts.extend(startCap);
  leftPts
}






impl super::RecordedStroke {
    pub fn vector_outline_points_new(&self, stroke_style: super::StrokeStyle) -> Option<crate::data::drawing::PointVec> {
        if self.sample_points.len() < 3 {
            return None
        }
        let points = self.sample_points
            .iter()
            .map(|sample| {
                StrokePoint {
                  point: Point{x: sample.point.x, y: sample.point.y},
                  pressure: sample.force().unwrap_or(0.5),
                  distance: 0.0,
                  vector: [0.0, 0.0].into(),
                  runningLength: 0.0,
                }
            })
            .collect::<Vec<_>>();
        let options = GetStrokeOptions {
            size: stroke_style.size as f32,
            thinning: stroke_style.thinning as f32,
            smoothing: stroke_style.smoothing as f32,
            streamline: stroke_style.streamline as f32,
            easing: stroke_style.easing,
            simulatePressure: stroke_style.simulate_pressure,
            start: stroke_style.start.clone(),
            end: stroke_style.end.clone(),
            last: false,
        };
        let outline_points = getStrokeOutlinePoints(getStrokePoints(points, options.clone()), options)
            .into_iter()
            .map(|point| {
                super::Point{x: point.x as f32, y: point.y as f32}
            })
            .collect::<Vec<_>>();
        Some(crate::data::drawing::PointVec{points: outline_points})
    }
}

impl<'a> super::PointVecRef<'a> {
    pub fn vector_outline_points_new(&self, stroke_style: super::StrokeStyle) -> Option<crate::data::drawing::PointVec> {
        if self.points.len() < 3 {
            return None
        }
        let points = self.points
            .iter()
            .map(|point| {
                StrokePoint {
                  point: Point{x: point.x, y: point.y},
                  pressure: 0.5,
                  distance: 0.0,
                  vector: [0.0, 0.0].into(),
                  runningLength: 0.0,
                }
            })
            .collect::<Vec<_>>();
        let options = GetStrokeOptions {
            size: stroke_style.size as f32,
            thinning: stroke_style.thinning as f32,
            smoothing: stroke_style.smoothing as f32,
            streamline: stroke_style.streamline as f32,
            easing: stroke_style.easing,
            simulatePressure: stroke_style.simulate_pressure,
            start: stroke_style.start.clone(),
            end: stroke_style.end.clone(),
            last: true,
        };
        let outline_points = getStrokeOutlinePoints(getStrokePoints(points, options.clone()), options)
            .into_iter()
            .map(|point| {
                super::Point{x: point.x as f32, y: point.y as f32}
            })
            .collect::<Vec<_>>();
        Some(crate::data::drawing::PointVec{points: outline_points})
    }
}