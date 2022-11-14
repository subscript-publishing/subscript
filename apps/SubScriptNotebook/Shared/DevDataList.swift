//
//  DevDataList.swift
//  SubScriptNotebook
//
//  Created by Colbyn Wadman on 11/11/22.
//

import SwiftUI
import UniformTypeIdentifiers

//extension UTType {
//    static var transferrableItemType: UTType {
//        UTType.init(tag: "", tagClass: <#T##UTTagClass#>, conformingTo: <#T##UTType?#>)
//    }
//}

struct DevDataList: View {
    fileprivate static let typeId = UTType.binaryPropertyList.identifier
    enum EncodingError: Error {
      case invalidData
    }
    fileprivate struct TransferrableProviderDropDelegate: DropDelegate {
        func performDrop(info: DropInfo) -> Bool {
            print("performDrop: ", info)
            return true
        }
        func dropEntered(info: DropInfo) {
            print("dropEntered: ", info)
        }
    }
    class TransferrableProvider: NSObject, Identifiable, NSItemProviderWriting, NSItemProviderReading {
        typealias PayloadItemType = DevItem
        struct PayloadData: Codable {
            let index: Int
            let payload: PayloadItemType
        }
        let payload: PayloadData
        required init(payloadData: PayloadData) {
            self.payload = payloadData
        }
        init(index: Int, payload: DevItem) {
            self.payload = PayloadData(index: index, payload: payload)
        }
        static var readableTypeIdentifiersForItemProvider: [String] = [
            DevDataList.typeId
        ]
        static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
            if typeIdentifier == DevDataList.typeId {
                do {
                    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
                    guard let payload = try unarchiver.decodeTopLevelDecodable(
                        PayloadData.self, forKey: NSKeyedArchiveRootObjectKey
                    ) else {
                        throw EncodingError.invalidData
                    }
                    return self.init(payloadData: payload)
                  } catch {
                    throw EncodingError.invalidData
                  }
            }
            throw EncodingError.invalidData
        }
        static var writableTypeIdentifiersForItemProvider: [String] = [
            DevDataList.typeId
        ]
        func loadData(
            withTypeIdentifier typeIdentifier: String,
            forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void
        ) -> Progress? {
            if typeIdentifier == DevDataList.typeId {
                do {
                    let archiver = NSKeyedArchiver(requiringSecureCoding: false)
                    try archiver.encodeEncodable(self.payload, forKey: NSKeyedArchiveRootObjectKey)
                    archiver.finishEncoding()
                    let data = archiver.encodedData
                    completionHandler(data, nil)
                  } catch {
                    completionHandler(nil, nil)
                  }
            }
            return nil
        }
    }
    struct DevItem: Identifiable, Codable {
        let id: UUID
        let value: Int
    }
    private var transferrableProviderDropDelegate = TransferrableProviderDropDelegate()
    @Environment(\.colorScheme) private var colorScheme
    let listID = UUID()
    @State private var data: Array<DevItem> = {
        var xs: [DevItem] = [
            DevItem(id: UUID(), value: 1),
            DevItem(id: UUID(), value: 2)
        ]
//        for i in (0...10) {
//            xs.append(DevItem(id: UUID(), value: i))
//        }
        return xs
    }()
    @ViewBuilder private func entryView(ix: Int, item: DevItem) -> some View {
        
    }
    var body: some View {
        let evenItemBackgroundColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
            darkMode: #colorLiteral(red: 0.2842785675, green: 0.306146147, blue: 0.3367607582, alpha: 1)
        )
        let backgroundColorMap = UX.ColorMap(
            lightMode: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1),
            darkMode: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        )
        let evenBackgroundColor = evenItemBackgroundColorMap.get(for: colorScheme).asColor
        let backgroundColor = backgroundColorMap.get(for: colorScheme).asColor
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.1.id) { (ix, item) in
                    let isFirstElement = ix == 0
                    DevItemView(listID: self.listID, data: $data, index: ix, item: item)
                        .background(ix.isMultiple(of: 2) ? evenBackgroundColor : Color.clear)
                        .withBorder(edges: isFirstElement ? [.top, .bottom] : [.bottom])
                }
                Spacer()
            }
        }
        .background(backgroundColor)
    }
    
    struct DevItemView: View, DropDelegate {
        let listID: UUID
        @Binding var data: Array<DevItem>
        let index: Int
        let item: DevItem
        @State private var isTargeted: Bool = false
        enum Placement: Equatable {
            case top
            case center
            case bottom
            var isTop: Bool {
                self == .top
            }
            var isCenter: Bool {
                self == .center
            }
            var isBottom: Bool {
                self == .bottom
            }
        }
        @ViewBuilder private func entry(item: DevItem) -> some View {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text("\(item.id)")
                    Spacer()
                }
                Text("\(item.value)")
                Spacer()
            }
            .padding(.leading, 20)
            .font(.system(size: 12, weight: Font.Weight.light, design: Font.Design.monospaced))
        }
        @Environment(\.colorScheme) private var colorScheme
        private let height: CGFloat = 35.0
        private let hoveringPreviewHeight: CGFloat = 5
        @GestureState var tapGesture = false
        @ViewBuilder private var content: some View {
            let hoverBgColorMap = UX.ColorMap(
                lightMode: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),
                darkMode: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            )
            let hoverBgColor = hoverBgColorMap.get(for: colorScheme).asColor
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                }
                .frame(height: hoveringPreviewHeight)
                .background(hoverBgColor)
                .withBorder(edges: .bottom)
                .isHidden(dropPayloadPreview?.placement != .top)
                self.entry(item: self.item)
                    .frame(height: height, alignment: SwiftUI.Alignment.center)
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                }
                .frame(height: hoveringPreviewHeight)
                .background(hoverBgColor)
                .withBorder(edges: .top)
                .isHidden(dropPayloadPreview?.placement != .bottom)
            }
                .onDrop(of: [.binaryPropertyList], delegate: self)
                .onDrag({
                    let objectProvider = TransferrableProvider.init(index: self.index, payload: self.item)
                    let itemProvider = NSItemProvider(object: objectProvider)
                    return itemProvider
                })
