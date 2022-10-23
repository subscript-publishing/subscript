//
//  Heading.swift
//  SubScript
//
//  Created by Colbyn Wadman on 10/20/22.
//

import SwiftUI

fileprivate struct SegmentedViewWrapper<L: View, C: View, R: View>: View {
//    let viewport: CGSize
    var height: CGFloat? = nil
    @ViewBuilder var left: L
    @ViewBuilder var center: C
    @ViewBuilder var right: R
    var body: some View {
        let foregroundColor = Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        HStack(alignment: .center, spacing: 0) {
            left.frame(width: 50, height: height, alignment: .center)
            center
                .frame(height: height, alignment: .leading)
                .border(edges: [.leading, .trailing])
            right.frame(width: 50, height: height)
        }
        .frame(height: height)
        .foregroundColor(foregroundColor)
    }
}

extension SS1 {
    struct Heading: Codable {
        var type: HeadingType = HeadingType.h1
        var text: String = "New Title"
        init() {
            self.type = .h1
            self.text = ""
        }
        init(heading: HeadingType, text: String) {
            self.type = heading
            self.text = text
        }
        init(h1 text: String) {
            self.init(heading: .h1, text: text)
        }
        init(h2 text: String) {
            self.init(heading: .h2, text: text)
        }
        init(h3 text: String) {
            self.init(heading: .h3, text: text)
        }
        init(h4 text: String) {
            self.init(heading: .h4, text: text)
        }
        init(h5 text: String) {
            self.init(heading: .h5, text: text)
        }
        init(h6 text: String) {
            self.init(heading: .h6, text: text)
        }
        enum HeadingType: String, CaseIterable, Codable {
            case h1
            case h2
            case h3
            case h4
            case h5
            case h6
            var asString: String {
                switch self {
                case .h1: return "H1"
                case .h2: return "H2"
                case .h3: return "H3"
                case .h4: return "H4"
                case .h5: return "H5"
                case .h6: return "H6"
                }
            }
            var defaultTextSize: CGFloat {
                switch self {
                case .h1: return 32
                case .h2: return 28
                case .h3: return 24
                case .h4: return 20
                case .h5: return 16
                case .h6: return 12
                }
            }
            var defaultLeadingMargin: CGFloat {
                switch self {
                case .h1: return 0
                case .h2: return 30
                case .h3: return 60
                case .h4: return 90
                case .h5: return 100
                case .h6: return 110
                }
            }
        }
    }
    struct HeadingView: View {
        @Binding var title: SS1.Heading
        let deleteMe: () -> ()
        
        @State private var showLeftOptions: Bool = false
        @State private var showRightOptions: Bool = false
        
        @ViewBuilder func selectHeadingType() -> some View {
            Picker("Type", selection: $title.type) {
                Text("H1").tag(SS1.Heading.HeadingType.h1)
                Text("H2").tag(SS1.Heading.HeadingType.h2)
                Text("H3").tag(SS1.Heading.HeadingType.h3)
                Text("H4").tag(SS1.Heading.HeadingType.h4)
                Text("H5").tag(SS1.Heading.HeadingType.h5)
                Text("H6").tag(SS1.Heading.HeadingType.h6)
            }
            .pickerStyle(SegmentedPickerStyle())
            .btnLabelTheme()
            .padding(15)
        }
        
        @ViewBuilder func options() -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    showRightOptions = false
                    deleteMe()
                }, label: {
                    Text("Delete")
                        .btnLabelTheme()
                })
                    .padding(8)
                    .border(edges: .all)
            }
            .padding(12)
        }
        
        var body: some View {
            SegmentedViewWrapper(
                left: {
                    Button(
                        action: {showLeftOptions = true},
                        label: {
                            Text(title.type.asString)
                                .btnLabelTheme()
                                .padding(12)
                        }
                    )
                        .buttonStyle(PlainButtonStyle())
                        .popover(isPresented: $showLeftOptions, content: selectHeadingType)
                },
                center: {
                    TextField("Title", text: $title.text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .textTheme()
//#if os(iOS)
//                        .autocapitalization(NSTextAutocapitalizationType.words)
//#endif
                        .font(.system(size: 25, weight: Font.Weight.medium, design: Font.Design.monospaced))
                        .padding(12)
                },
                right: {
                    Button(
                        action: {showRightOptions = true},
                        label: {
                            Image(systemName: "gearshape.fill")
                                .btnLabelTheme()
                        }
                    )
                        .buttonStyle(PlainButtonStyle())
                        .popover(isPresented: $showRightOptions, content: options)
                }
            )
            .border(width: 0.5, edges: [.top])
        }
    }
}
