//
//  ToolBar.swift
//  Superscript
//
//  Created by Colbyn Wadman on 12/29/21.
//

import SwiftUI
import UIKit


fileprivate let DARK_TOOLBAR_FOREGROUND_COLOR: UIColor = #colorLiteral(red: 0.2541313469, green: 0.2541313469, blue: 0.2541313469, alpha: 1)
fileprivate let LIGHT_TOOLBAR_FOREGROUND_COLOR: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

fileprivate let iconColor: Color = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
fileprivate let disabledIconColor: Color = Color(#colorLiteral(red: 0.5570612527, green: 0.633860792, blue: 0.6627638421, alpha: 1))
fileprivate let textColor: Color = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
fileprivate let borderColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
fileprivate let buttonBgColor: Color = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))

fileprivate enum LayerViewToggle {
    case foreground
    case background
    case both
}

fileprivate struct PenSettingsPanel: View {
    var onDelete: (() -> ())? = nil
    var onSave: (() -> ()) = {}
    @Binding var pen: SS1.RuntimeDataModel.Pen
    @Environment(\.presentationMode) private var presentationMode
    @ViewBuilder private var layer: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Layer")
            Picker("Layer", selection: $pen.layer) {
                Text("Foreground").tag(SS1.Stroke.Layer.foreground)
                Text("Background").tag(SS1.Stroke.Layer.background)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
    }
    @ViewBuilder private var penUISettings: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Primary Color Scheme Mode")
            Picker("primary Color Scheme Mode", selection: $pen.primaryColorSchemeMode) {
                Text("Both").tag(SS1.RuntimeDataModel.Pen.PrimaryColorSchemeMode.both)
                Text("Light").tag(SS1.RuntimeDataModel.Pen.PrimaryColorSchemeMode.light)
                Text("Dark").tag(SS1.RuntimeDataModel.Pen.PrimaryColorSchemeMode.dark)
            }
            .pickerStyle(SegmentedPickerStyle())
            Text("Pen Set")
            Picker("Pen Set", selection: $pen.penSet) {
                Text("Set 1").tag(SS1.RuntimeDataModel.Pen.PenSet.set1)
                Text("Set 2").tag(SS1.RuntimeDataModel.Pen.PenSet.set2)
                Text("Set 3").tag(SS1.RuntimeDataModel.Pen.PenSet.set3)
                Text("Set 4").tag(SS1.RuntimeDataModel.Pen.PenSet.set4)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
    }
    @ViewBuilder private var size: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 0) {
                Text("Size")
                Spacer()
                Text(String(format: "%.2fpx", pen.options.size))
            }
            Slider(
                value: $pen.options.size,
                in: SS1.Stroke.Options.minSize...SS1.Stroke.Options.maxSize,
                step: 0.5
            )
        }
        .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
    }
    @ViewBuilder private var colors: some View {
        VStack(alignment: .center, spacing: 0) {
            let bg = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            ZStack(alignment: .center) {
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
                        selection: $pen.options.color.lightUIMode.cgColor,
                        supportsOpacity: true
                    )
                        .labelsHidden()
                        .frame(minWidth: 100, minHeight: 100)
                }
                .foregroundColor(Color.black)
                .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                .padding([.top, .bottom], 10)
            }
            
            Divider()
            ZStack(alignment: .center) {
                Rectangle()
                    .foregroundColor(Color(hue: 0.698, saturation: 0.184, brightness: 0.438))
                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Spacer()
                        Image(systemName: "moon")
                        Text("Dark Mode Color")
                        Spacer()
                    }
                    ColorPicker(
                        "",
                        selection: $pen.options.color.darkUIMode.cgColor,
                        supportsOpacity: true
                    )
                        .labelsHidden()
                        .frame(minWidth: 100, minHeight: 100)
                }
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
                .padding([.top, .bottom], 10)
            }
        }
    }
    @ViewBuilder private var strokeSettings: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 0) {
                Text("Thinning")
                Spacer()
                Text(String(format: "%.2f", pen.options.thinning))
            }
            Slider(
                value: $pen.options.thinning,
                in: SS1.Stroke.Options.minThinning...SS1.Stroke.Options.maxThinning
            )
            easingControl($pen.options.easing, label: {
                Text("Stroke Easing")
            })
            HStack(alignment: .center, spacing: 0) {
                Text("Smoothing")
                Spacer()
                Text(String(format: "%.2f", pen.options.smoothing))
            }
            Slider(
                value: $pen.options.smoothing,
                in: SS1.Stroke.Options.minSmoothing...SS1.Stroke.Options.maxSmoothing
            )
            HStack(alignment: .center, spacing: 0) {
                Text("Streamline")
                Spacer()
                Text(String(format: "%.2f", pen.options.streamline))
            }
            Slider(
                value: $pen.options.streamline,
                in: SS1.Stroke.Options.minStreamline...SS1.Stroke.Options.maxStreamline
            )
        }
        .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
    }
    @ViewBuilder private func easingControl<V: View>(
        _ value: Binding<SS1.Stroke.Options.Easing>,
        @ViewBuilder label: @escaping () -> V
    ) -> some View {
        HStack(alignment: .center, spacing: 10) {
            label()
            Spacer()
            Picker(
                selection: value,
                content: {
                    Group {
                        Text("linear")
                            .tag(SS1.Stroke.Options.Easing.linear)
                        Text("easeInQuad")
                            .tag(SS1.Stroke.Options.Easing.easeInQuad)
                        Text("easeOutQuad")
                            .tag(SS1.Stroke.Options.Easing.easeOutQuad)
                        Text("easeInOutQuad")
                            .tag(SS1.Stroke.Options.Easing.easeInOutQuad)
                        Text("easeInCubic")
                            .tag(SS1.Stroke.Options.Easing.easeInCubic)
                        Text("easeOutCubic")
                            .tag(SS1.Stroke.Options.Easing.easeOutCubic)
                        Text("easeInOutCubic")
                            .tag(SS1.Stroke.Options.Easing.easeInOutCubic)
                        Text("easeInQuart")
                            .tag(SS1.Stroke.Options.Easing.easeInQuart)
                        Text("easeOutQuart")
                            .tag(SS1.Stroke.Options.Easing.easeOutQuart)
                    }
                    Group {
                        Text("easeInOutQuart")
                            .tag(SS1.Stroke.Options.Easing.easeInOutQuart)
                        Text("easeInQuint")
                            .tag(SS1.Stroke.Options.Easing.easeInQuint)
                        Text("easeOutQuint")
                            .tag(SS1.Stroke.Options.Easing.easeOutQuint)
                        Text("easeInOutQuint")
                            .tag(SS1.Stroke.Options.Easing.easeInOutQuint)
                        Text("easeInSine")
                            .tag(SS1.Stroke.Options.Easing.easeInSine)
                        Text("easeOutSine")
                            .tag(SS1.Stroke.Options.Easing.easeOutSine)
                        Text("easeInOutSine")
                            .tag(SS1.Stroke.Options.Easing.easeInOutSine)
                        Text("easeInExpo")
                            .tag(SS1.Stroke.Options.Easing.easeInExpo)
                        Text("easeOutExpo")
                            .tag(SS1.Stroke.Options.Easing.easeOutExpo)
                    }
                },
                label: {
                    label()
                }
            )
                .pickerStyle(MenuPickerStyle())
                .scaleEffect(1.5)
                .padding(.trailing, 5)
        }
    }
    @ViewBuilder private var strokeCapSettings: some View {
        VStack(alignment: .center, spacing: 10) {
            RoundedLabel(inactive: true, label: {
                VStack(alignment: .center, spacing: 10) {
                    Toggle(isOn: $pen.options.start.cap) {
                        Text("Stroke Start Cap")
                    }
                    Divider()
                    easingControl($pen.options.start.easing, label: {
                        Text("Start Cap Easing")
                    })
                }
                .padding(10)
            })
            RoundedLabel(inactive: true, label: {
                VStack(alignment: .center, spacing: 10) {
                    Toggle(isOn: $pen.options.end.cap) {
                        Text("Stroke End Cap")
                    }
                    Divider()
                    easingControl($pen.options.end.easing, label: {
                        Text("End Cap Easing")
                    })
                }
                .padding(10)
            })
        }
        .padding(EdgeInsets(top: 10, leading: 25, bottom: 10, trailing: 25))
    }
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
    @ViewBuilder private func infoPanel() -> some View {
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
                    colors
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
        .navigationBarItems(trailing: NavigationLink(destination: infoPanel, label: {
            RoundedLabel(label: {
                Text("Info")
            })
        }))
    }
}