//                .simultaneousGesture(LongPressGesture()
//                   .updating($tapGesture) { _,_,_  in
//                       print("updating")
//                   }
//                   .onEnded { _ in
//                       print("ended")
//                   })
//                .simultaneousGesture(DragGesture()
//                   .updating($tapGesture) { _,_,_  in
//                       print("updating")
//                   }
//                   .onEnded { _ in
//                       print("ended")
//                   }
//                )
        }
        var body: some View {
            content
        }
        private func getHoveringPlacement(info: DropInfo) -> HoveringPlacement? {
            if info.location.y < height / 2.0 {
                return HoveringPlacement.top
            }
            if info.location.y >= height / 2.0 {
                return HoveringPlacement.bottom
            }
            return nil
        }
        fileprivate  enum HoveringPlacement: Equatable {
            case top
            case bottom
        }
        fileprivate struct DropPayload {
            let placement: HoveringPlacement
            let data: DevDataList.TransferrableProvider.PayloadData
        }
        @State private var dropPayloadPreview: DropPayload? = nil
        private func givenDropInfo(
            info: DropInfo,
            ifInvalid: @escaping (TransferrableProvider?) -> (),
            ifValid: @escaping (TransferrableProvider, DropPayload) -> ()
        ) {
            let placement = self.getHoveringPlacement(info: info)!
            let providers = info.itemProviders(for: [.binaryPropertyList])
            assert(providers.count == 1)
            let provider = providers[0]
            provider.loadObject(ofClass: TransferrableProvider.self) { provider, error in
                if let provider = provider as? TransferrableProvider {
                    let value = provider.payload
                    if value.index == self.index {
                        return ifInvalid(provider)
                    }
                    let payload = DropPayload(placement: placement, data: value)
                    ifValid(provider, payload)
                }
            }
        }
        func performDrop(info: DropInfo) -> Bool {
            givenDropInfo(
                info: info,
                ifInvalid: { provider in
                    print("performDrop: invalid")
//                    if let provider = provider {
//
//                    }
                },
                ifValid: { provider, payload in
                    print("performDrop: valid")
                    let newIndex = payload.placement == .top
                        ? self.index
                        : self.data.index(after: self.index)
                    let source = IndexSet.init(integer: payload.data.index)
                    self.data.move(fromOffsets: source, toOffset: newIndex)
                }
            )
            return true
        }
        func validateDrop(info: DropInfo) -> Bool {
            print("validateDrop", info.location)
            return true
        }
        func dropExited(info: DropInfo) {
            self.dropPayloadPreview = nil
        }
        func dropEntered(info: DropInfo) {
            givenDropInfo(
                info: info,
                ifInvalid: { provider in
                    self.dropPayloadPreview = nil
                },
                ifValid: { provider, payload in
                    self.dropPayloadPreview = payload
                }
            )
        }
        func dropUpdated(info: DropInfo) -> DropProposal? {
            givenDropInfo(
                info: info,
                ifInvalid: { provider in
                    self.dropPayloadPreview = nil
                },
                ifValid: { provider, payload in
                    self.dropPayloadPreview = payload
                }
            )
//            return DropProposal.init(operation: DropOperation.move)
            return nil
        }
    }
}

