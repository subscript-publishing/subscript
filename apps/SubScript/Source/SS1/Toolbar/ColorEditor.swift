//
//  ColorEditor.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/22/22.
//

import SwiftUI



extension SS1 {
    struct ColorEditor: View {
        var body: some View {
            Text("TODO")
        }
    }
    struct HSBAColorSlider: View {
        @Binding var color: UI.ColorType.HSBA
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                ColorPreview(color: $color)
                Text("Hue")
                HueColorSlider(color: $color)
                Text("Saturation")
                SaturationColorSlider(color: $color)
                Text("Brightness")
                BrightnessColorSlider(color: $color)
                Text("Alpha")
                AlphaColorSlider(color: $color)
            }
            .padding(10)
        }
        
        struct ColorPreview: View {
            @Binding var color: UI.ColorType.HSBA
            var body: some View {
                RoundedRectangle(cornerRadius: 3.0)
                    .fill(fillStyle: color.asColor, stroke: Color.white, lineWidth: 2.0)
                    .frame(height: 50)
            }
        }
        
        struct HueColorSlider: View {
            @Binding var color: UI.ColorType.HSBA
            private var sampleColors: Array<Color> {
                var xs: Array<Color> = []
                for i in stride(from: 0.0, through: 1.0, by: 0.05) {
                    let hsba = UI.ColorType.HSBA(
                        hue: i,
                        saturation: self.color.saturation,
                        brightness: self.color.brightness,
                        alpha: self.color.alpha
                    )
                    xs.append(hsba.asColor)
                }
                return xs
            }
            var body: some View {
                ZStack {
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: sampleColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    let bg = RoundedRectangle(cornerRadius: 3.0).fill(gradient)
                    Slider(value: $color.hue, in: 0.0...1.0).background(bg)
                }
            }
        }
        struct SaturationColorSlider: View {
            @Binding var color: UI.ColorType.HSBA
            private var sampleColors: Array<Color> {
                var xs: Array<Color> = []
                for i in stride(from: 0.0, through: 1.0, by: 0.05) {
                    let hsba = UI.ColorType.HSBA(
                        hue: self.color.hue,
                        saturation: i,
                        brightness: self.color.brightness,
                        alpha: self.color.alpha
                    )
                    xs.append(hsba.asColor)
                }
                return xs
            }
            var body: some View {
                ZStack {
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: sampleColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    let bg = RoundedRectangle(cornerRadius: 3.0).fill(gradient)
                    Slider(value: $color.saturation, in: 0.0...1.0).background(bg)
                }
            }
        }
        struct BrightnessColorSlider: View {
            @Binding var color: UI.ColorType.HSBA
            private var sampleColors: Array<Color> {
                var xs: Array<Color> = []
                for i in stride(from: 0.0, through: 1.0, by: 0.05) {
                    let hsba = UI.ColorType.HSBA(
                        hue: self.color.hue,
                        saturation: self.color.saturation,
                        brightness: i,
                        alpha: self.color.alpha
                    )
                    xs.append(hsba.asColor)
                }
                return xs
            }
            var body: some View {
                ZStack {
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: sampleColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    let bg = RoundedRectangle(cornerRadius: 3.0).fill(gradient)
                    Slider(value: $color.brightness, in: 0.0...1.0).background(bg)
                }
            }
        }
        struct AlphaColorSlider: View {
            @Binding var color: UI.ColorType.HSBA
            private var sampleColors: Array<Color> {
                var xs: Array<Color> = []
                for i in stride(from: 0.0, through: 1.0, by: 0.05) {
                    let hsba = UI.ColorType.HSBA(
                        hue: self.color.hue,
                        saturation: self.color.saturation,
                        brightness: self.color.brightness,
                        alpha: i
                    )
                    xs.append(hsba.asColor)
                }
                return xs
            }
            var body: some View {
                ZStack {
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: sampleColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    let bg = RoundedRectangle(cornerRadius: 3.0).fill(gradient)
                    Slider(value: $color.alpha, in: 0.0...1.0).background(bg)
                }
            }
        }
    }
}