fileprivate struct StrokeTextLabel: UIViewRepresentable {
    let color: UIColor
    let size: CGFloat
    
    private let scale = MathUtils.newLinearScale(domain: (0, SS1.Stroke.Options.maxSize), range: (20, 40))
    
    func makeUIView(context: Context) -> UILabel {
        let attributedStringParagraphStyle = NSMutableParagraphStyle()
        attributedStringParagraphStyle.alignment = NSTextAlignment.center
        let attributedString = NSAttributedString(
            string: "Color",
            attributes:[
                NSAttributedString.Key.paragraphStyle: attributedStringParagraphStyle,
                NSAttributedString.Key.strokeWidth: -4.0,
                NSAttributedString.Key.foregroundColor: self.color,
                NSAttributedString.Key.strokeColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name:"Helvetica", size: scale(self.size))!
            ]
        )

        let strokeLabel = UILabel()
        strokeLabel.attributedText = attributedString
        strokeLabel.backgroundColor = UIColor.clear
        strokeLabel.sizeToFit()
        return strokeLabel
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}

fileprivate struct EraserTool: View {
    let active: Bool
    let onClick: () -> ()
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                let fg = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                ZStack(alignment: Alignment.top) {
                    BackgroundGraphic(active: active)
                        .scale(1.0)
                        .foregroundColor(Color(fg))
                    TopGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)),
                                        Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)),
                                    ]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    BottomGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)),
                                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .offset(x: 0, y: self.active ? 10 : 0)
                .foregroundColor(Color.clear)
            }
        )
    }
    private struct BackgroundGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.62))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.62))
            path.closeSubpath()
            return path
        }
    }
    private struct TopGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.closeSubpath()
            return path
        }
    }
    private struct BottomGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.6))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.6))
            path.closeSubpath()
            return path
        }
    }
}
fileprivate struct SelectionTool: View {
    let active: Bool
    let onClick: () -> ()
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                ZStack(alignment: Alignment.top) {
                    BackgroundGraphic(active: active)
                        .scale(1.0)
                        .foregroundColor(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)))
                    TopGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)),
                                        Color(#colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)),
                                    ]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    BottomGraphic(active: active)
                        .scale(0.95)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(#colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)),
                                        Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
                                    ]
                                ),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .offset(x: 0, y: self.active ? 8 : 0)
                .foregroundColor(Color.clear)
            }
        )
    }
    private struct BackgroundGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.42))
            path.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.752))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.42))
            path.closeSubpath()
            return path
        }
    }
    private struct TopGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: -20))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.closeSubpath()
            return path
        }
    }
    private struct BottomGraphic: Shape {
        let active: Bool
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.4))
            path.addLine(to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.75))
