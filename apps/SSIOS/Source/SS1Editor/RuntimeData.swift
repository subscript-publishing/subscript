//
//  RuntimeData.swift
//  Subscript
//
//  Created by Colbyn Wadman on 3/30/22.
//

import Foundation
import CoreGraphics
import UIKit

extension SS1 {
    enum Placement: String, Codable {
        case foreground
        case background
    }
    enum InkType: String, Codable {
        case regular
        case highlighter
        case filler
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAWING RUNTIME STATE
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fileprivate func defaultPenList() -> Array<SS1.RuntimeDataModel.Pen> {
    typealias ColorMap = SS1.Stroke.Options.ColorMap
    typealias PrimaryColorSchemeMode = SS1.RuntimeDataModel.Pen.PrimaryColorSchemeMode
    let defaulColorList: Array<(SS1.Stroke.Options.ColorMap, PrimaryColorSchemeMode)> = [
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.3306372166, green: 0.3306372166, blue: 0.3306372166, alpha: 0.8210225611), darkUIMode: #colorLiteral(red: 0.8077382445, green: 0.8077382445, blue: 0.8077382445, alpha: 0.8152429959)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.5555444637, blue: 0, alpha: 1), darkUIMode: #colorLiteral(red: 1, green: 0.9087574811, blue: 0, alpha: 1)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.3515071338, green: 1, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.7728719971, blue: 0, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.5448406202, alpha: 1), darkUIMode: #colorLiteral(red: 0, green: 1, blue: 0.5448406202, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.8468232216, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0, green: 1, blue: 0.8468232216, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0.8208826725, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0, green: 0.8208826725, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0.2191386359, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0, green: 0.2191386359, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.2523259827, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.2523259827, green: 0, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.4992633515, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4992633515, green: 0, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0, blue: 0.9402033476, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0, blue: 0.9402033476, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0, blue: 0.5167398384, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0, blue: 0.5167398384, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.2240143539, blue: 0.236947448, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.2240143539, blue: 0.236947448, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.5137268299, blue: 0.1420599709, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.5137268299, blue: 0.1420599709, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.7728719971, blue: 0, alpha: 0.93), darkUIMode: #colorLiteral(red: 1, green: 0.8071567184, blue: 0.1509488961, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.342746343, green: 1, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.433911352, green: 1, blue: 0.1387059745, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.1437019026, green: 1, blue: 0.1875252066, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.1437019026, green: 1, blue: 0.1875252066, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.1624330333, green: 1, blue: 0.6187735389, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.1624330333, green: 1, blue: 0.6187735389, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.2043766505, green: 1, blue: 0.8781289785, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.2043766505, green: 1, blue: 0.8781289785, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.272520325, green: 0.4319392286, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.272520325, green: 0.4319392286, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.4648627396, green: 0.2842639332, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4648627396, green: 0.2842639332, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.6414011498, green: 0.2838573904, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.6414011498, green: 0.2838573904, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.2358020191, blue: 0.954303519, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.2358020191, blue: 0.954303519, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.772871997, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.8864359985, blue: 0.5, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.8440355411, green: 1, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.875283665, green: 1, blue: 0.2003541329, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.3427463431, green: 1, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.6575437492, green: 1, blue: 0.4789587746, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.05117762614, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4948470425, green: 1, blue: 0.5206995717, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.5448406202, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4925926817, green: 1, blue: 0.7690487997, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.8468232216, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4918868374, green: 1, blue: 0.9221688627, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0.8208826724, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.5, green: 0.9104413362, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0.6109374522, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4759099539, green: 0.7960961914, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0.2191386358, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4928677698, green: 0.6040000349, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.2523259828, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.6067544452, green: 0.4740414328, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.4992633514, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.748245313, green: 0.4972313536, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.703415194, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.8473270163, green: 0.485229922, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0, blue: 0.9402033476, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.5, blue: 0.9701016738, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0, blue: 0.5167398383, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.4845291639, blue: 0.7508934804, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0, blue: 0.01666666667, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.7005116638, blue: 0.705503136, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.4332084368, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.832351172, blue: 0.7042143199, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.7728719969, blue: 0, alpha: 1), darkUIMode: #colorLiteral(red: 1, green: 0.933354508, blue: 0.7065729849, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.7476659175, blue: 0, alpha: 1), darkUIMode: #colorLiteral(red: 0.9559898487, green: 1, blue: 0.7178193571, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.3427463431, green: 1, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.8576844253, green: 1, blue: 0.78346933, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.05117762629, alpha: 1), darkUIMode: #colorLiteral(red: 0.7356720687, green: 1, blue: 0.7491997448, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.5448406203, alpha: 1), darkUIMode: #colorLiteral(red: 0.7688084992, green: 1, blue: 0.8947710199, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.8468232215, alpha: 1), darkUIMode: #colorLiteral(red: 0.7630801492, green: 1, blue: 0.9637093805, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.2352792803, green: 0.7024758084, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.7414549348, green: 0.8994097982, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0.2191386357, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.7333147649, green: 0.7917558035, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.2523259827, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.8189585316, green: 0.7578604255, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.703415194, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.8473270163, green: 0.485229922, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.1465652537, blue: 0.5875689865, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.7692172628, blue: 0.8884718971, alpha: 0.9308121501)), PrimaryColorSchemeMode.dark)
    ]
    let thickColorExtraList: Array<(SS1.Stroke.Options.ColorMap, PrimaryColorSchemeMode)> = [
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.5555444637, blue: 0, alpha: 1), darkUIMode: #colorLiteral(red: 1, green: 0.9087574811, blue: 0, alpha: 1)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 1, blue: 0.2643320075, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.342746343, green: 1, blue: 0, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0, green: 0.6109374522, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0, green: 0.6109374522, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.4992633515, green: 0, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.4992633515, green: 0, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 0.6414011498, green: 0.2838573904, blue: 1, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 0.6414011498, green: 0.2838573904, blue: 1, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.2358020191, blue: 0.954303519, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.2358020191, blue: 0.954303519, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
        (ColorMap(lightUIMode: #colorLiteral(red: 1, green: 0.2636250241, blue: 0.6441393101, alpha: 0.9308121501), darkUIMode: #colorLiteral(red: 1, green: 0.2636250241, blue: 0.6441393101, alpha: 0.9308121501)), PrimaryColorSchemeMode.both),
    ]
//    var leftPens: Array<SS1.RuntimeDataModel.Pen> = []
//    var rightPens: Array<SS1.RuntimeDataModel.Pen> = []
    var pens: Array<SS1.RuntimeDataModel.Pen> = []
    for (colorMap, primaryColorSchemeMode) in defaulColorList {
        let pen1 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultExtraThinPenSize
            ),
            layer: SS1.Stroke.Layer.foreground,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        let pen2 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultExtraThinPenSize
            ),
            layer: SS1.Stroke.Layer.background,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        pens.append(contentsOf: [pen1, pen2])
    }
    for (colorMap, primaryColorSchemeMode) in defaulColorList {
        let pen1 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultThinPenSize
            ),
            layer: SS1.Stroke.Layer.foreground,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        let pen2 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultThinPenSize
            ),
            layer: SS1.Stroke.Layer.background,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        pens.append(contentsOf: [pen1, pen2])
    }
    for (colorMap, primaryColorSchemeMode) in defaulColorList {
        let pen1 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultThickPenSize
            ),
            layer: SS1.Stroke.Layer.foreground,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        let pen2 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultThickPenSize
            ),
            layer: SS1.Stroke.Layer.background,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        pens.append(contentsOf: [pen1, pen2])
    }
    for (colorMap, primaryColorSchemeMode) in thickColorExtraList {
        let pen1 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultExtraThickPenSize
            ),
            layer: SS1.Stroke.Layer.foreground,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        let pen2 = SS1.RuntimeDataModel.Pen(
            options: SS1.Stroke.Options(
                color: colorMap,
                size: SS1.RuntimeDataModel.Pen.defaultExtraThickPenSize
            ),
            layer: SS1.Stroke.Layer.background,
            primaryColorSchemeMode: primaryColorSchemeMode
        )
        pens.append(contentsOf: [pen1, pen2])
    }
