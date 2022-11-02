//
//  PenDocsUI.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/24/22.
//

import SwiftUI


fileprivate let sunIcon = "sun.min"
fileprivate let moonIcon = "moon"
fileprivate let templateColorIcon = "paintpalette"
fileprivate let LEADING_PADDING: CGFloat = 50.0
fileprivate let SECTION_TITLE_FONT: Font = .system(size: 20, weight: Font.Weight.heavy)
fileprivate let INFO_BOX_TITLE_FONT: Font = .system(size: 15, weight: Font.Weight.bold)
fileprivate let INFO_BOX_SUBTITLE_FONT: Font = .system(size: 12, weight: Font.Weight.semibold)
fileprivate let ITEM_TITLE_FONT: Font = .system(size: 15, weight: Font.Weight.medium)

@ViewBuilder fileprivate func topLevelSection<V: View>(title: String, @ViewBuilder _ content: @escaping () -> V) -> some View {
    Section(
        header: Text(title).font(.headline),
        content: content
    )
}
@ViewBuilder fileprivate func section<V: View>(title: String, @ViewBuilder _ content: @escaping () -> V) -> some View {
    Section(
        header: Text(title).font(.subheadline),
        content: content
    )
}


fileprivate struct TopLevelDocSection {
    struct Section: View, Identifiable {
        let id: UUID = UUID()
        let title: String
        let overview: String
        let contents: Array<Item>
        @Environment(\.colorScheme) private var colorScheme
        init(title: String, overview: String, _ contents: Array<Item>) {
            self.title = title
            self.overview = overview
            self.contents = contents
        }
        var body: some View {
            let borderColor = UI.ColorMode(
                lightUI: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
                darkUI: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            )
            VStack(alignment: .leading, spacing: 10) {
                Text(self.title)
                    .font(SECTION_TITLE_FONT)
                    .padding(.leading, 10)
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(self.contents) { item in
                        item
                    }
                }
                .padding(.leading, 10)
                .border(width: 1.0, edges: .leading, color: borderColor.get(for: colorScheme).asColor)
                .padding(.leading, 30)
            }
        }
    }
    
    enum Item: View, Identifiable {
        var id: UUID {
            switch self {
            case .section(let section): return section.id
            case .concept(let concept): return concept.id
            case .tip(let tip): return tip.id
            case .control(let control): return control.id
            }
        }
        case section(Section)
        case concept(Concept)
        case tip(Tip)
        case control(Control)
        init(_ section: Section) {
            self = Item.section(section)
        }
        init(_ concept: Concept) {
            self = Item.concept(concept)
        }
        init(_ tip: Tip) {
            self = Item.tip(tip)
        }
        init(_ slider: SliderControl) {
            self = Item.control(Control.init(slider: slider))
        }
        init(_ picker: EnumPickerControl) {
            self = Item.control(Control.init(picker: picker))
        }
        init(_ toggle: ToggleControl) {
            self = Item.control(Control.init(toggle: toggle))
        }
        var body: some View {
            switch self {
            case .section(let section): section
            case .concept(let concept): concept
            case .tip(let tip): tip
            case .control(let control): control
            }
        }
    }
    
    enum Control: View, Identifiable {
        var id: UUID {
            switch self {
            case .enumPickerControl(let enumPickerControl): return enumPickerControl.id
            case .slider(let sliderControl): return sliderControl.id
            case .toggle(let toggleControl): return toggleControl.id
            }
        }
        case enumPickerControl(EnumPickerControl)
        case slider(SliderControl)
        case toggle(ToggleControl)
        
        init(slider: SliderControl) {
            self = Control.slider(slider)
        }
        init(picker: EnumPickerControl) {
            self = Control.enumPickerControl(picker)
        }
        init(toggle: ToggleControl) {
            self = Control.toggle(toggle)
        }
        var body: some View {
            switch self {
            case .enumPickerControl(let enumPickerControl): enumPickerControl
            case .slider(let sliderControl): sliderControl
            case .toggle(let toggleControl): toggleControl
            }
        }
    }
    
    struct Tip: View {
        let id: UUID = UUID()
        let info: String
        var body: some View {
            RoundedLabel(inactive: true) {
                HStack(alignment: .center, spacing: 10) {
                    Text("Tip")
                        .font(INFO_BOX_TITLE_FONT)
                    Text(info)
                        .multilineTextAlignment(.leading)
                }
                .padding(10)
            }
        }
    }
    
    struct Concept: View {
        let id: UUID = UUID()
        let title: String
        var description: AnyView
        
        init(title: String, description: AnyView) {
            self.title = title
            self.description = description
        }
        init(title: String, description: String) {
            self.title = title
            self.description = AnyView(Text(description))
        }
        static func fromView<T: View>(
            title: String,
            @ViewBuilder description: @escaping () -> T
        ) -> Concept {
            Concept(
                title: title,
                description: AnyView(description())
            )
        }
        var body: some View {
            RoundedLabel(inactive: true) {
                VStack(alignment: .center, spacing: 10) {
                    Text("Concept")
                        .font(INFO_BOX_TITLE_FONT)
                    Divider()
                    Text(title)
                        .font(INFO_BOX_SUBTITLE_FONT)
                    VStack(alignment: .leading, spacing: 10) {
                        description
                            .multilineTextAlignment(.leading)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    }
                }
            }
        }
    }
    
    struct SliderControl: View {
        let id: UUID = UUID()
        let title: String
        let defaultValue: String
        let range: String
        let description: AnyView
        
        init(title: String, defaultValue: String, range: String, description: AnyView) {
            self.title = title
            self.defaultValue = defaultValue
            self.range = range
            self.description = description
        }
        init(title: String, defaultValue: String, range: String, description: String) {
            self.title = title
            self.defaultValue = defaultValue
            self.range = range
            self.description = AnyView(Text(description))
        }
        init(title: String, defaultValue: @escaping () -> String, range: @escaping () -> String, description: String) {
            self.title = title
            self.defaultValue = defaultValue()
            self.range = range()
            self.description = AnyView(Text(description))
        }
        static func fromView<T: View>(
            title: String,
            defaultValue: String,
            range: String,
            @ViewBuilder description: @escaping () -> T
        ) -> SliderControl {
            SliderControl(
                title: title,
                defaultValue: defaultValue,
                range: range,
                description: AnyView(description())
            )
        }
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text(title)
                        .font(ITEM_TITLE_FONT)
                    Spacer()
                    RoundedPill(
                        inactive: true,
                        left: {
                            Text("Range")
                        },
                        right: {
                            Text(self.range)
                        }
                    )
                    RoundedPill(
                        inactive: true,
                        left: {
                            Text("A Good Default Value")
                        },
                        right: {
                            Text(defaultValue)
                        }
                    )
                }
                description
                    .multilineTextAlignment(.leading)
                    .padding(.leading, LEADING_PADDING)
            }
        }
    }
    struct EnumPickerControl: View {
        let id: UUID = UUID()
        let title: String
        let defaultValue: String
        let description: AnyView
        
        init(title: String, defaultValue: String, description: AnyView) {
            self.title = title
            self.defaultValue = defaultValue
            self.description = description
        }
        init(title: String, defaultValue: String, description: String) {
            self.title = title
            self.defaultValue = defaultValue
            self.description = AnyView(Text(description))
        }
        init(title: String, defaultValue: () -> String, description: String) {
            self.title = title
            self.defaultValue = defaultValue()
            self.description = AnyView(Text(description))
        }
        static func fromView<T: View>(
            title: String,
            defaultValue: String,
            @ViewBuilder description: @escaping () -> T
        ) -> EnumPickerControl {
            EnumPickerControl(
                title: title,
                defaultValue: defaultValue,
                description: AnyView(description())
            )
        }
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text(title)
                        .font(ITEM_TITLE_FONT)
                    Spacer()
                    RoundedPill(
                        inactive: true,
                        left: {
                            Text("A Good Default Value")
                        },
                        right: {
                            Text(defaultValue)
                        }
                    )
                }
                description
                    .multilineTextAlignment(.leading)
                    .padding(.leading, LEADING_PADDING)
            }
        }
    }
    struct ToggleControl: View {
        let id: UUID = UUID()
        let title: String
        let defaultValue: String?
        let description: AnyView
        
        init(title: String, defaultValue: String?, description: AnyView) {
            self.title = title
            self.defaultValue = defaultValue
            self.description = description
        }
        init(title: String, defaultValue: String?, description: String) {
            self.title = title
            self.defaultValue = defaultValue
            self.description = AnyView(Text(description))
        }
        static func fromView<T: View>(
            title: String,
            defaultValue: String?,
            @ViewBuilder description: @escaping () -> T
        ) -> ToggleControl {
            ToggleControl(
                title: title,
                defaultValue: defaultValue,
                description: AnyView(description())
            )
        }
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text(title)
                        .font(ITEM_TITLE_FONT)
                    Spacer()
                    if let defaultValue = self.defaultValue {
                        RoundedPill(
                            inactive: true,
                            left: {
                                Text("Default")
                            },
                            right: {
                                Text(defaultValue)
                            }
                        )
                    }
                }
                description
                    .multilineTextAlignment(.leading)
                    .padding(.leading, LEADING_PADDING)
            }
        }
    }
    
    static let docs: Array<Section> = [
        Section(title: "Toolbar UI", overview: "Settings that pertain to the behavior of the toolbar UI.", [
            Item(EnumPickerControl(
                title: "Pen Set",
                defaultValue: "Set 1",
                description: "Pen Sets allow you to organize a list of pens into one of four predefined ‘sets’, which can be quickly toggled in the toolbar."
            ))
        ]),
        Section(title: "Stroke Placement", overview: "Settings that pertain to one of two predefined layers in the drawing canvas.", [
            Item(EnumPickerControl(
                title: "(Canvas) Layer",
                defaultValue: "Foreground",
                description: "The motivation for this feature is to be able to highlight and underline strokes and have such strokes render ‘underneath’ foreground strokes, it just looks nicer. More generally, each stroke can be rendered to the foreground or background layer depending on the given pen’s ‘Layer’ property. ‘Foreground’ should be the default, when you want to create a highlighter pen, set this property to ‘Background’."
            ))
        ]),
        Section(title: "Stroke Coloring", overview: "All colors in SubScript are parameterized over the environment’s color scheme preference, and these settings define the color of a given stroke for a given light or dark color scheme preference.", [
            Item(Concept(
                title: "Template Colors",
                description: "Template colors are a convince feature for defining chromatic colors where the dark and light UI colors are derivatives (i.e.) based on a ‘primary’ color. For convenience, when “Use Template Color” is enabled, the reset button (for the light & dark color derivatives) will reset the given color back to the original template color. This facilitates a workflow where you can quickly define light/dark colors based on a primary color, and then precisely tune the brightness and saturation of your color derivatives without altering the original hue."
            )),
            Item(ToggleControl(
                title: "Use Template Color",
                defaultValue: nil,
                description: "By default this setting is disabled for predefined grayscale pens. "
            )),
            Item(EnumPickerControl(
                title: "Light UI Mode",
                defaultValue: "Black",
                description: "The color of the stroke that will be displayed in light mode. When “Use Template Color” is enabled, the reset button will set this color to your defined template color."
            )),
            Item(EnumPickerControl(
                title: "Dark UI Mode",
                defaultValue: "White",
                description: "The color of the stroke that will be displayed in light mode. When “Use Template Color” is enabled, the reset button will set this color to your defined template color."
            )),
        ]),
        Section(title: "Shaping Paramaters", overview: "These settings alter the generation of a given stroke’s vector outline points, the simplest of such being the stroke diameter (i.e. size).", [
            Item(SliderControl(
                title: "Stroke Diameter",
                defaultValue: {
                    return "\(SS1.PenModel.DynamicPenStyle.defaultSize)"
                },
                range: {
                    let start = SS1.PenModel.DynamicPenStyle.minSize
                    let end = SS1.PenModel.DynamicPenStyle.maxSize
                    return "from \(start) to \(end)"
                },
                description: "The diameter (i.e. size) of the rendered stroke."
            )),
            Item(SliderControl(
                title: "Thinning",
                defaultValue: {
                    return "\(SS1.PenModel.DynamicPenStyle.defaultThinning)"
                },
                range: {
                    let start = SS1.PenModel.DynamicPenStyle.minThinning
                    let end = SS1.PenModel.DynamicPenStyle.maxThinning
                    return "from \(start) to \(end)"
                },
                description: "The effect of pressure on the stroke's size. The thinning option takes a number between ‘-1’ and ‘1’. At ‘0’, pressure will have no effect on the width of the line. When positive, pressure will have a positive effect on the width of the line; and when negative, pressure will have a negative effect on the width of the line."
            )),
            Item(EnumPickerControl(
                title: "Easing",
                defaultValue: "Linear",
                description: "An easing function to apply to each point's pressure. For even finer control over the effect of thinning, we can pass an easing function that will adjust the pressure along a curve."
            )),
            Item(SliderControl(
                title: "Smoothing",
                defaultValue: {
                    return "\(SS1.PenModel.DynamicPenStyle.defaultSmoothing)"
                },
                range: {
                    let start = SS1.PenModel.DynamicPenStyle.minSmoothing
                    let end = SS1.PenModel.DynamicPenStyle.maxSmoothing
                    return "from \(start) to \(end)"
                },
                description: "How much to soften the stroke's edges. We can also control the density of points along the edges of our polygon using the smoothing option. At zero, the polygon will contain many points, and may appear jagged or bumpy. At higher values, the polygon will contain fewer points and lose definition."
            )),
            Item(SliderControl(
                title: "Streamline",
                defaultValue: {
                    return "\(SS1.PenModel.DynamicPenStyle.defaultSmoothing)"
                },
                range: {
                    let start = SS1.PenModel.DynamicPenStyle.minStreamline
                    let end = SS1.PenModel.DynamicPenStyle.maxStreamline
                    return "from \(start) to \(end)"
                },
                description: "How much to streamline the stroke. Often the input points recorded for a line are 'noisy', or full of irregularities. To fix this, the shaping algorithm applies a “low pass” filter that moves the points closer to a perfect curve. We can control the strength of this filter through the streamline option."
            )),
            Item(ToggleControl(
                title: "Use Real Pressure (Force)",
                defaultValue: "Disabled",
                description: "Whether or not to use pressure metrics reported by the Apple Pencil."
            )),
            Item(ToggleControl(
                title: "Simulate Pressure (Force)",
                defaultValue: "Enabled",
                description: "Whether to simulate pressure based on velocity (this will override pressure metrics reported by the Apple Pencil with a static value)."
            )),
            Item(SliderControl(
                title: "Static Pressure",
                defaultValue: "0.5",
                range: "Undefined",
                description: "A pressure constant to use when relevant."
            )),
            Item(Tip(
                info: "To create a stroke with a steady line, set the thinning option to '0'."
            )),
            Item(Tip(
                info: "To create a stroke that gets thinner with pressure instead of thicker, use a negative number for the thinning option."
            )),
        ]),
    ]
}

extension SS1.ToolBarView.PenSettingsForm {
    struct DocView: View {
        fileprivate let contents = TopLevelDocSection.docs
        var body: some View {
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    ForEach(contents) { section in
                        section
                    }
                }
                .padding(.trailing, 20)
            }
        }
    }
}