//            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.6))
            path.closeSubpath()
            return path
        }
    }
}

fileprivate struct PenView: View {
    let width: CGFloat
    let setToPen: (SS1.RuntimeDataModel.Pen) -> ()
    @ObservedObject var runtimeModel: SS1.RuntimeDataModel
    @Binding var pen: SS1.RuntimeDataModel.Pen
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onClick, label: self.label)
    }
    
    private func onClick() {
        for (ix, _) in runtimeModel.pens.enumerated() {
            runtimeModel.pens[ix].active = false
        }
        pen.active = true
        setToPen(pen)
    }
    
    @ViewBuilder private func label() -> some View {
        GeometryReader { geo in
            let graphic = ZStack(alignment: Alignment.top) {
                let backColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                let frontColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                let invertToggle = runtimeModel.invertPenColors
                let penColor = pen.options.color
                    .getUIColorFor(invertToggle: invertToggle, colorScheme)
                Top(active: pen.active)
                    .foregroundColor(Color(backColor))
                Top(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Top(active: pen.active)
                    .scale(0.90)
                    .offset(y: -2.0)
                    .foregroundColor(Color(penColor.cgColor))
                Bottom(active: pen.active)
                    .foregroundColor(Color(backColor))
                Bottom(active: pen.active)
                    .scale(0.95)
                    .foregroundColor(Color(frontColor))
                Bottom(active: pen.active)
                    .scale(0.9)
                    .offset(y: -1.0)
                    .foregroundColor(Color(penColor.cgColor))
            }
            if self.pen.active {
                graphic.offset(x: 0, y: 6.0)
            } else {
                graphic.offset(x: 0, y: -2.0)
            }
        }
    }
    
    private struct Top: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.2))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY * 0.2))
            path.closeSubpath()
            return path
        }
    }
    
    private struct Bottom: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: rect.maxY * 0.2))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.2))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.8),
                control: CGPoint(x: rect.maxX, y: rect.maxY / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.maxY * 0.2),
                control: CGPoint(x: 0, y: rect.maxY / 2)
            )
            path.closeSubpath()
            return path
        }
    }
    
    private struct Background: Shape {
        let active: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: -8.0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.21))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX / 2, y: rect.maxY * 0.8),
                control: CGPoint(x: rect.maxX, y: rect.maxY / 2)
            )
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.maxY * 0.21),
                control: CGPoint(x: 0, y: rect.maxY / 2)
            )
            path.closeSubpath()
            return path
        }
    }
}