//    for (colorMap, primaryColorSchemeMode) in defaulColorList {
//        let pen1 = SS1.RuntimeDataModel.Pen(
//            options: SS1.Stroke.Options(
//                color: colorMap,
//                size: SS1.RuntimeDataModel.Pen.defaultThinPenSize,
//                simulatePressure: true
//            ),
//            layer: SS1.Stroke.Layer.foreground,
//            primaryColorSchemeMode: primaryColorSchemeMode
//        )
//        let pen2 = SS1.RuntimeDataModel.Pen(
//            options: SS1.Stroke.Options(
//                color: colorMap,
//                size: SS1.RuntimeDataModel.Pen.defaultThickPenSize,
//                simulatePressure: true
//            ),
//            layer: SS1.Stroke.Layer.foreground,
//            primaryColorSchemeMode: primaryColorSchemeMode
//        )
//        leftPens.append(pen1)
//        rightPens.append(pen2)
//    }
//    return [leftPens, rightPens].flatMap({$0})
    return pens
}

//fileprivate func testPens() -> Array<SS1.RuntimeDataModel.Pen> {
//    var pens: Array<SS1.RuntimeDataModel.Pen> = []
//    let base = SS1.RuntimeDataModel.Pen(
//        options: SS1.Stroke.Options(
//            color: SS1.Stroke.Options.ColorMap(
//                lightUIMode: CodableColor(color: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9361161474)),
//                darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9308121501))
//            ),
//            size: 30,
//            thinning: 0,
//            smoothing: 0.5,
//            streamline: 0.5,
//            easing: SS1.Stroke.Options.Easing.easeInSine,
//            simulatePressure: false,
//            start: SS1.Stroke.Options.StartCap(
//                cap: false,
//                taper: 0.0,
//                easing: SS1.Stroke.Options.Easing.easeInSine
//            ),
//            end: SS1.Stroke.Options.EndCap(
//                cap: false,
//                taper: 0.0,
//                easing: SS1.Stroke.Options.Easing.easeInSine
//            )
//        )
//    )
//    let easings = [
//        SS1.Stroke.Options.Easing.linear,
//        SS1.Stroke.Options.Easing.easeInQuad,
//        SS1.Stroke.Options.Easing.easeOutQuad,
//        SS1.Stroke.Options.Easing.easeInOutQuad,
//        SS1.Stroke.Options.Easing.easeInCubic,
//        SS1.Stroke.Options.Easing.easeOutCubic,
//        SS1.Stroke.Options.Easing.easeInOutCubic,
//        SS1.Stroke.Options.Easing.easeInQuart,
//        SS1.Stroke.Options.Easing.easeOutQuart,
//        SS1.Stroke.Options.Easing.easeInOutQuart,
//        SS1.Stroke.Options.Easing.easeInQuint,
//        SS1.Stroke.Options.Easing.easeOutQuint,
//        SS1.Stroke.Options.Easing.easeInOutQuint,
//        SS1.Stroke.Options.Easing.easeInSine,
//        SS1.Stroke.Options.Easing.easeOutSine,
//        SS1.Stroke.Options.Easing.easeInOutSine,
//        SS1.Stroke.Options.Easing.easeInExpo,
//        SS1.Stroke.Options.Easing.easeOutExpo,
//    ]
//    for e in easings {
//        var base1 = base
//        base1.id = UUID()
//        base1.options.thinning = 0
//        base1.options.streamline = 1
//        base1.options.smoothing = 1
//        base1.options.easing = e
//        base1.options.start.easing = e
//        base1.options.end.easing = e
//        pens.append(base1)
//
//        var base2 = base
//        base2.id = UUID()
//        base2.options.thinning = 0.5
//        base2.options.streamline = 0.5
//        base2.options.smoothing = 0.5
//        base2.options.easing = e
//        base2.options.start.easing = e
//        base2.options.end.easing = e
//        pens.append(base2)
//
//        var base3 = base
//        base3.id = UUID()
//        base3.options.thinning = 0
//        base3.options.streamline = -1
//        base3.options.smoothing = -1
//        base3.options.easing = e
//        base3.options.start.easing = e
//        base3.options.end.easing = e
//        pens.append(base3)
//    }
//    return pens
//}

