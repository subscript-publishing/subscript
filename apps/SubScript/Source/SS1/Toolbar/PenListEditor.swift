//
//  ToolbarDocs.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/21/22.
//

import SwiftUI

extension SS1.ToolBarView {
    struct PenSettingsDocs: View {
        @Environment(\.presentationMode) private var presentationMode
        @ViewBuilder private func infoSectionTitle<T: View>(
            center: Bool = false,
            @ViewBuilder title: @escaping () -> T
        ) -> some View {
            HStack(alignment: .center, spacing: 0) {
                title()
                    .textTheme()
                    .font(.system(size: 25, weight: Font.Weight.bold, design: Font.Design.monospaced))
                if !center {
                    Spacer()
                }
            }
        }
        @ViewBuilder private func subSectionTitle<T: View>(
            center: Bool = false,
            @ViewBuilder title: @escaping () -> T
        ) -> some View {
            HStack(alignment: .center, spacing: 0) {
                title()
                    .textTheme()
                    .font(.system(size: 20, weight: Font.Weight.bold, design: Font.Design.monospaced))
                if !center {
                    Spacer()
                }
            }
        }
        @ViewBuilder private func tipDisplay<T: View>(
            @ViewBuilder label: @escaping () -> T
        ) -> some View {
            label()
                .multilineTextAlignment(.leading)
        }
        @ViewBuilder private func infoSection<T: View, U: View, V: View>(
            hidden: Bool = false,
            @ViewBuilder title: @escaping () -> T,
            @ViewBuilder defaultValue: @escaping () -> U,
            @ViewBuilder description: @escaping () -> V
        ) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 0) {
                        title()
                            .textTheme()
                            .font(.system(size: 20, weight: Font.Weight.bold, design: Font.Design.monospaced))
                        if hidden {
                            RoundedLabel(inactive: true, label: {
                                Text("Hidden").foregroundColor(Color.red)
                            })
                        }
                        Spacer()
                    }
                    Spacer()
                    RoundedPill(
                        inactive: true,
                        left: {
                            Text("A good default value")
                        },
                        right: {
                            defaultValue()
                        }
                    )
                }
                VStack(alignment: .leading, spacing: 5) {
                    description()
                        .multilineTextAlignment(.leading)
                }
                .padding(.leading, 20)
            }
        }
        @ViewBuilder private var pickerSettingsInfo: some View {
            RoundedLabel(inactive: true, label: {
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text("Canvas Editor Settings")
                        .textTheme()
                        .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                    Spacer()
                }
            })
            VStack(alignment: .leading, spacing: 10) {
                infoSection(
                    title: {
                        Text("Primary Color Scheme Mode")
                    },
                    defaultValue: {
                        Text("Both")
                    },
                    description: {
                        Text("This option defines what pens get displayed in the toolbar based on the current color scheme. The rationale for this setting is to reduce redundant colors for a given color scheme in the toolbar UI (specially the pen list therein). Notably, dark color schemes permit for more and richer color variations -such as pastel colors- that would otherwise be too faint on light backgrounds, and so the color value for light mode may map to a value that is already defined by another pen, and so this setting was introduced to reduce redundant pens in the toolbar.")

                    }
                )
            }.padding(.leading, 20)
            RoundedLabel(inactive: true, label: {
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Text("Stroke Layering")
                        .textTheme()
                        .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                    Spacer()
                }
            })
            VStack(alignment: .leading, spacing: 10) {
                infoSection(
                    title: {
                        Text("Layer")
                    },
                    defaultValue: {
                        Text("Foreground")
                    },
                    description: {
                        Text("The motivation for this feature is to be able to highlight and underline strokes and have such strokes render ‘underneath’ foreground strokes, it just looks nicer. More generally, each stroke can be rendered to the foreground or background layer depending on the given pen’s ‘Layer’ property. ‘Foreground’ should be the default, when you want to create a highlighter pen, set the property to ‘Background’.")
                    }
                )
            }.padding(.leading, 20)
        }
        @ViewBuilder private var colorSettingsInfo: some View {
            VStack(alignment: .leading, spacing: 10) {
                RoundedLabel(inactive: true, label: {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Stroke Coloring")
                            .textTheme()
                            .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                        Spacer()
                    }
                })
                VStack(alignment: .leading, spacing: 10) {
                    infoSection(
                        title: {
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "sun.min")
                                Text("Light Mode Color")
                                Spacer()
                            }
                        },
                        defaultValue: {
                            Text("Black")
                        },
                        description: {
                            Text("The color of the stroke that will be displayed in light mode.")
                        }
                    )
                    infoSection(
                        title: {
                            HStack(alignment: .center, spacing: 10) {
                                Image(systemName: "moon")
                                Text("Dark Mode Color")
                                Spacer()
                            }
                        },
                        defaultValue: {
                            Text("White")
                        },
                        description: {
                            Text("The color of the stroke that will be displayed in dark mode.")
                        }
                    )
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        RoundedLabel(inactive: true, label: {
                            Text("Note: in the canvas editor, you can click on the sun/moon icon to toggle the color scheme mode (I.e. light/dark mode) to see what your drawing looks like with regards to light and dark mode respectively.")
                                .multilineTextAlignment(.center)
                                .padding(20)
                                .frame(maxWidth: 700)
                        })
                        Spacer()
                    }
                }
                .padding(.leading, 20)
            }
        }
        @ViewBuilder private var sliderSettingsInfo: some View {
            VStack(alignment: .leading, spacing: 10) {
                RoundedLabel(inactive: true, label: {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Stroke Configuration")
                            .textTheme()
                            .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                        Spacer()
                    }
                })
                VStack(alignment: .leading, spacing: 10) {
                    infoSection(
                        title: {
                            Text("Size")
                        },
                        defaultValue: {
                            Text("5")
                        },
                        description: {
                            Text("The size (i.e. diameter) of the stroke.")
                        }
                    )
                    infoSection(
                        title: {
                            Text("Thinning")
                        },
                        defaultValue: {
                            Text("0.5")
                        },
                        description: {
                            Text("The effect of pressure on the stroke's size. The thinning option takes a number between ‘-1’ and ‘1’. At ‘0’, pressure will have no effect on the width of the line. When positive, pressure will have a positive effect on the width of the line; and when negative, pressure will have a negative effect on the width of the line.")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("Easing")
                        },
                        defaultValue: {
                            Text("linear")
                        },
                        description: {
                            Text("An easing function to apply to each point's pressure. For even finer control over the effect of thinning, we can pass an easing function that will adjust the pressure along a curve.")
                        }
                    )
                    infoSection(
                        title: {
                            Text("Smoothing")
                        },
                        defaultValue: {
                            Text("0.5")
                        },
                        description: {
                            Text("How much to soften the stroke's edges. We can also control the density of points along the edges of our polygon using the smoothing option. At zero, the polygon will contain many points, and may appear jagged or bumpy. At higher values, the polygon will contain fewer points and lose definition.")
                        }
                    )
                    infoSection(
                        title: {
                            Text("Streamline")
                        },
                        defaultValue: {
                            Text("0.5")
                        },
                        description: {
                            Text("How much to streamline the stroke. Often the input points recorded for a line are 'noisy', or full of irregularities. To fix this, the perfect-freehand algorithm [what this app uses] applies a “low pass” filter that moves the points closer to a perfect curve. We can control the strength of this filter through the streamline option.")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("Use Real Pressure")
                        },
                        defaultValue: {
                            Text("false")
                        },
                        description: {
                            Text("Whether or not to use pressure metrics reported by the Apple Pencil.")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("Simulate Pressure")
                        },
                        defaultValue: {
                            Text("true")
                        },
                        description: {
                            Text("Whether to simulate pressure based on velocity (this will override pressure metrics reported by the Apple Pencil with a static value).")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("Static Pressure")
                        },
                        defaultValue: {
                            Text("0.5")
                        },
                        description: {
                            Text("A pressure constant to use when relevant.")
                        }
                    )
                }.padding(.leading, 20)
                RoundedLabel(inactive: true, label: {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Stroke Configuration Tips")
                            .textTheme()
                            .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                        Spacer()
                    }
                })
                VStack(alignment: .leading, spacing: 10) {
                    tipDisplay(label: {
                        Text("To create a stroke with a steady line, set the thinning option to '0'.")
                    })
                    tipDisplay(label: {
                        Text("To create a stroke that gets thinner with pressure instead of thicker, use a negative number for the thinning option.")
                    })
                }.padding(.leading, 20)
            }
        }
        @ViewBuilder private var hiddenSettingsInfo: some View {
            VStack(alignment: .leading, spacing: 10) {
                RoundedLabel(inactive: true, label: {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Stroke Start - Tapering Options")
                            .textTheme()
                            .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                        Spacer()
                    }
                })
                VStack(alignment: .leading, spacing: 5) {
                    infoSection(
                        hidden: true,
                        title: {
                            Text("start.cap")
                        },
                        defaultValue: {
                            Text("true")
                        },
                        description: {
                            Text("Whether to draw a cap.")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("start.taper")
                        },
                        defaultValue: {
                            Text("0")
                        },
                        description: {
                            Text("The distance to taper. If set to true, the taper will be the total length of the stroke.")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("start.easing")
                        },
                        defaultValue: {
                            Text("linear")
                        },
                        description: {
                            Text("An easing function for the tapering effect.")
                        }
                    )
                }
                .padding(.leading, 20)
                RoundedLabel(inactive: true, label: {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Text("Stroke End - Tapering Options")
                            .textTheme()
                            .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                        Spacer()
                    }
                })
                VStack(alignment: .leading, spacing: 5) {
                    infoSection(
                        hidden: true,
                        title: {
                            Text("end.cap")
                        },
                        defaultValue: {
                            Text("true")
                        },
                        description: {
                            Text("Whether to draw a cap.")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("end.taper")
                        },
                        defaultValue: {
                            Text("0")
                        },
                        description: {
                            Text("The distance to taper. If set to true, the taper will be the total length of the stroke.")
                        }
                    )
                    infoSection(
                        hidden: true,
                        title: {
                            Text("end.easing")
                        },
                        defaultValue: {
                            Text("linear")
                        },
                        description: {
                            Text("An easing function for the tapering effect.")
                        }
                    )
                }
                .padding(.leading, 20)
            }
        }
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    pickerSettingsInfo
                    colorSettingsInfo
                    sliderSettingsInfo
                    hiddenSettingsInfo
                    RoundedLabel(inactive: true, label: {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Text("Notes")
                                .textTheme()
                                .font(.system(size: 20, weight: Font.Weight.light, design: Font.Design.monospaced))
                            Spacer()
                        }
                    })
                    VStack(alignment: .leading, spacing: 10) {
                        tipDisplay(label: {
                            Text("‘Hidden’ options are options that are yet to be exposed in the settings panel, expect to see such in a newer version of this app.")
                        })
                    }.padding(.leading, 20)
                }
                .padding(10)
            }
        }
    }
}