extension SS1.Drawing {
    struct ToolBar: View {
        @ObservedObject var runtimeModel: SS1.RuntimeDataModel
        @ObservedObject var canvasModel: SS1.CanvasDataModel
//        @Binding var displayStyle: ColorScheme
        let toggleColorScheme: () -> ()
        let openSettings: () -> ()
        let setToPen: (SS1.RuntimeDataModel.Pen) -> ()
        let setToEraser: () -> ()
        let setToSelection: () -> ()
        let goBack: () -> ()
        let onSave: () -> ()
        
        @State private var usingEraserTool: Bool = false
        @State private var usingSelectionTool: Bool = false
        @Environment(\.colorScheme) private var colorScheme
        @State private var layerViewToggle: LayerViewToggle = .both
        @State private var penSetViewToggle = SS1.RuntimeDataModel.Pen.PenSet.set1
        
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 5) {
                    Button(
                        action: goBack,
                        label: {
                            RoundedLabel(label: {
                                Image(systemName: "chevron.left")
                            })
                        }
                    )
                        .padding(.trailing, 10)
                    SelectionTool(active: usingSelectionTool, onClick: {
                        usingSelectionTool = !usingSelectionTool
                        usingEraserTool = false
                        setToSelection()
                    })
                        .frame(width: 35, alignment: .center)
                    EraserTool(active: usingEraserTool, onClick: {
                        usingEraserTool = !usingEraserTool
                        usingSelectionTool = false
                        setToEraser()
                    })
                        .frame(width: 35, alignment: .center)
                        .padding(.trailing, 10)
                }
                Button(
                    action: {
                        switch self.layerViewToggle {
                        case .both: self.layerViewToggle = .foreground
                        case .foreground: self.layerViewToggle = .background
                        case .background: self.layerViewToggle = .both
                        }
                    },
                    label: {
                        RoundedLabel(label: {
                            let foreground = "square.2.stack.3d.top.filled"
                            let background = "square.2.stack.3d.bottom.filled"
                            let both = "square.3.layers.3d.down.right"
                            switch self.layerViewToggle {
                            case .foreground: Image(systemName: foreground)
                            case .background: Image(systemName: background)
                            case .both: Image(systemName: both)
                            }
                        })
                    }
                )
                Button(
                    action: {
                        switch self.penSetViewToggle {
                        case .set1: self.penSetViewToggle = SS1.RuntimeDataModel.Pen.PenSet.set2
                        case .set2: self.penSetViewToggle = SS1.RuntimeDataModel.Pen.PenSet.set3
                        case .set3: self.penSetViewToggle = SS1.RuntimeDataModel.Pen.PenSet.set4
                        case .set4: self.penSetViewToggle = SS1.RuntimeDataModel.Pen.PenSet.set1
                        }
                    },
                    label: {
                        RoundedLabel(label: {
                            switch self.penSetViewToggle {
                            case .set1: Text("{1}")
                            case .set2: Text("{2}")
                            case .set3: Text("{3}")
                            case .set4: Text("{4}")
                            }
                        })
                    }
                )
                pensListMenu
                    .border(edges: [.leading, .trailing])
                    .padding([.leading, .trailing], 10)
                HStack(alignment: .center, spacing: 5) {
                    Button(
                        action: openSettings,
                        label: {
                            RoundedLabel(label: {
                                Image(systemName: "paintpalette.fill")
                            })
                        }
                    )
                    Button(
                        action: {
                            runtimeModel.invertPenColors.toggle()
                        },
                        label: {
                            RoundedLabel(altColor: runtimeModel.invertPenColors, label: {
                                Text("𝑓⁻¹")
                            })
                        }
                    )
                    Button(
                        action: toggleColorScheme,
                        label: {
                            RoundedLabel(label: {
                                let darkIcon = Image(systemName: "moon")
                                let lightIcon = Image(systemName: "sun.min")
                                colorScheme == .dark ? darkIcon : lightIcon
                            })
                        }
                    )
                    Button(
                        action: onSave,
                        label: {
                            RoundedLabel(label: {
                                Text("Save")
                            })
                        }
                    )
                }
            }
            .padding([.leading, .trailing], 10)
            .background(Color(colorScheme == .dark ? DARK_TOOLBAR_FOREGROUND_COLOR : LIGHT_TOOLBAR_FOREGROUND_COLOR))
            .border(width: 0.5, edges: .bottom)
            .clipped()
        }
        private func getPenSize(_ pen: SS1.RuntimeDataModel.Pen) -> CGFloat {
            var sizes: Array<CGFloat> = []
            for pen in runtimeModel.pens {
                if pen.penSet == penSetViewToggle {
                    sizes.append(pen.options.size)
                }
            }
            let min: CGFloat = sizes.min()!
            let max: CGFloat = sizes.max()!
            let delta = max - min
            let outputMin: CGFloat = 25
            let outputMax: CGFloat = delta >= 10 ? 60 : 45
            let xScale: (CGFloat) -> CGFloat = MathUtils.newLinearScale(
                domain: (min, max),
                range: (outputMin, outputMax)
            )
            let penWidthX: CGFloat = xScale(pen.options.size)
            if penWidthX.isNaN {
                return outputMin
            }
            if penWidthX.isZero {
                return outputMin
            }
            if penWidthX.isInfinite {
                return outputMax
            }
            if penWidthX.isSignalingNaN {
                return outputMin
            }
            if penWidthX <= outputMin {
                return outputMin
            } else {
                if penWidthX >= outputMax {
                    return outputMax
                }
                return penWidthX
            }
        }
        @ViewBuilder private func penItem(ix: Int, pen: SS1.RuntimeDataModel.Pen) -> some View {
            let width = getPenSize(pen)
            let penView = PenView(
                width: width,
                setToPen: { pen in
                    self.usingSelectionTool = false
                    self.usingEraserTool = false
                    self.setToPen(pen)
                },
                runtimeModel: runtimeModel,
                pen: Binding.proxy($runtimeModel.pens[ix])
            )
            if pen.layer == .foreground {
                penView
                    .frame(width: width, alignment: .center)
            } else {
                penView
                    .rotationEffect(Angle.degrees(180))
                    .frame(width: width, alignment: .center)
            }
        }
        @ViewBuilder private var pensListMenu: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: -5) {
                    ForEach(Array(runtimeModel.pens.enumerated()), id: \.1.id) { (ix, pen) in
                        let view = {
                            Group {
                                switch (self.layerViewToggle, pen.layer) {
                                case (.both, _): penItem(ix: ix, pen: pen)
                                case (.foreground, .foreground): penItem(ix: ix, pen: pen)
                                case (.background, .background): penItem(ix: ix, pen: pen)
                                default: EmptyView()
                                }
                            }
                        }
                        if pen.penSet == self.penSetViewToggle {
                            if runtimeModel.invertPenColors {
                                view()
                            } else {
                                switch (colorScheme.toBinaryOption(), pen.primaryColorSchemeMode) {
                                case (.dark, .dark): view()
                                case (.light, .light): view()
                                case (_, .both): view()
                                case (_, _): EmptyView()
                                }
                            }
                        } else {
                            EmptyView()
                        }
                    }
                }
                .padding([.leading, .trailing], 10)
            }
        }
    }
    struct PenSettingsView: View {
        @ObservedObject var runtimeModel: SS1.RuntimeDataModel
        @ObservedObject var drawingModel: SS1.CanvasDataModel
        @State var editMode: Bool = false
        @Environment(\.colorScheme) var colorScheme
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
        @ViewBuilder private var insertPenBtn: some View {
            let lotsOfPens = self.runtimeModel.pens.count > 10
            Button(action: {
                if !lotsOfPens {
                    var newPen = runtimeModel.templatePen
                    newPen.id = UUID()
                    runtimeModel.pens.append(newPen)
                } else {
                    showInsertNewPenMenu = true
                }
            }, label: {
                RoundedPill(
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
                ).popover(isPresented: $showInsertNewPenMenu, content: {
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
                        Button(
                            action: {
                                var newPen = runtimeModel.templatePen
                                newPen.id = UUID()
                                switch self.insertNewPenOrder {
                                case .back: runtimeModel.pens.append(newPen)
                                case .front:
                                    if runtimeModel.pens.isEmpty {
                                        runtimeModel.pens.append(newPen)
                                    } else {
                                        runtimeModel.pens.insert(newPen, at: 0)
                                    }
                                }
                            },
                            label: {
                                RoundedLabel(label: {
                                    HStack(alignment: .center, spacing: 0) {
                                        Spacer()
                                        Text("Insert")
                                        Spacer()
                                    }
                                })
                            }
                        )
                    }
                    .padding(20)
                })
            })
        }
        @ViewBuilder private func penListEntry(pen: Binding<SS1.RuntimeDataModel.Pen>) -> some View {
            let label = HStack(alignment: .center, spacing: 5) {
                let darkColor = Color(pen.options.color.wrappedValue.darkUIMode.cgColor)
                let lightColor = Color(pen.options.color.wrappedValue.lightUIMode.cgColor)
                let darkIcon = Image(systemName: "moon")
                let lightIcon = Image(systemName: "sun.min")
                Text(String(format: "%.1fpx", pen.options.size.wrappedValue))
                Spacer()
                if pen.active.wrappedValue {
                    RoundedLabel(altColor: true, label: {
                        Text("Active")
                    })
                }
                Spacer()
                RoundedLabel(inactive: true, label: {
                    if pen.wrappedValue.layer == .foreground {
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
            }
            HStack(alignment: .center, spacing: 8) {
                if editMode {
                    label
                } else {
                    NavigationLink(
                        destination: {
                            PenSettingsPanel(pen: pen)
                                .navigationBarTitleDisplayMode(.inline)
                        },
                        label: {
                            label
                        }
                    )
                }
            }
        }
        @ViewBuilder private var penList: some View {
            List {
                ForEach(Array(runtimeModel.pens.enumerated()), id: \.1.id) {(ix, pen) in
                    let view = penListEntry(pen: Binding.proxy($runtimeModel.pens[ix]))
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
        }
        var body: some View {
            NavigationView {
                VStack(alignment: .center, spacing: 10) {
                    Divider()
                    HStack(alignment: .center, spacing: 10) {
                        Button(action: {editMode = !editMode}, label: {
                            RoundedLabel(label: {
                                Text("Toggle Edit Mode")
                            })
                        })
                        Spacer()
                        insertPenBtn
                        Spacer()
                        NavigationLink(
                            destination: {
                                PenSettingsPanel(pen: $runtimeModel.templatePen)
                                    .navigationBarTitleDisplayMode(.inline)
                            },
                            label: {
                                RoundedLabel(label: {
                                    Text("Edit Template Pen")
                                })
                            }
                        )
                    }.padding([.leading, .trailing], 10)
                    if editMode {
                        RoundedLabel(inactive: true, label: {
                            VStack(alignment: .center, spacing: 10) {
                                Text("Info")
                                Text("Click the “Toggle List Edit Mode” button to edit individual pens.")
                                    .multilineTextAlignment(.center)
                                Text("(The toggle-edit-mode workaround wouldn’t be necessary if I had a newer laptop -I’m happy to accept donations if you want a better app 🙂.)")
                                    .multilineTextAlignment(.center)
                            }
                            .padding(10)
                        })
                    } else {
                        RoundedLabel(inactive: true, label: {
                            VStack(alignment: .center, spacing: 10) {
                                Text("Info")
                                Text("Click the “Toggle Edit Mode” button to rearrange and delete pen entries.")
                                    .multilineTextAlignment(.center)
                                Text("(The toggle-edit-mode workaround wouldn’t be necessary if I had a newer laptop -I’m happy to accept donations if you want a better app 🙂.)")
                                    .multilineTextAlignment(.center)
                            }
                            .padding(10)
                        })
                    }
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
                        list.environment(\.editMode, Binding.constant(EditMode.active))
                            .border(edges: [.top])
                    } else {
                        list.border(edges: [.top])
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("Pen List Editor")
                .navigationBarItems(leading: HStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        RoundedLabel(label: {
                            Text("Close")
                        })
                    })
                    Button(
                        action: {
                            settingsLock.toggle()
                        },
                        label: {
                            RoundedLabel(altColor: true, label: {
                                if settingsLock {
                                    Image(systemName: "lock")
                                } else {
                                    Image(systemName: "lock.open")
                                }
                            })
                        }
                    )
                })
                .navigationBarItems(trailing: HStack(alignment: .center, spacing: 10) {
                    Button(
                        action: {
                            if !settingsLock {
                                let newModel = SS1.RuntimeDataModel()
                                runtimeModel.pens = newModel.pens
                                runtimeModel.templatePen = newModel.templatePen
                            }
                        },
                        label: {
                            RoundedPill(
                                inactive: settingsLock,
                                altColor: !settingsLock,
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
                        }
                    )
                        .disabled(settingsLock)
                })
                .navigationBarHidden(false)
//                .edgesIgnoringSafeArea(.all)
            }
        }
        private func edit(id: UUID) -> some View {
            let index: Int = runtimeModel.getIndexForPen(id: id)
            return VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Size")
                    Spacer()
                    Text(String(format: "%.2f", runtimeModel.pens[index].options.size))
                }
                Slider(
                    value: Binding.proxy($runtimeModel.pens[index].options.size),
                    in: 1...SS1.Stroke.Options.maxSize,
                    step: 1
                )
                Spacer()
            }
            .padding(12)
        }
        private func onDelete(offsets: IndexSet) {
            runtimeModel.pens.remove(atOffsets: offsets)
        }
        private func onMove(source: IndexSet, destination: Int) {
            runtimeModel.pens.move(fromOffsets: source, toOffset: destination)
        }
    }
}