extension SS1 {
    class RuntimeDataModel: ObservableObject, Codable {
        typealias ColorMap = SS1.Stroke.Options.ColorMap
        typealias PrimaryColorSchemeMode = SS1.RuntimeDataModel.Pen.PrimaryColorSchemeMode
        
        @Published var currentToolType: CurrentToolType = CurrentToolType.pen
//        @Published var pens: Array<Pen> = defaultPenList()
        @Published var pens: Array<Pen> = [
            // DEFAULT THIN PENS
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9361161474)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9308121501))
                    ),
                    size: Pen.defaultThinPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
                    ),
                    size: Pen.defaultThinPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))
                    ),
                    size: Pen.defaultThinPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
                    ),
                    size: Pen.defaultThinPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
                    ),
                    size: Pen.defaultThinPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
                    ),
                    size: Pen.defaultThinPenSize
                )
            ),
            // DEFAULT THICK PENS
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.1522153874, green: 0.1522153874, blue: 0.1522153874, alpha: 0.9361161474)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.9308121501))
                    ),
                    size: Pen.defaultThickPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))
                    ),
                    size: Pen.defaultThickPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))
                    ),
                    size: Pen.defaultThickPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
                    ),
                    size: Pen.defaultThickPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
                    ),
                    size: Pen.defaultThickPenSize
                )
            ),
            Pen(
                options: Stroke.Options(
                    color: ColorMap(
                        lightUIMode: CodableColor(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)),
                        darkUIMode: CodableColor(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
                    ),
                    size: Pen.defaultThickPenSize
                )
            ),
            // OTHER
        ]
        
        @Published var templatePen: Pen = Pen(
            options: SS1.Stroke.Options(),
            active: false,
            layer: SS1.Stroke.Layer.foreground
        )
        @Published var invertPenColors: Bool = false
        enum CodingKeys: CodingKey {
            case pens, templatePen
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try! container.encode(pens, forKey: .pens)
            try! container.encode(templatePen, forKey: .templatePen)
        }
        init() {}
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            pens = try container.decode(Array.self, forKey: .pens)
            templatePen = try container.decode(Pen.self, forKey: .templatePen)
        }
        func save(path: URL) {
            let encoder = PropertyListEncoder()
            let data = try! encoder.encode(self)
            try! data.write(to: path)
        }
        static func load(path: URL) -> Optional<RuntimeDataModel> {
            let decoder = PropertyListDecoder()
            let data = try? Data(contentsOf: path)
            if let data = data {
                return try? decoder.decode(RuntimeDataModel.self, from: data)
            } else {
                return .none
            }
//            return .none
        }
        static func loadDefault() -> RuntimeDataModel {
            let defaultFileName = "SubscriptRuntimeState.data"
            let path = URL
                .getDocumentsDirectory()
                .appendingPathComponent(defaultFileName, isDirectory: false)
            if let data = RuntimeDataModel.load(path: path) {
                return data
            } else {
                if SS1.DEBUG_MODE {
                    print("[load pen failed] init new RuntimeDataModel", path)
                }
                return RuntimeDataModel()
            }
        }
        func saveDefault() {
            let path = URL.getDocumentsDirectory().appendingPathComponent("SubscriptRuntimeState.data", isDirectory: false)
            if SS1.DEBUG_MODE {
                print("save RuntimeDataModel", path)
            }
            self.save(path: path)
        }
        
        func getIndexForPen(id: UUID) -> Int {
            var index: Int! = nil
            for (ix, pen) in self.pens.enumerated() {
                if pen.id == id {
                    index = ix
                }
            }
            assert(index != nil)
            return index!
        }
        
        func penMinMaxValues(defPenMin: CGFloat, defPenMax: CGFloat) -> (CGFloat, CGFloat) {
            var values: Array<CGFloat> = []
            for pen in pens {
                values.append(pen.options.size)
            }
            let min = values.min() ?? defPenMin
            let max = values.max() ?? defPenMax
            return (min, max)
        }
        
        struct Pen: Codable, Identifiable {
            var id: UUID = UUID()
            var options: Stroke.Options = Stroke.Options()
            var active: Bool = false
            var layer: SS1.Stroke.Layer = SS1.Stroke.Layer.foreground
            var primaryColorSchemeMode: PrimaryColorSchemeMode = PrimaryColorSchemeMode.both
            static let defaultExtraThinPenSize: CGFloat = 2.5
            static let defaultThinPenSize: CGFloat = 5
            static let defaultThickPenSize: CGFloat = 10
            static let defaultExtraThickPenSize: CGFloat = 15
            /// This option defines what pens get filtered out based on the current color scheme.
            ///
            /// For instance regarding the toolbar and specifically the pen list therein:
            /// - `PrimaryColorSchemeMode.light` : the toolbar will only display this pen if the active color scheme is set to `ColorScheme.light`
            /// - `PrimaryColorSchemeMode.dark` : the toolbar will only display this pen if the active color scheme is set to `ColorScheme.dark`
            /// - `PrimaryColorSchemeMode.both` : the toolbar will only display this pen regardless of the current color scheme environment.
            ///
            /// The rationale for this setting is to reduce redundant colors for a given color scheme in the
            /// toolbar UI (specially the pen list therein). Notably for dark color schemes which permit for
            /// more color variations -such as pastel colors- that would otherwise be too faint on light
            /// backgrounds and so the color value for light mode may map to a value that is already
            /// defined by another pen, and so this setting was introduced to reduce redundant colors
            /// in the pen list.
            enum PrimaryColorSchemeMode: String, Equatable, Codable {
                case both
                case light
                case dark
            }
        }
        
        enum CurrentToolType {
            case pen
            case selection
            case eraser
            
            var isPen: Bool {
                self == .pen
            }
            var isSelection: Bool {
                self == .selection
            }
            var isEraser: Bool {
                self == .eraser
            }
            var isAnyEditToolType: Bool {
                isSelection || isEraser
            }
        }
    }
}