extension SS1.ToolBarView {
    struct PenSettingsPanel: View {
        var onDelete: (() -> ())? = nil
        var onSave: (() -> ()) = {}
        @ObservedObject var toolbarModel: SS1.ToolBarModel
        @Binding var pen: SS1.Pen
        
        @Environment(\.presentationMode) private var presentationMode
        @ViewBuilder private var layer: some View {
            VStack(alignment: .center, spacing: 10) {
                Text("Layer")
                Picker("Layer", selection: $pen.style.layer) {
                    Text("Foreground").tag(SS1.Pen.PenStyle.Layer.foreground)
                    Text("Background").tag(SS1.Pen.PenStyle.Layer.background)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
        }
        @ViewBuilder private var penUISettings: some View {
            VStack(alignment: .center, spacing: 10) {
                Text("Pen Set")
                Picker("Pen Set", selection: $pen.penSet) {
                    Text("Set 1").tag(SS1.Pen.PenSet.set1)
                    Text("Set 2").tag(SS1.Pen.PenSet.set2)
                    Text("Set 3").tag(SS1.Pen.PenSet.set3)
                    Text("Set 4").tag(SS1.Pen.PenSet.set4)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
        }
        @ViewBuilder private var size: some View {
            VStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text("Size")
                    Spacer()
                    Text(String(format: "%.2fpx", pen.style.size))
                    UI.Btn.Rounded(action: {pen.style.size = SS1.Pen.PenStyle.defaultSize}) {
                        Text("Reset")
                    }
                }
                Slider(
                    value: $pen.style.size,
                    in: SS1.Pen.PenStyle.minSize...SS1.Pen.PenStyle.maxSize,
                    step: 0.5
                )
            }
            .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
        }
        @ViewBuilder private var basicColorPicker: some View {
            HStack(alignment: .center, spacing: 0) {
                Text("Basic Color Picker").padding(10)
            }
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .center) {
                    let bg = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    Rectangle()
                        .foregroundColor(Color(bg))
                    VStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            Image(systemName: "sun.min")
                            Text("Light Mode Color")
                            Spacer()
                        }
                        ColorPicker(
                            "",
                            selection: $pen.style.color.lightUI.asCGColor,
                            supportsOpacity: true
                        )
                            .labelsHidden()
                            .frame(minWidth: 100, minHeight: 50)
                    }
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                    .padding([.top, .bottom], 10)
                }
                Divider()
                ZStack(alignment: .center) {
                    let bg = pen.templateColor.asCGColor
                    Rectangle()
                        .foregroundColor(Color(bg))
                    let fgColor = pen.templateColor.brightness < 0.50 ? Color.white : Color.black
                    VStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            Image(systemName: "paintpalette")
                            Text("Template Color")
                            Spacer()
                        }
                        .foregroundColor(fgColor)
                        ColorPicker(
                            "",
                            selection: $pen.templateColor.asCGColor,
                            supportsOpacity: true
                        )
                            .labelsHidden()
                            .frame(minWidth: 100, minHeight: 50)
                    }
                    .foregroundColor(Color.black)
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                    .padding([.top, .bottom], 10)
                }
                Divider()
                ZStack(alignment: .center) {
                    let bg = #colorLiteral(red: 0.0617946571, green: 0.0617946571, blue: 0.0617946571, alpha: 0.5613338629)
                    Rectangle().foregroundColor(Color(bg))
                    VStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Spacer()
                            Image(systemName: "moon")
                            Text("Dark Mode Color")
                            Spacer()
                        }
                        ColorPicker(
                            "",
                            selection: $pen.style.color.darkUI.asCGColor,
                            supportsOpacity: true
                        )
                            .labelsHidden()
                            .frame(minWidth: 100, minHeight: 50)
                    }
                    .foregroundColor(Color.white)
                    .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                    .padding([.top, .bottom], 10)
                }
            }
        }
        @State private var showOtherColors: Bool = false
        @ViewBuilder private var hsbaColorPicker: some View {
            let lightBg = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            let darkBg = #colorLiteral(red: 0.0617946571, green: 0.0617946571, blue: 0.0617946571, alpha: 0.5613338629)
            VStack(alignment: .center, spacing: 10) {
                VStack(alignment: .center, spacing: 5) {
                    HStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "sun.min")
                                .foregroundColor(Color.black)
                            Text("Light UI Mode")
                                .foregroundColor(Color.black)
                        }
                        .padding(.top, 10)
                        Spacer()
                        UI.Btn.Pill(
                            action: {
                                pen.style.color.lightUI = pen.templateColor
                            },
                            left: {
                                Image(systemName: "paintpalette")
                            },
                            right: {
                                Text("Reset")
                            }
                        )
                            .fgColorMap(lightMode: UI.LL.Color.black, darkMode: UI.LL.Color.black)
                    }
                    .padding(20)
                    SS1.HSBAColorSlider(color: $pen.style.color.lightUI)
                }
                .background(
                    Rectangle().fill(Color(lightBg))
                )
                
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "paintpalette")
                        Text("Foundation Color")
                    }
                    .padding([.top, .bottom], 10)
                    SS1.HSBAColorSlider(color: $pen.templateColor)
                    HStack(alignment: .center, spacing: 10) {
                        Toggle("Show Other Colors", isOn: $showOtherColors)
                    }
                    .padding(.bottom, 10)
                    if showOtherColors {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 10) {
                                ForEach(toolbarModel.pens) { otherPen in
                                    VStack(alignment: .center, spacing: 5) {
                                        Button(
                                            action: {
                                                pen.templateColor = otherPen.style.color.lightUI
                                            },
                                            label: {
                                                RoundedRectangle(cornerRadius: 3.0)
                                                    .fill(otherPen.style.color.lightUI.asColor)
                                                    .frame(width: 50, height: 50)
                                            }
                                        )
                                        Button(
                                            action: {
                                                pen.templateColor = otherPen.templateColor
                                            },
                                            label: {
                                                RoundedRectangle(cornerRadius: 3.0)
                                                    .fill(otherPen.templateColor.asColor)
                                                    .frame(width: 50, height: 50)
                                            }
                                        )
                                        Button(
                                            action: {
                                                pen.templateColor = otherPen.style.color.darkUI
                                            },
                                            label: {
                                                RoundedRectangle(cornerRadius: 3.0)
                                                    .fill(otherPen.style.color.darkUI.asColor)
                                                    .frame(width: 50, height: 50)
                                            }
                                        )
                                    }
                                        .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding([.bottom], 10)
                        }
                    }
                }
                
                VStack(alignment: .center, spacing: 5) {
                    HStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "moon")
                                .foregroundColor(Color.white)
                            Text("Dark UI Mode")
                                .foregroundColor(Color.white)
                        }
                        .padding(.top, 10)
                        Spacer()
                        UI.Btn.Pill(
                            action: {
                                pen.style.color.darkUI = pen.templateColor
                            },
                            left: {
                                Image(systemName: "paintpalette")
                            },
                            right: {
                                Text("Reset")
                            }
                        )
                            .fgColorMap(lightMode: UI.LL.Color.white, darkMode: UI.LL.Color.white)
                    }
                    .padding(20)
                    SS1.HSBAColorSlider(color: $pen.style.color.darkUI)
                }
                .background(
                    Rectangle().fill(Color(darkBg))
                )
            }
            .padding(.top, 10)
        }
        @ViewBuilder private var strokeSettings: some View {
            VStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text("Thinning")
                    Spacer()
                    Text(String(format: "%.2f", pen.style.thinning))
                    UI.Btn.Rounded(action: {pen.style.thinning = SS1.Pen.PenStyle.defaultThinning}) {
                        Text("Reset")
                    }
                }
                Slider(
                    value: $pen.style.thinning,
                    in: SS1.Pen.PenStyle.minThinning...SS1.Pen.PenStyle.maxThinning
                )
                HStack(alignment: .center, spacing: 10) {
                    easingControl($pen.style.easing, label: {
                        Text("Stroke Easing")
                    })
                    UI.Btn.Rounded(action: {pen.style.easing = .linear}) {
                        Text("Reset")
                    }
                }
                HStack(alignment: .center, spacing: 10) {
                    Text("Smoothing")
                    Spacer()
                    Text(String(format: "%.2f", pen.style.smoothing))
                    UI.Btn.Rounded(action: {pen.style.smoothing = SS1.Pen.PenStyle.defaultSmoothing}) {
                        Text("Reset")
                    }
                }
                Slider(
                    value: $pen.style.smoothing,
                    in: SS1.Pen.PenStyle.minSmoothing...SS1.Pen.PenStyle.maxSmoothing
                )
                HStack(alignment: .center, spacing: 10) {
                    Text("Streamline")
                    Spacer()
                    Text(String(format: "%.2f", pen.style.streamline))
                    UI.Btn.Rounded(action: {pen.style.streamline = SS1.Pen.PenStyle.defaultStreamline}) {
                        Text("Reset")
                    }
                }
                Slider(
                    value: $pen.style.streamline,
                    in: SS1.Pen.PenStyle.minStreamline...SS1.Pen.PenStyle.maxStreamline
                )
            }
            .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
        }
        @ViewBuilder private func easingControl<V: View>(
            _ value: Binding<SS1.Pen.PenStyle.Easing>,
            @ViewBuilder label: @escaping () -> V
        ) -> some View {
            Picker(
                selection: value,
                content: {
                    Group {
                        Text("linear").tag(SS1.Pen.PenStyle.Easing.linear)
                        Text("easeInQuad").tag(SS1.Pen.PenStyle.Easing.easeInQuad)
                        Text("easeOutQuad").tag(SS1.Pen.PenStyle.Easing.easeOutQuad)
                        Text("easeInOutQuad").tag(SS1.Pen.PenStyle.Easing.easeInOutQuad)
                        Text("easeInCubic").tag(SS1.Pen.PenStyle.Easing.easeInCubic)
                        Text("easeOutCubic").tag(SS1.Pen.PenStyle.Easing.easeOutCubic)
                        Text("easeInOutCubic").tag(SS1.Pen.PenStyle.Easing.easeInOutCubic)
                        Text("easeInQuart").tag(SS1.Pen.PenStyle.Easing.easeInQuart)
                        Text("easeOutQuart").tag(SS1.Pen.PenStyle.Easing.easeOutQuart)
                    }
                    Group {
                        Text("easeInOutQuart").tag(SS1.Pen.PenStyle.Easing.easeInOutQuart)
                        Text("easeInQuint").tag(SS1.Pen.PenStyle.Easing.easeInQuint)
                        Text("easeOutQuint").tag(SS1.Pen.PenStyle.Easing.easeOutQuint)
                        Text("easeInOutQuint").tag(SS1.Pen.PenStyle.Easing.easeInOutQuint)
                        Text("easeInSine").tag(SS1.Pen.PenStyle.Easing.easeInSine)
                        Text("easeOutSine").tag(SS1.Pen.PenStyle.Easing.easeOutSine)
                        Text("easeInOutSine").tag(SS1.Pen.PenStyle.Easing.easeInOutSine)
                        Text("easeInExpo").tag(SS1.Pen.PenStyle.Easing.easeInExpo)
                        Text("easeOutExpo").tag(SS1.Pen.PenStyle.Easing.easeOutExpo)
                    }
                },
                label: {
                    label()
                }
            )
                .pickerStyle(MenuPickerStyle())
        }
        @ViewBuilder private var strokeCapSettings: some View {
            VStack(alignment: .center, spacing: 10) {
                RoundedLabel(inactive: true, label: {
                    VStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Toggle(isOn: $pen.style.start.cap) {
                                Text("Show Stroke Start Cap")
                            }
                            Spacer()
                            UI.Btn.Rounded(action: {pen.style.start.cap = true}) {
                                Text("Reset")
                            }
                        }
                        Divider()
                        HStack(alignment: .center, spacing: 10) {
                            easingControl($pen.style.start.easing, label: {
                                Text("Start Cap Easing")
                            })
                            UI.Btn.Rounded(action: {pen.style.start.easing = .linear}) {
                                Text("Reset")
                            }
                        }
                    }
                    .padding(10)
                })
                RoundedLabel(inactive: true, label: {
                    VStack(alignment: .center, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            Toggle(isOn: $pen.style.end.cap) {
                                Text("Show Stroke End Cap")
                            }
                            Spacer()
                            UI.Btn.Rounded(action: {pen.style.end.cap = true}) {
                                Text("Reset")
                            }
                        }
                        Divider()
                        HStack(alignment: .center, spacing: 10) {
                            easingControl($pen.style.end.easing, label: {
                                Text("End Cap Easing")
                            })
                            UI.Btn.Rounded(action: {pen.style.end.easing = .linear}) {
                                Text("Reset")
                            }
                        }
                    }
                    .padding(10)
                })
            }
            .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
        }

        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    Group {
                        layer.padding([.bottom], 10)
                        Divider().padding([.top], 10)
                    }
                    Group {
                        penUISettings.padding([.top, .bottom], 10)
                        Divider().padding([.top], 10)
                    }
                    Group {
                        basicColorPicker
                        Divider()
                        hsbaColorPicker
                        Divider().padding([.bottom], 10)
                    }
                    Group {
                        size.padding([.top, .bottom], 10)
                    }
                    Group {
                        Divider().padding([.top, .bottom], 10)
                        strokeSettings.padding([.top, .bottom], 10)
                    }
                    Group {
                        Divider().padding([.top, .bottom], 10)
                        strokeCapSettings.padding([.top, .bottom], 10)
                    }
                }
                .frame(minWidth: 500)
                .padding([.top, .bottom], 25)
            }
        }
    }

    struct PenListEditorView: View {
        @ObservedObject var toolbarModel: SS1.ToolBarModel
        @State private var editMode: Bool = false
        @Environment(\.colorScheme) private var colorScheme
        @Environment(\.presentationMode) private var presentationMode
        private enum InsertNewPenOrder {
            case front
            case back
        }
        @State private var showInsertNewPenMenu: Bool = false
        @State private var insertNewPenOrder: InsertNewPenOrder = InsertNewPenOrder.back
        @State private var settingsLock: Bool = true
        enum PenListFilter: String, Equatable, Codable {
            case showAll
            case showSet1
            case showSet2
            case showSet3
            case showSet4
        }
        @State private var penListFilter = PenListFilter.showAll
        func hasLotsOfPens() -> Bool {
            var penCounter = 0
            for pen in self.toolbarModel.pens {
                switch (penListFilter, pen.penSet) {
                case (.showAll, _): penCounter = penCounter + 1
                case (.showSet1, .set1): penCounter = penCounter + 1
                case (.showSet2, .set2): penCounter = penCounter + 1
                case (.showSet3, .set3): penCounter = penCounter + 1
                case (.showSet4, .set4): penCounter = penCounter + 1
                default: ()
                }
            }
            return penCounter > 10
        }
        private func insertPenBtnAction() {
            let lotsOfPens = hasLotsOfPens()
            if !lotsOfPens {
                var newPen = toolbarModel.templatePen
                newPen.id = UUID()
                switch self.penListFilter {
                case .showSet1: newPen.penSet = .set1
                case .showSet2: newPen.penSet = .set2
                case .showSet3: newPen.penSet = .set3
                case .showSet4: newPen.penSet = .set4
                case .showAll: ()
                }
                toolbarModel.pens.append(newPen)
            } else {
                showInsertNewPenMenu = true
            }
        }
        @ViewBuilder private var insertPenBtn: some View {
            let lotsOfPens = hasLotsOfPens()
            UI.Btn.Pill(
                action: self.insertPenBtnAction,
                left: {
                    if lotsOfPens {
                        Image(systemName: "rectangle.badge.plus")
                    } else {
                        Image(systemName: "plus")
                    }
                },
                right: {
                    if lotsOfPens {
                        Text("Insert New Pen (Options)")
                    } else {
                        Text("Insert New Pen")
                    }
                }
            )
                .popover(isPresented: $showInsertNewPenMenu, content: {
                    let addPenAction = {
                        var newPen = toolbarModel.templatePen
                        newPen.id = UUID()
                        switch self.penListFilter {
                        case .showSet1: newPen.penSet = .set1
                        case .showSet2: newPen.penSet = .set2
                        case .showSet3: newPen.penSet = .set3
                        case .showSet4: newPen.penSet = .set4
                        case .showAll: ()
                        }
                        switch self.insertNewPenOrder {
                        case .back: toolbarModel.pens.append(newPen)
                        case .front:
                            if toolbarModel.pens.isEmpty {
                                toolbarModel.pens.append(newPen)
                            } else {
                                toolbarModel.pens.insert(newPen, at: 0)
                            }
                        }
                    }
                    VStack(alignment: .center, spacing: 20) {
                        Text("It looks like you have a lot of pens, for your convenience, I can insert the new pen at the beginning of the list, or at the back of the list.")
                            .multilineTextAlignment(.center)
                            .textTheme()
                            .frame(width: 400)
                        Picker("Layer", selection: $insertNewPenOrder) {
                            Text("Front").tag(InsertNewPenOrder.front)
                            Text("Back").tag(InsertNewPenOrder.back)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        UI.Btn.Rounded(action: addPenAction) {
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Text("Insert")
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                })
        }
        @ViewBuilder private func penListEntry(pen: Binding<SS1.Pen>) -> some View {
            HStack(alignment: .center, spacing: 5) {
                let darkColor = Color(pen.wrappedValue.style.color.darkUI.asCGColor)
                let lightColor = Color(pen.wrappedValue.style.color.lightUI.asCGColor)
                let darkIcon = Image(systemName: "moon")
                let lightIcon = Image(systemName: "sun.min")
                RoundedLabel(inactive: true, label: {
                    switch pen.penSet.wrappedValue {
                    case .set1: Text("{1}")
                    case .set2: Text("{2}")
                    case .set3: Text("{3}")
                    case .set4: Text("{4}")
                    }
                })
                Text(String(format: "%.1fpx", pen.style.size.wrappedValue))
                Spacer()
                if pen.active.wrappedValue {
                    RoundedLabel(altColor: true, label: {
                        Text("Active")
                    })
                }
                Spacer()
                RoundedLabel(inactive: true, label: {
                    if pen.wrappedValue.style.layer == .foreground {
                        Text("Foreground")
                    } else {
                        Text("Background")
                    }
                })
                RoundedPill(inactive: true, left: {darkIcon}, right: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            fillStyle: darkColor,
                            stroke: Color.black,
                            lineWidth: 1
                        )
                        .frame(width: 50, alignment: .center)
                })
                RoundedPill(inactive: true, left: {lightIcon}, right: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            fillStyle: lightColor,
                            stroke: Color.white,
                            lineWidth: 1
                        )
                        .frame(width: 50, alignment: .center)
                    }
                )
                UI.Hacks.NavigationStackViewLink(
                    navBar: UI.Hacks.NavBar.defaultNavBar(title: "Edit Pen", withBackBtn: true),
                    destination: {
                        PenSettingsPanel(toolbarModel: toolbarModel, pen: pen)
                    },
                    label: {
                        Image(systemName: "chevron.forward")
                    }
                )
            }
        }
        @ViewBuilder private var penList: some View {
            List {
                ForEach(Array(toolbarModel.pens.enumerated()), id: \.1.id) {(ix, pen) in
                    let view = penListEntry(pen: $toolbarModel.pens[ix])
                    switch (penListFilter, pen.penSet) {
                    case (.showAll, _): view
                    case (.showSet1, .set1): view
                    case (.showSet2, .set2): view
                    case (.showSet3, .set3): view
                    case (.showSet4, .set4): view
                    default: EmptyView()
                    }
                }
                .onMove(perform: onMove)
                .onDelete(perform: onDelete)
            }
            .frame(minWidth: 800, minHeight: 400)
        }
        var body: some View {
            let navBar = UI.Hacks.NavBar(
                title: "Pen List Editor",
                withBackBtn: false,
                leading: {
                    UI.Btn.Rounded(action: {presentationMode.wrappedValue.dismiss()}) {
                        Text("Close")
                    }
                    UI.Btn.Rounded(toggle: $settingsLock) {
                        if settingsLock {
                            Image(systemName: "lock")
                        } else {
                            Image(systemName: "lock.open")
                        }
                    }
                    .useDangerousFgColor()
                },
                trailing: {
                    UI.Btn.Pill(
                        action: {
                            if !settingsLock {
                                let newModel = SS1.ToolBarModel()
                                toolbarModel.pens = newModel.pens
                                toolbarModel.templatePen = newModel.templatePen
                            }
                        },
                        left: {
                            if settingsLock {
                                Image(systemName: "lock")
                            } else {
                                Image(systemName: "lock.open")
                            }
                        },
                        right: {
                            Text("Reset Pens")
                        }
                    )
                        .disabled(settingsLock)
                }
            )
            UI.Hacks.NavigationStackView(navBar: navBar) {
                content
            }
        }
        private var content: some View {
            VStack(alignment: .center, spacing: 10) {
                Divider()
                HStack(alignment: .center, spacing: 10) {
                    UI.Btn.Rounded(toggle: $editMode) {
                        Text("Toggle Edit Mode")
                    }
                    Spacer()
                    insertPenBtn
                    Spacer()
                    UI.Hacks.NavigationStackViewLink(
                        navBar: UI.Hacks.NavBar.defaultNavBar(),
                        destination: {
                            PenSettingsPanel(
                                onDelete: nil,
                                onSave: {
                                    
                                },
                                toolbarModel: toolbarModel,
                                pen: $toolbarModel.templatePen
                            )
                        },
                        label: {
                            Text("Edit Template Pen")
                        }
                    )
                }
                .padding([.leading, .trailing], 10)
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    Text("Show")
                    Picker("Filter", selection: $penListFilter) {
                        Text("All Pens").tag(PenListFilter.showAll)
                        Text("{1}").tag(PenListFilter.showSet1)
                        Text("{2}").tag(PenListFilter.showSet2)
                        Text("{3}").tag(PenListFilter.showSet3)
                        Text("{4}").tag(PenListFilter.showSet4)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Spacer()
                }
                let list = penList
                if editMode {
//                    list.environment(\.editMode, Binding.constant(EditMode.active)).border(edges: [.top])
                    list.border(edges: [.top])
                } else {
                    list.border(edges: [.top])
                }
            }
        }
        private func onDelete(offsets: IndexSet) {
            toolbarModel.pens.remove(atOffsets: offsets)
        }
        private func onMove(source: IndexSet, destination: Int) {
            toolbarModel.pens.move(fromOffsets: source, toOffset: destination)
        }
    }
}

